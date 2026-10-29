import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pne/app/core/exceptions/network_exception.dart';
import 'package:pne/app/data/models/models.dart';
import 'package:pne/app/data/models/personal_hotel_model.dart';
import 'package:pne/app/data/providers/providers_impl.dart';
import 'package:pne/app/data/repository/data_repositories.dart';
import 'package:pne/app/domain/repositories/domain_repositories.dart';
import 'package:pne/app/presentation/modules/alertasCiudadanas/alertas_ciudadanas_controller.dart';
import 'package:pne/app/presentation/modules/alertasCiudadanas/alertas_ciudadanas_page.dart';
import 'package:pne/app/presentation/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

const documentoPrueba = 'documento-prueba';

PermisoMiUpc permisoPrueba({
  bool ciudadano = false,
  bool policia = false,
  bool hotel = false,
}) => PermisoMiUpc.fromJson({
  'documento': documentoPrueba,
  'tienePermiso': ciudadano || policia || hotel,
  'permisoCiudadano': ciudadano || hotel,
  'permisoPolicial': policia,
  'ciudadano': ciudadano || hotel
      ? {
          'documento': documentoPrueba,
          'idDgoPersonasAlertaApp': 17,
          'tipoUsuario': hotel ? 'PROPIETARIO' : 'CIUDADANO',
          'codigoInstitucion': hotel ? 'HOT-88FDA816313A605972F68D7B' : '',
          'institucion': hotel ? 'HOTEL UNICORNIO' : '',
        }
      : null,
  'servidorPolicial': policia
      ? {
          'activo': true,
          'idGenUsuario': 1250,
          'unidad': 'DNTICS',
          'dispositivo': 'samsung-SM-A705MN',
          'plataforma': 'Android',
          'dispositivoVinculado': true,
          'tokenRegistrado': true,
        }
      : null,
});

class _Permisos implements PermisosMiUpcRepository {
  PermisoMiUpc permiso = permisoPrueba(policia: true);
  int llamadas = 0;
  int codeError = 0;
  Object? fallo;
  Completer<void>? espera;
  @override
  Future<ConsultaPermisosMiUpc> consultarPermisosMiUpc({
    required String documento,
  }) async {
    llamadas++;
    if (espera != null) await espera!.future;
    if (fallo != null) throw fallo!;
    return ConsultaPermisosMiUpc(
      codeError: codeError,
      msj: codeError == 0 ? '' : 'Servicio de permisos no disponible.',
      datos: [permiso],
    );
  }
}

class _Validacion implements ValidacionCiudadanoAlertaRepository {
  int llamadas = 0;
  List<CiudadanoAlerta> datos = [];
  @override
  Future<ValidacionCiudadanoAlerta> validarCiudadanoAlerta({
    required String documento,
  }) async {
    llamadas++;
    return ValidacionCiudadanoAlerta(codeError: 0, msj: '', datos: datos);
  }
}

class _Crear implements CrearAlertaCiudadanaRepository {
  int llamadas = 0;
  RespuestaAlertaCiudadana respuesta = const RespuestaAlertaCiudadana(
    codeError: 0,
    msj: '',
    datos: null,
  );
  @override
  Future<RespuestaAlertaCiudadana> crearAlertaCiudadana({
    required int idDgoPersonasAlertaApp,
    required double latitud,
    required double longitud,
    required String observacion,
  }) async {
    llamadas++;
    return respuesta;
  }
}

class _Atender implements AtenderAlertaCiudadanaRepository {
  int llamadas = 0;
  int idConfirmado = 51;
  @override
  Future<RespuestaAtencionAlertaCiudadana> atenderAlertaCiudadana({
    required int idDgoAlertasMovilCiu,
    required int idGenUsuario,
    required String procedimiento,
    required String estadoVerificacion,
  }) async {
    llamadas++;
    expect(idDgoAlertasMovilCiu, 51);
    expect(idGenUsuario, 1250);
    expect(procedimiento, 'Se verificó la novedad.');
    expect(estadoVerificacion, 'VERIFICADA');
    return RespuestaAtencionAlertaCiudadana(
      codeError: 0,
      msj: '',
      datos: AtencionAlertaCiudadana(
        idDgoAlertasMovilCiu: idConfirmado,
        idGenUsuarioAtiende: 1250,
        estadoAlerta: 'ATENDIDA',
        estadoVerificacion: 'VERIFICADA',
        fechaAtencion: '2026-10-11 19:30:00',
      ),
    );
  }
}

class _Bandeja implements AlertasPoliciaRepository {
  int llamadas = 0;
  Object? fallo;
  @override
  Future<ConsultaAlertasPolicia> consultarAlertasPolicia({
    required String documento,
  }) async {
    llamadas++;
    expect(documento, documentoPrueba);
    if (fallo != null) throw fallo!;
    return ConsultaAlertasPolicia.fromJson({
      'alertasPolicia': {
        'datos': [
          {
            'documento': documentoPrueba,
            'pendientes': [
              {
                'idDgoAlertasMovilCiu': 51,
                'estadoAlerta': 'GENERADA',
                'observacion': 'Se requiere presencia policial.',
              },
            ],
            'atendidas': [],
          },
          {
            'documento': 'otra-cuenta',
            'pendientes': [
              {'idDgoAlertasMovilCiu': 99},
            ],
            'atendidas': [],
          },
        ],
      },
    });
  }
}

class _Generadas implements AlertasGeneradasCiudadanoRepository {
  ConsultaAlertasGeneradasCiudadano respuesta =
      ConsultaAlertasGeneradasCiudadano.fromJson(
        jsonDecode(
          File('test/fixtures/alertas_generadas_ciudadano.json')
              .readAsStringSync(),
        ) as Map<String, dynamic>,
      );
  int llamadas = 0;
  String? documentoConsultado;
  Object? fallo;
  Completer<ConsultaAlertasGeneradasCiudadano>? pendiente;

  @override
  Future<ConsultaAlertasGeneradasCiudadano> consultarAlertasGeneradas({
    required String documento,
  }) async {
    llamadas++;
    documentoConsultado = documento;
    if (pendiente != null) return pendiente!.future;
    if (fallo != null) throw fallo!;
    return respuesta;
  }
}

class _PersonalHotel implements PersonalHotelRepository {
  int llamadas = 0;
  int? idPersona;
  String? documento;
  String? nombres;
  String? nacionalidad;

  @override
  Future<RespuestaRegistroPersonalHotel> registrarPersonalHotel({
    required int idDgoPersonasAlertaApp,
    required String documento,
    required String nombres,
    required String nacionalidad,
    required double latitud,
    required double longitud,
  }) async {
    llamadas++;
    this.idPersona = idDgoPersonasAlertaApp;
    this.documento = documento;
    this.nombres = nombres;
    this.nacionalidad = nacionalidad;
    return RespuestaRegistroPersonalHotel(
      codeError: 0,
      msj: 'true',
      datos: PersonalHotelRegistrado(
        idDgoHuespedesApp: 31,
        idDgoPersonasAlertaApp: idDgoPersonasAlertaApp,
        idDgoHotelesApp: 3,
        codigoInstitucion: 'HOT-TEST',
        institucion: 'HOTEL DE PRUEBA',
        documento: documento,
        nombres: nombres,
        nacionalidad: nacionalidad,
        fechaRegistro: '2026-10-14 20:17:20',
      ),
    );
  }
}

class _Historial implements AlertasAtendidasPoliciaRepository {
  int llamadas = 0;
  Object? fallo;
  @override
  Future<AlertasAtendidasPolicia> consultarAlertasAtendidas({
    required String documento,
  }) async {
    llamadas++;
    expect(documento, documentoPrueba);
    if (fallo != null) throw fallo!;
    return AlertasAtendidasPolicia.fromJson({
      'alertasAtendidasPolicia': {
        'datos': [
          {
            'documento': documentoPrueba,
            'alertas': [
              {
                'idDgoAlertasMovilCiu': 45,
                'estadoAlerta': 'ATENDIDA',
                'procedimiento': 'Procedimiento registrado.',
              },
            ],
          },
        ],
      },
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const gpsChannel = MethodChannel('flutter.baseflow.com/geolocator');
  late _Permisos permisos;
  late _Validacion validacion;
  late _Crear crear;
  late _Atender atender;
  late _Bandeja bandeja;
  late _Historial historial;
  late _Generadas generadas;
  late _PersonalHotel personalHotel;
  late AlertasCiudadanasController controller;
  var permisoNotificaciones = true;

  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({'USER_CEDULA': documentoPrueba});
    PackageInfo.setMockInitialValues(
      appName: 'MI UPC',
      packageName: 'com.miupc',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    Get.put(LocalStoreProviderImpl());
    Get.put(LocalStoreImpl());
    permisos = _Permisos();
    validacion = _Validacion();
    crear = _Crear();
    atender = _Atender();
    bandeja = _Bandeja();
    historial = _Historial();
    generadas = _Generadas();
    personalHotel = _PersonalHotel();
    Get.put<PermisosMiUpcRepository>(permisos);
    Get.put<ValidacionCiudadanoAlertaRepository>(validacion);
    Get.put<CrearAlertaCiudadanaRepository>(crear);
    Get.put<AtenderAlertaCiudadanaRepository>(atender);
    Get.put<AlertasPoliciaRepository>(bandeja);
    Get.put<AlertasAtendidasPoliciaRepository>(historial);
    Get.put<AlertasGeneradasCiudadanoRepository>(generadas);
    Get.put<PersonalHotelRepository>(personalHotel);
    permisoNotificaciones = true;
    controller = AlertasCiudadanasController(
      verificarPermisoNotificaciones: () async => permisoNotificaciones,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          gpsChannel,
          (call) async => switch (call.method) {
            'checkPermission' => 2,
            'isLocationServiceEnabled' => true,
            'getCurrentPosition' => {
              'latitude': -0.18,
              'longitude': -78.46,
              'accuracy': 10.0,
            },
            _ => null,
          },
        );
  });
  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(gpsChannel, null);
    controller.onClose();
    Get.reset();
  });

  void habilitarCiudadano() {
    permisos.permiso = permisoPrueba(ciudadano: true);
    validacion.datos = [
      CiudadanoAlerta.fromJson({
        'documento': documentoPrueba,
        'idDgoPersonasAlertaApp': 17,
      }),
    ];
  }

  void habilitarHotel() {
    permisos.permiso = permisoPrueba(hotel: true);
    validacion.datos = [
      CiudadanoAlerta.fromJson({
        'documento': documentoPrueba,
        'idDgoPersonasAlertaApp': 17,
        'codigoInstitucion': 'HOT-88FDA816313A605972F68D7B',
        'institucion': 'HOTEL UNICORNIO',
        'tipoUsuario': 'PROPIETARIO',
        'idGenEstado': 1,
      }),
    ];
  }

  test(
    'consulta las alertas de su cédula y descarta filas de otras cuentas',
    () async {
      habilitarCiudadano();
      await controller.cargar();
      final propios = generadas.respuesta.datos.single;
      generadas.respuesta = ConsultaAlertasGeneradasCiudadano(
        codeError: 0,
        msj: '',
        datos: [
          propios,
          AlertasGeneradasCiudadano.fromJson({
            ...propios.toJson(),
            'documento': 'otra-cuenta',
            'totalAlertas': 99,
            'alertas': [
              {'idDgoAlertasMovilCiu': 99},
            ],
          }),
        ],
      );

      controller.observacion.text = 'Novedad pendiente de enviar';
      await controller.cargarAlertasGeneradas();
      expect(generadas.documentoConsultado, documentoPrueba);
      expect(controller.historialCiudadano, hasLength(1));
      expect(controller.alertasGeneradas.map((a) => a.idDgoAlertasMovilCiu), [
        5,
        4,
        3,
        2,
        1,
      ]);
      expect(controller.totalAlertasGeneradas, 5);
      expect(controller.totalGeneradasPendientes, 4);
      expect(controller.totalGeneradasEnAtencion, 0);
      expect(controller.totalGeneradasAtendidas, 1);
      expect(controller.errorAlertasGeneradas.value, isEmpty);
      expect(controller.observacion.text, 'Novedad pendiente de enviar');
      await controller.cargarAlertasGeneradas();
      expect(generadas.llamadas, 2);
    },
  );

  test('una cuenta hotel registra y lista personal confirmado', () async {
    habilitarHotel();
    await controller.cargar();

    expect(controller.esUsuarioHotel, isTrue);
    final registrado = await controller.registrarPersonalHotel(
      documento: 'AB123456',
      nombres: 'Juan Carlos Perez',
      nacionalidad: 'COLOMBIANA',
    );

    expect(registrado, isTrue);
    expect(personalHotel.llamadas, 1);
    expect(personalHotel.idPersona, 17);
    expect(personalHotel.documento, 'AB123456');
    expect(controller.personalHotelRegistrado, hasLength(1));
    expect(
      controller.personalHotelRegistrado.single.nombres,
      'Juan Carlos Perez',
    );
  });

  test('rechaza el registro si la cuenta no es un hotel', () async {
    habilitarCiudadano();
    await controller.cargar();

    final registrado = await controller.registrarPersonalHotel(
      documento: 'AB123456',
      nombres: 'Juan Carlos Perez',
      nacionalidad: 'COLOMBIANA',
    );

    expect(registrado, isFalse);
    expect(personalHotel.llamadas, 0);
    expect(controller.errorPersonalHotel.value, contains('permisos'));
  });

  testWidgets('el acceso de hotel abre el formulario y el listado', (
    tester,
  ) async {
    habilitarHotel();
    await controller.cargar();
    Get.put<AlertasCiudadanasController>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(home: AlertasCiudadanasPage()),
    );
    await tester.pumpAndSettle();

    final boton = find.byKey(const ValueKey('registrar-personal-hotel'));
    expect(boton, findsOneWidget);
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pumpAndSettle();
    expect(find.text('Número de documento'), findsOneWidget);
    expect(find.text('Nombres y apellidos'), findsOneWidget);
    expect(find.text('Nacionalidad'), findsOneWidget);
    expect(find.text('PERSONAL REGISTRADO EN ESTA SESIÓN'), findsOneWidget);
  });

  test(
    'evita consultas simultáneas y permite consultar nuevamente al finalizar',
    () async {
      habilitarCiudadano();
      await controller.cargar();
      final pendiente = Completer<ConsultaAlertasGeneradasCiudadano>();
      generadas.pendiente = pendiente;
      final primera = controller.cargarAlertasGeneradas();
      await controller.cargarAlertasGeneradas();
      await Future<void>.delayed(Duration.zero);
      expect(generadas.llamadas, 1);
      expect(controller.cargandoAlertasGeneradas.value, isTrue);
      pendiente.complete(generadas.respuesta);
      await primera;
      expect(controller.cargandoAlertasGeneradas.value, isFalse);
      generadas.pendiente = null;
      await controller.cargarAlertasGeneradas();
      expect(generadas.llamadas, 2);
    },
  );

  for (final cambio in ['cuenta', 'permiso', 'registro local']) {
    test('descarta una consulta en curso si cambia $cambio', () async {
      habilitarCiudadano();
      await controller.cargar();
      final pendiente = Completer<ConsultaAlertasGeneradasCiudadano>();
      generadas.pendiente = pendiente;
      final consulta = controller.cargarAlertasGeneradas();
      await Future<void>.delayed(Duration.zero);
      if (cambio == 'permiso') {
        permisos.permiso = permisoPrueba();
        await controller.cargar();
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('USER_CEDULA', 'otra-cuenta');
        if (cambio == 'cuenta') await controller.cargar();
      }
      pendiente.complete(generadas.respuesta);
      await consulta;
      expect(controller.historialCiudadano, isEmpty);
      expect(controller.alertasGeneradas, isEmpty);
      expect(controller.cargandoAlertasGeneradas.value, isFalse);
      if (cambio == 'registro local') {
        expect(
          controller.errorAlertasGeneradas.value,
          contains('registro cambió'),
        );
      }
    });
  }

  for (final falloRed in [false, true]) {
    test(
      'el historial ciudadano permite reintentar después de ${falloRed ? 'un fallo de conexión' : 'un error del servidor'}',
      () async {
        habilitarCiudadano();
        await controller.cargar();
        final valida = generadas.respuesta;
        await controller.cargarAlertasGeneradas();
        expect(controller.alertasGeneradas, hasLength(5));
        if (falloRed) {
          generadas.fallo = NetworkException.desde(
            const SocketException('Sin conexión'),
          );
        } else {
          generadas.respuesta = const ConsultaAlertasGeneradasCiudadano(
            codeError: 1,
            msj: 'Servicio no disponible',
            datos: [],
          );
        }
        await controller.cargarAlertasGeneradas();
        expect(controller.errorAlertasGeneradas.value, isNotEmpty);
        expect(controller.historialCiudadano, isEmpty);
        expect(controller.error.value, isEmpty);
        expect(controller.cargandoAlertasGeneradas.value, isFalse);
        generadas.fallo = null;
        generadas.respuesta = valida;
        await controller.cargarAlertasGeneradas();
        expect(controller.alertasGeneradas, hasLength(5));
        expect(controller.errorAlertasGeneradas.value, isEmpty);
      },
    );
  }

  test('un perfil policial no consulta el historial ciudadano', () async {
    await controller.cargar();
    await controller.cargarAlertasGeneradas();
    expect(generadas.llamadas, 0);
  });

  testWidgets(
    'el botón abre un diálogo con el resumen, detalle y atención sin borrar el formulario',
    (tester) async {
      habilitarCiudadano();
      await controller.cargar();
      Get.put<AlertasCiudadanasController>(controller);
      await tester.pumpWidget(
        const GetMaterialApp(home: AlertasCiudadanasPage()),
      );
      await tester.pumpAndSettle();
      controller.observacion.text = 'Descripción que sigue en el formulario';
      final pendiente = Completer<ConsultaAlertasGeneradasCiudadano>();
      generadas.pendiente = pendiente;
      final boton = find.byKey(
        const ValueKey('ver-alertas-generadas-ciudadano'),
      );
      await tester.ensureVisible(boton);
      await tester.tap(boton);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Consultando sus alertas…'), findsOneWidget);
      pendiente.complete(generadas.respuesta);
      await tester.pumpAndSettle();
      expect(find.text('Mis alertas'), findsOneWidget);
      expect(find.text('Total: 5'), findsOneWidget);
      expect(find.text('Pendientes: 4'), findsOneWidget);
      expect(find.text('En atención: 0'), findsOneWidget);
      expect(find.text('Atendidas: 1'), findsOneWidget);
      final lista = find.byKey(
        const ValueKey('lista-alertas-generadas-ciudadano'),
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('alerta-generada-1')),
        180,
        scrollable: find
            .descendant(of: lista, matching: find.byType(Scrollable))
            .first,
      );
      await tester.tap(find.text('Alerta N.º 1'));
      await tester.pumpAndSettle();
      expect(find.text('Servidor de prueba'), findsOneWidget);
      expect(find.text('Se verificó la novedad.'), findsOneWidget);
      expect(find.text('Local de prueba'), findsOneWidget);
      expect(find.text('ciudadano@example.com'), findsOneWidget);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(find.text('Mis alertas'), findsNothing);
      expect(
        controller.observacion.text,
        'Descripción que sigue en el formulario',
      );
      expect(generadas.documentoConsultado, documentoPrueba);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'el diálogo muestra errores, reintenta y distingue un historial vacío',
    (tester) async {
      habilitarCiudadano();
      await controller.cargar();
      Get.put<AlertasCiudadanasController>(controller);
      generadas.fallo = NetworkException.desde(
        const SocketException('Sin conexión'),
      );
      await tester.pumpWidget(
        const GetMaterialApp(home: AlertasCiudadanasPage()),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('ver-alertas-generadas-ciudadano')),
      );
      await tester.pumpAndSettle();
      expect(find.text('No se pudieron cargar sus alertas'), findsOneWidget);
      expect(find.text('Todavía no tiene alertas generadas'), findsNothing);
      generadas.fallo = null;
      generadas.respuesta = const ConsultaAlertasGeneradasCiudadano(
        codeError: 0,
        msj: 'noExiste',
        datos: [],
      );
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(find.text('Todavía no tiene alertas generadas'), findsOneWidget);
      expect(generadas.llamadas, 2);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(360, 640), const Size(640, 360)]) {
    testWidgets('el diálogo de alertas se adapta a $size con texto ampliado', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      habilitarCiudadano();
      await controller.cargar();
      Get.put<AlertasCiudadanasController>(controller);
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AlertasCiudadanasPage(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.4)),
            child: child!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boton = find.byKey(
        const ValueKey('ver-alertas-generadas-ciudadano'),
      );
      await tester.ensureVisible(boton);
      await tester.tap(boton);
      await tester.pumpAndSettle();
      expect(find.text('Mis alertas'), findsOneWidget);
      await tester.tap(find.text('Actualizar'));
      await tester.pumpAndSettle();
      expect(generadas.llamadas, 2);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'una alerta confirmada muestra AwesomeDialog y al aceptar vuelve al menú',
    (tester) async {
      habilitarCiudadano();
      crear.respuesta = const RespuestaAlertaCiudadana(
        codeError: 0,
        msj: '',
        datos: AlertaCiudadanaCreada(
          idDgoAlertasMovilCiu: 76,
          estadoAlerta: 'GENERADA',
          fechaAlerta: '',
          institucion: '',
          notificacionesEnviadas: 1,
        ),
      );
      await controller.cargar();
      Get.put<AlertasCiudadanasController>(controller);
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: AppRoutes.MENU,
          getPages: [
            GetPage(
              name: AppRoutes.MENU,
              page: () => const Scaffold(body: Text('Inicio MI UPC')),
            ),
            GetPage(
              name: AppRoutes.alertasCiudadanas,
              page: () => const AlertasCiudadanasPage(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      unawaited(Get.toNamed(AppRoutes.alertasCiudadanas));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Se solicita apoyo policial.',
      );
      await tester.ensureVisible(find.text('ENVIAR ALERTA'));
      await tester.tap(find.text('ENVIAR ALERTA'));
      await tester.pumpAndSettle();
      expect(crear.llamadas, 1);
      expect(find.text('Alerta generada correctamente'), findsOneWidget);
      expect(controller.resultado.value, contains('76'));
      expect(Get.currentRoute, AppRoutes.alertasCiudadanas);
      expect(controller.observacion.text, isEmpty);
      await tester.tap(find.text('VOLVER AL INICIO'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, AppRoutes.MENU);
      expect(find.text('Inicio MI UPC'), findsOneWidget);
      expect(find.text('Alerta generada correctamente'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'si el servidor no confirma la alerta conserva el formulario sin diálogo de éxito',
    (tester) async {
      habilitarCiudadano();
      await controller.cargar();
      Get.put<AlertasCiudadanasController>(controller);
      await tester.pumpWidget(
        const GetMaterialApp(home: AlertasCiudadanasPage()),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'Se solicita apoyo policial.',
      );
      await tester.ensureVisible(find.text('ENVIAR ALERTA'));
      await tester.tap(find.text('ENVIAR ALERTA'));
      await tester.pumpAndSettle();
      expect(crear.llamadas, 1);
      expect(
        controller.error.value,
        'No se pudo confirmar el envío de la alerta.',
      );
      expect(controller.observacion.text, 'Se solicita apoyo policial.');
      expect(find.text('Alerta generada correctamente'), findsNothing);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'el fallo DNS deja la consulta pendiente de verificar, no denegada',
    () async {
      permisos.fallo = NetworkException.desde(
        const SocketException("Failed host lookup: 'servidor-prueba'"),
      );
      await controller.cargar();
      expect(
        controller.estadoPermisos.value,
        EstadoConsultaPermisos.noDisponible,
      );
      expect(controller.permiso.value, isNull);
      expect(controller.error.value, contains('resolver'));
      expect(controller.cargando.value, isFalse);
      expect(bandeja.llamadas, 0);

      permisos.fallo = null;
      await controller.cargar();
      expect(
        controller.estadoPermisos.value,
        EstadoConsultaPermisos.confirmada,
      );
      expect(controller.esPolicia, isTrue);
      expect(controller.error.value, isEmpty);
    },
  );

  test('un fallo al actualizar conserva los datos de la misma cuenta, pero impide atender', () async {
    await controller.cargar();
    controller.seleccionar(controller.alertas.single);
    controller.procedimiento.text = 'Se verificó la novedad.';
    controller.verificacion.value = 'VERIFICADA';
    permisos.fallo = NetworkException.desde(
      const SocketException("Failed host lookup: 'servidor-prueba'"),
    );
    await controller.cargar();
    expect(controller.esPolicia, isTrue);
    expect(controller.alertas.map((item) => item.id), [51]);
    expect(controller.seleccionada.value?.id, 51);
    expect(controller.procedimiento.text, 'Se verificó la novedad.');
    expect(
      controller.estadoPermisos.value,
      EstadoConsultaPermisos.noDisponible,
    );
    await controller.atender();
    expect(atender.llamadas, 0);
    expect(controller.error.value, contains('resolver'));
  });

  test(
    'una revocación confirmada elimina el acceso y los datos policiales',
    () async {
      await controller.cargar();
      controller.seleccionar(controller.alertas.single);
      permisos.permiso = permisoPrueba();
      await controller.cargar();
      expect(
        controller.estadoPermisos.value,
        EstadoConsultaPermisos.confirmada,
      );
      expect(controller.esPolicia, isFalse);
      expect(controller.alertas, isEmpty);
      expect(controller.seleccionada.value, isNull);
    },
  );

  test('cambiar la cuenta no conserva el acceso anterior si falla la nueva consulta', () async {
    await controller.cargar();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('USER_CEDULA', 'otra-cuenta');
    permisos.fallo = const SocketException('Sin conexión');
    await controller.cargar();
    expect(controller.permiso.value, isNull);
    expect(controller.esPolicia, isFalse);
    expect(controller.alertas, isEmpty);
    expect(
      controller.estadoPermisos.value,
      EstadoConsultaPermisos.noDisponible,
    );
  });

  test(
    'cargas concurrentes esperan una sola consulta de permisos y bandeja',
    () async {
      permisos.espera = Completer<void>();
      final primera = controller.cargar();
      final segunda = controller.cargar();
      expect(identical(primera, segunda), isTrue);
      permisos.espera!.complete();
      await Future.wait([primera, segunda]);
      expect(permisos.llamadas, 1);
      expect(bandeja.llamadas, 1);
      expect(controller.esPolicia, isTrue);
    },
  );

  test(
    'volver de un diálogo no consulta otra vez; volver del fondo sí actualiza',
    () async {
      await controller.cargar();
      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(permisos.llamadas, 1);
      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await controller.cargar();
      expect(permisos.llamadas, 2);
    },
  );

  test(
    'una respuesta de error del servidor no se convierte en permiso denegado',
    () async {
      await controller.cargar();
      controller.seleccionar(controller.alertas.single);
      controller.procedimiento.text = 'Se verificó la novedad.';
      controller.verificacion.value = 'VERIFICADA';
      permisos.codeError = 1;
      await controller.atender();
      expect(atender.llamadas, 0);
      expect(controller.error.value, 'Servicio de permisos no disponible.');
      expect(controller.esPolicia, isTrue);
    },
  );

  testWidgets(
    'un fallo de consulta muestra reintento y no acceso restringido',
    (tester) async {
      permisos.fallo = NetworkException.desde(
        const SocketException("Failed host lookup: 'servidor-prueba'"),
      );
      await controller.cargar();
      Get.put<AlertasCiudadanasController>(controller);
      await tester.pumpWidget(
        const GetMaterialApp(home: AlertasCiudadanasPage()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Consulta no disponible'), findsOneWidget);
      expect(find.text('REINTENTAR CONSULTA'), findsOneWidget);
      expect(find.text('Acceso restringido'), findsNothing);
      expect(tester.takeException(), isNull);

      permisos.fallo = null;
      permisos.permiso = permisoPrueba();
      await tester.tap(find.text('REINTENTAR CONSULTA'));
      await tester.pumpAndSettle();
      expect(find.text('Acceso restringido'), findsOneWidget);
      expect(find.text('Consulta no disponible'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'usa el loading institucional mientras consulta permisos policiales',
    (tester) async {
      permisos.espera = Completer<void>();
      final request = controller.cargar();
      Get.put<AlertasCiudadanasController>(controller);

      await tester.pumpWidget(
        const GetMaterialApp(home: AlertasCiudadanasPage()),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('institutional-loading-icon')),
        findsOneWidget,
      );

      permisos.espera!.complete();
      await request;
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('institutional-loading-icon')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'muestra los permisos policiales aunque el endpoint de bandeja no exista',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      bandeja.fallo = const HttpException('404 Not Found: The requested URL');
      await controller.cargar();
      expect(controller.esPolicia, isTrue);
      expect(controller.bandejaDisponible.value, isFalse);
      expect(controller.permiso.value?.servidorPolicial?.unidad, 'DNTICS');

      Get.put<AlertasCiudadanasController>(controller);
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AlertasCiudadanasPage(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.4)),
            child: child!,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PERFIL DE SERVIDOR POLICIAL'), findsOneWidget);
      expect(find.text('DNTICS'), findsOneWidget);
      expect(find.text('samsung-SM-A705MN'), findsOneWidget);
      expect(find.text('Bandeja no disponible'), findsOneWidget);
      expect(find.text('No hay alertas pendientes'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'una alerta recibida muestra un diálogo con sus datos y deja la ficha abierta',
    (tester) async {
      await controller.cargar();
      await controller.prepararAlertaNotificada(51);
      Get.put<AlertasCiudadanasController>(controller);

      await tester.pumpWidget(
        const GetMaterialApp(home: AlertasCiudadanasPage()),
      );
      await tester.pumpAndSettle();

      expect(find.text('NUEVA ALERTA CIUDADANA'), findsOneWidget);
      expect(find.text('INCIDENTE  #51'), findsOneWidget);
      expect(find.text('Se requiere presencia policial.'), findsNWidgets(2));
      expect(find.text('ABRIR Y ATENDER ALERTA'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('ABRIR Y ATENDER ALERTA'));
      await tester.pumpAndSettle();
      expect(find.text('FICHA DE INCIDENTE'), findsOneWidget);
      expect(controller.seleccionada.value?.id, 51);
      expect(tester.takeException(), isNull);
    },
  );

  test('consulta la bandeja de su documento y el historial conserva las pendientes', () async {
    await controller.cargar();
    expect(controller.esPolicia, isTrue);
    expect(controller.alertas.map((item) => item.id), [51]);
    await controller.mostrarHistorial(true);
    expect(historial.llamadas, 1);
    expect(controller.alertas.map((item) => item.id), [51, 45]);
    expect(controller.alertas.last.procedimiento, 'Procedimiento registrado.');
  });

  testWidgets(
    'la página permite reintentar el historial policial tras un error',
    (tester) async {
      await controller.cargar();
      historial.fallo = const HttpException('Historial no disponible');
      Get.put<AlertasCiudadanasController>(controller);

      await tester.pumpWidget(
        const GetMaterialApp(home: AlertasCiudadanasPage()),
      );
      await tester.pumpAndSettle();

      final botonHistorial = find.text('Historial');
      await tester.ensureVisible(botonHistorial);
      await tester.tap(botonHistorial);
      await tester.pumpAndSettle();

      expect(controller.viendoHistorial.value, isTrue);
      expect(controller.cargandoHistorial.value, isFalse);
      expect(find.text('Reintentar historial'), findsOneWidget);
      expect(tester.takeException(), isNull);

      historial.fallo = null;
      await tester.ensureVisible(find.text('Reintentar historial'));
      await tester.tap(find.text('Reintentar historial'));
      await tester.pumpAndSettle();

      expect(historial.llamadas, 2);
      expect(controller.alertas.map((item) => item.id), [51, 45]);
      expect(controller.error.value, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('confirma la atención y regresa a la bandeja de pendientes', (
    tester,
  ) async {
    await controller.cargar();
    controller.seleccionar(controller.alertas.single);
    Get.put<AlertasCiudadanasController>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(home: AlertasCiudadanasPage()),
    );
    await tester.pumpAndSettle();
    controller.procedimiento.text = 'Se verificó la novedad.';
    controller.verificacion.value = 'VERIFICADA';
    await tester.pumpAndSettle();
    final registrar = find.text('CERRAR Y REGISTRAR PROCEDIMIENTO');
    await tester.ensureVisible(registrar);
    await tester.tap(registrar);
    await tester.pumpAndSettle();

    expect(atender.llamadas, 1);
    expect(controller.error.value, isEmpty);
    expect(find.text('Atención registrada'), findsOneWidget);
    expect(controller.seleccionada.value?.atendida, isTrue);

    await tester.tap(find.text('VER PENDIENTES'));
    await tester.pumpAndSettle();

    expect(controller.seleccionada.value, isNull);
    expect(controller.viendoHistorial.value, isFalse);
    expect(find.text('BANDEJA DE ALERTAS'), findsOneWidget);
    expect(find.text('Bandeja despejada'), findsOneWidget);
    expect(find.text('INCIDENTE  #51'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  test(
    'un ciudadano con ambos permisos ve primero la interfaz de envío',
    () async {
      permisos.permiso = permisoPrueba(ciudadano: true, policia: true);
      await controller.cargar();
      expect(controller.esCiudadano, isTrue);
      expect(controller.esPolicia, isFalse);
      expect(bandeja.llamadas, 0);
    },
  );

  test('permiso revocado impide enviar antes de validar al ciudadano o consultar GPS', () async {
    habilitarCiudadano();
    await controller.cargar();
    controller.observacion.text = 'Se requiere ayuda.';
    permisos.permiso = permisoPrueba();
    await controller.enviar();
    expect(controller.esCiudadano, isFalse);
    expect(validacion.llamadas, 1);
    expect(crear.llamadas, 0);
    expect(controller.error.value, contains('no tiene permiso'));
  });

  test(
    'permiso de notificaciones denegado impide enviar la SOS ALERTA',
    () async {
      habilitarCiudadano();
      await controller.cargar();
      controller.observacion.text = 'Se requiere ayuda.';
      permisoNotificaciones = false;

      await controller.enviar();

      expect(controller.error.value, contains('permisos de notificación'));
      expect(validacion.llamadas, 1);
      expect(crear.llamadas, 0);
    },
  );

  test('permiso revocado impide registrar el procedimiento', () async {
    await controller.cargar();
    controller.seleccionar(controller.alertas.single);
    controller.procedimiento.text = 'Se verificó la novedad.';
    controller.verificacion.value = 'VERIFICADA';
    permisos.permiso = permisoPrueba();
    await controller.atender();
    expect(atender.llamadas, 0);
    expect(controller.error.value, contains('no tiene permiso'));
  });

  test('solo actualiza una atención confirmada y evita reenviarla', () async {
    await controller.cargar();
    controller.seleccionar(controller.alertas.single);
    controller.procedimiento.text = 'Se verificó la novedad.';
    controller.verificacion.value = 'VERIFICADA';
    expect(await controller.atender(), isTrue);
    expect(controller.seleccionada.value?.atendida, isTrue);
    expect(controller.alertas.single.atendida, isTrue);
    expect(controller.alertas.single.fechaAtencion, '2026-10-11 19:30:00');
    expect(controller.viendoHistorial.value, isFalse);
    controller.mostrarPendientes();
    expect(controller.seleccionada.value, isNull);
    expect(controller.resultado.value, isEmpty);
    await controller.atender();
    expect(atender.llamadas, 1);
  });

  test(
    'una respuesta de otra alerta no marca la seleccionada como atendida',
    () async {
      await controller.cargar();
      controller.seleccionar(controller.alertas.single);
      controller.procedimiento.text = 'Se verificó la novedad.';
      controller.verificacion.value = 'VERIFICADA';
      atender.idConfirmado = 999;
      await controller.atender();
      expect(controller.seleccionada.value?.atendida, isFalse);
      expect(controller.resultado.value, isEmpty);
      expect(controller.error.value, contains('No se pudo confirmar'));
    },
  );
}
