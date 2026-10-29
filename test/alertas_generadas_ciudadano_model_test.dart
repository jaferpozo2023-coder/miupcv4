import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pne/app/data/models/models.dart';

void main() {
  Map<String, dynamic> respuesta() => jsonDecode(
    File('test/fixtures/alertas_generadas_ciudadano.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test(
    'interpreta el contrato completo de alertas generadas del ciudadano',
    () {
      final consulta = ConsultaAlertasGeneradasCiudadano.fromJson(respuesta());
      final ciudadano = consulta.datos.single;
      expect(consulta.codeError, 0);
      expect(consulta.msj, 'existe');
      expect(ciudadano.documento, 'documento-prueba');
      expect(ciudadano.idGenPersona, 1250);
      expect(ciudadano.apenom, 'Ciudadano de prueba');
      expect(ciudadano.totalAlertas, 5);
      expect(ciudadano.totalPendientes, 4);
      expect(ciudadano.totalEnAtencion, 0);
      expect(ciudadano.totalAtendidas, 1);
      expect(ciudadano.pendientes, hasLength(4));
      expect(ciudadano.enAtencion, isEmpty);
      expect(ciudadano.atendidas, hasLength(1));
      expect(ciudadano.alertas, hasLength(5));
      expect(ciudadano.todas.map((item) => item.idDgoAlertasMovilCiu), [
        5,
        4,
        3,
        2,
        1,
      ]);

      final pendiente = ciudadano.pendientes.first;
      expect(pendiente.idDgoPersonasAlertaApp, 2);
      expect(pendiente.estado, 'PENDIENTE');
      expect(pendiente.estadoAlerta, 'PENDIENTE');
      expect(pendiente.fechaAlerta, '2026-10-12 00:13:30');
      expect(pendiente.fechaAtencion, isNull);
      expect(pendiente.procedimiento, isNull);
      expect(pendiente.estadoVerificacion, isNull);
      expect(pendiente.atencion?.idGenUsuarioAtiende, isNull);
      expect(pendiente.ubicacionAlerta?.latitud, -0.18);
      expect(pendiente.ubicacionAlerta?.longitud, -78.46);
      expect(pendiente.ubicacionAlerta?.esValida, isTrue);
      final establecimiento = pendiente.establecimiento!;
      expect(establecimiento.institucion, 'Local de prueba');
      expect(establecimiento.tipoUsuario, 'PROPIETARIO');
      expect(establecimiento.direccion, 'Calle de prueba');
      expect(establecimiento.telefono, '0999999999');
      expect(establecimiento.mail, 'ciudadano@example.com');
      expect(establecimiento.latitud, -0.19);
      expect(establecimiento.longitud, -78.47);

      final atendida = ciudadano.atendidas.single;
      expect(atendida.fechaAtencion, '2026-10-11 23:28:22');
      expect(atendida.procedimiento, 'Se verificó la novedad.');
      expect(atendida.estadoVerificacion, isEmpty);
      expect(atendida.atencion?.servidorPolicial, 'Servidor de prueba');
      expect(atendida.atencion?.idGenUsuarioAtiende, 1250);
      expect(atendida.atencion?.procedimiento, atendida.procedimiento);
      expect(atendida.atencion?.fechaAtencion, atendida.fechaAtencion);
      expect(
        atendida.atencion?.estadoVerificacion,
        atendida.estadoVerificacion,
      );
      expect(
        ConsultaAlertasGeneradasCiudadano.fromJson(consulta.toJson()).toJson(),
        consulta.toJson(),
      );
    },
  );

  test(
    'incluye las alertas en atención aunque no exista una lista general',
    () {
      final ciudadano = AlertasGeneradasCiudadano.fromJson({
        'documento': 'documento-prueba',
        'totalAlertas': '1',
        'totalEnAtencion': '1',
        'enAtencion': [
          {'idDgoAlertasMovilCiu': '8', 'estado': 'EN_ATENCION'},
        ],
      });
      expect(ciudadano.totalEnAtencion, 1);
      expect(ciudadano.todas.single.idDgoAlertasMovilCiu, 8);
      expect(ciudadano.todas.single.estadoActual, 'EN_ATENCION');
      expect(ciudadano.todas.single.ubicacionAlerta, isNull);
      expect(ciudadano.todas.single.establecimiento, isNull);
      expect(ciudadano.todas.single.atencion, isNull);
    },
  );

  test('una respuesta vacía válida difiere de una respuesta incompleta', () {
    expect(
      ConsultaAlertasGeneradasCiudadano.fromJson({
        'alertasCiudadano': {'codeError': 0, 'msj': 'noExiste', 'datos': []},
      }).datos,
      isEmpty,
    );
    for (final json in [
      <String, dynamic>{},
      {
        'alertasCiudadano': {'datos': []},
      },
      {
        'alertasCiudadano': {'codeError': null, 'datos': []},
      },
      {
        'alertasCiudadano': {'codeError': 0},
      },
      {
        'alertasCiudadano': {'codeError': 0, 'datos': {}},
      },
    ]) {
      expect(
        () => ConsultaAlertasGeneradasCiudadano.fromJson(json),
        throwsFormatException,
      );
    }
    final error = ConsultaAlertasGeneradasCiudadano.fromJson({
      'alertasCiudadano': {'codeError': 1, 'msj': 'Servicio no disponible'},
    });
    expect(error.codeError, 1);
    expect(error.datos, isEmpty);
  });

  test(
    'las coordenadas inválidas no se presentan como una ubicación válida',
    () {
      for (final json in [
        {'latitud': null, 'longitud': '-78'},
        {'latitud': 'NaN', 'longitud': '-78'},
        {'latitud': '-91', 'longitud': '-78'},
        {'latitud': '-0.18', 'longitud': '-181'},
      ]) {
        expect(UbicacionAlertaGenerada.fromJson(json).esValida, isFalse);
      }
    },
  );
}
