import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pne/app/core/exceptions/exceptions.dart';
import 'package:pne/app/core/exceptions/network_exception.dart';
import 'package:pne/app/data/models/models.dart';
import 'package:pne/app/data/providers/providers_impl.dart';
import 'package:pne/app/data/providers/remote/host/mi_upc_api_client.dart';
import 'package:pne/app/data/repository/data_repositories.dart';

void main() {
  test('consultas simultáneas del mismo documento comparten una petición, sin guardar permisos', () async {
    var llamadas = 0;
    final espera = Completer<String>();
    final provider = PermisosMiUpcApiProviderImpl(
      client: MiUpcApiClient(
        post: ({required segmento, required body}) {
          llamadas++;
          expect(body['documento'], 'documento-prueba');
          return espera.future;
        },
      ),
    );
    final primera = provider.consultarPermisosMiUpc(
      documento: 'documento-prueba',
    );
    final segunda = provider.consultarPermisosMiUpc(
      documento: ' documento-prueba ',
    );
    expect(identical(primera, segunda), isTrue);
    expect(llamadas, 1);
    espera.complete(
      jsonEncode({
        'permisosMiUpc': {'codeError': 0, 'datos': []},
      }),
    );
    await Future.wait([primera, segunda]);
    await provider.consultarPermisosMiUpc(documento: 'documento-prueba');
    expect(llamadas, 2);
  });

  test(
    'documentos distintos no comparten permisos y un fallo permite reintentar',
    () async {
      var llamadas = 0;
      var sinRed = true;
      final provider = PermisosMiUpcApiProviderImpl(
        client: MiUpcApiClient(
          post: ({required segmento, required body}) async {
            llamadas++;
            if (sinRed) {
              throw const SocketException(
                "Failed host lookup: 'servidor-prueba'",
              );
            }
            return jsonEncode({
              'permisosMiUpc': {
                'codeError': 0,
                'datos': [
                  {'documento': body['documento']},
                ],
              },
            });
          },
        ),
      );
      await expectLater(
        provider.consultarPermisosMiUpc(documento: 'cuenta-uno'),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.tipo,
            'tipo',
            TipoErrorRed.dns,
          ),
        ),
      );
      sinRed = false;
      final resultados = await Future.wait([
        provider.consultarPermisosMiUpc(documento: 'cuenta-uno'),
        provider.consultarPermisosMiUpc(documento: 'cuenta-dos'),
      ]);
      expect(resultados.map((r) => r.datos.single.documento), [
        'cuenta-uno',
        'cuenta-dos',
      ]);
      expect(llamadas, 3);
    },
  );

  test(
    'cada repositorio conserva la operación y los parámetros del contrato',
    () async {
      final peticiones = <Map<String, dynamic>>[];
      final client = MiUpcApiClient(
        post: ({required segmento, required body}) async {
          expect(segmento, 'polco/index.php');
          expect(body['modulo'], 'ddced13c854fb2c03d6e01ce5bfd7e08');
          peticiones.add(body);
          final key = switch (body['opc']) {
            'v1-post-valida-ciudadano-alerta' => 'ciudadanoAlerta',
            'v1-post-vincula-dispositivo-policial' => 'dispositivoPolicial',
            'v1-post-alerta-ciudadana' => 'alertaCiudadana',
            'v1-post-atender-alerta-ciudadana' => 'atencionAlertaCiudadana',
            'v1-post-permisos-miupc' => 'permisosMiUpc',
            'v1-post-alertas-atendidas-policia' => 'alertasAtendidasPolicia',
            _ => throw StateError('Operación inesperada'),
          };
          return jsonEncode({
            key: {'codeError': 0, 'msj': 'true', 'datos': []},
          });
        },
      );

      await ValidacionCiudadanoAlertaApiImpl(
        ValidacionCiudadanoAlertaApiProviderImpl(client: client),
      ).validarCiudadanoAlerta(documento: 'documento-prueba');
      await VinculacionDispositivoPolicialApiImpl(
        VinculacionDispositivoPolicialApiProviderImpl(client: client),
      ).vincularDispositivoPolicial(
        documento: 'documento-prueba',
        instalacion: 'instalacion',
        dispositivo: 'telefono',
        plataforma: 'ANDROID',
        tokenNotificacion: 'token-prueba',
      );
      await CrearAlertaCiudadanaApiImpl(
        CrearAlertaCiudadanaApiProviderImpl(client: client),
      ).crearAlertaCiudadana(
        idDgoPersonasAlertaApp: 7,
        latitud: -0.18,
        longitud: -78.46,
        observacion: 'Se requiere ayuda',
      );
      await AtenderAlertaCiudadanaApiImpl(
        AtenderAlertaCiudadanaApiProviderImpl(client: client),
      ).atenderAlertaCiudadana(
        idDgoAlertasMovilCiu: 51,
        idGenUsuario: 1250,
        procedimiento: 'Procedimiento realizado',
        estadoVerificacion: 'VERIFICADA',
      );
      await PermisosMiUpcApiImpl(PermisosMiUpcApiProviderImpl(client: client))
          .consultarPermisosMiUpc(documento: 'documento-prueba');
      await AlertasPoliciaApiImpl(AlertasPoliciaApiProviderImpl(client: client))
          .consultarAlertasPolicia(documento: 'documento-prueba');
      await AlertasAtendidasPoliciaApiImpl(
        AlertasAtendidasPoliciaApiProviderImpl(client: client),
      ).consultarAlertasAtendidas(documento: 'documento-prueba');

      expect(peticiones.length, 7);
      expect(peticiones.map((item) => item['opc']).toSet().length, 7);
      expect(peticiones[2]['latitud'], '-0.18');
      expect(peticiones[2]['longitud'], '-78.46');
      expect(peticiones[2]['idDgoPersonasAlertaApp'], 7);
      expect(peticiones[3]['idGenUsuario'], 1250);
      expect(peticiones[3]['procedimiento'], 'Procedimiento realizado');
      expect(peticiones[5]['documento'], 'documento-prueba');
      expect(peticiones[6]['documento'], 'documento-prueba');
    },
  );

  test('la bandeja respeta coordenadas de la alerta y acepta campos nulos', () {
    final respuesta = ConsultaAlertasPolicia.fromJson({
      'alertasPolicia': {
        'datos': [
          {
            'documento': 'documento-prueba',
            'idGenUsuario': '1250',
            'totalPendientes': 1,
            'totalAtendidas': 1,
            'total': 2,
            'pendientes': [
              {
                'idDgoAlertasMovilCiu': 51,
                'estadoAlerta': 'GENERADA',
                'procedimiento': null,
                'estadoVerificacion': null,
                'ubicacionAlerta': {
                  'latitud': '-0.1806532',
                  'longitud': '-78.4678382',
                },
                'establecimiento': {
                  'institucion': 'LOCAL COMERCIAL',
                  'direccion': 'Dirección',
                  'latitud': '-1',
                  'longitud': '-79',
                },
                'ciudadano': {
                  'apenom': 'Ciudadano de prueba',
                  'telefono': '0999999999',
                },
              },
            ],
            'atendidas': [
              {
                'idDgoAlertasMovilCiu': 45,
                'estadoAlerta': 'ATENDIDA',
                'procedimiento': 'Se verificó la novedad.',
                'estadoVerificacion': 'VERIFICADA',
              },
            ],
          },
        ],
      },
    });
    final datos = respuesta.datos.single;
    expect(respuesta.codeError, 0);
    expect(datos.pendientes.single.latitud, -0.1806532);
    expect(datos.pendientes.single.institucion, 'LOCAL COMERCIAL');
    expect(datos.pendientes.single.ciudadano, 'Ciudadano de prueba');
    expect(datos.pendientes.single.procedimiento, isEmpty);
    expect(datos.atendidas.single.atendida, isTrue);
    expect(datos.atendidas.single.tieneUbicacion, isFalse);
  });

  test('el historial conserva el procedimiento y la fecha de atención', () {
    final respuesta = AlertasAtendidasPolicia.fromJson({
      'alertasAtendidasPolicia': {
        'datos': [
          {
            'documento': 'documento-prueba',
            'totalAtendidas': 1,
            'alertas': [
              {
                'idDgoAlertasMovilCiu': 25,
                'estadoAlerta': 'ATENDIDA',
                'fechaAtencion': '2026-10-11 18:37:00',
                'procedimiento': 'Se verificó la novedad.',
                'estadoVerificacion': 'VERIFICADA',
                'ubicacionAlerta': {'latitud': '-0.18', 'longitud': '-78.46'},
              },
            ],
          },
        ],
      },
    });
    expect(
      respuesta.datos.single.alertas.single.fechaAtencion,
      '2026-10-11 18:37:00',
    );
    expect(
      respuesta.datos.single.alertas.single.procedimiento,
      'Se verificó la novedad.',
    );
  });

  test(
    'respuestas incompletas no se interpretan como permisos ni listas válidas',
    () async {
      final provider = PermisosMiUpcApiProviderImpl(
        client: MiUpcApiClient(
          post: ({required segmento, required body}) async => '{}',
        ),
      );
      await expectLater(
        provider.consultarPermisosMiUpc(documento: 'documento-prueba'),
        throwsA(isA<ServerException>()),
      );
      expect(
        () => ConsultaAlertasPolicia.fromJson({'alertasPolicia': {}}),
        throwsFormatException,
      );
      expect(() => AlertasAtendidasPolicia.fromJson({}), throwsFormatException);
      expect(
        () => ConsultaPermisosMiUpc.fromJson({
          'permisosMiUpc': {'codeError': 0},
        }),
        throwsFormatException,
      );
      expect(
        () => ConsultaPermisosMiUpc.fromJson({
          'permisosMiUpc': {'codeError': null, 'datos': []},
        }),
        throwsFormatException,
      );
    },
  );

  test('el permiso policial necesita un servidor activo y no se deduce por ausencia de permiso ciudadano', () {
    PermisoMiUpc permiso({
      bool ciudadano = false,
      bool policial = false,
      bool activo = false,
      int id = 0,
    }) => PermisoMiUpc.fromJson({
      'tienePermiso': ciudadano || policial,
      'permisoCiudadano': ciudadano,
      'permisoPolicial': policial,
      'servidorPolicial': {'activo': activo, 'idGenUsuario': id},
    });
    expect(permiso().puedeAtenderAlertas, isFalse);
    expect(permiso(policial: true, id: 1250).puedeAtenderAlertas, isFalse);
    expect(permiso(policial: true, activo: true).puedeAtenderAlertas, isFalse);
    expect(
      permiso(policial: true, activo: true, id: 1250).puedeAtenderAlertas,
      isTrue,
    );
    expect(permiso(ciudadano: true).puedeEnviarAlertas, isTrue);
  });
}
