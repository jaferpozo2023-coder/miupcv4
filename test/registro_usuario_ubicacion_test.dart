import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:pne/app/core/app_config.dart';
import 'package:pne/app/core/exceptions/ubicacion_exception.dart';
import 'package:pne/app/core/services/google_auth_service.dart';
import 'package:pne/app/data/models/models.dart';
import 'package:pne/app/data/providers/providers_impl.dart';
import 'package:pne/app/data/repository/data_repositories.dart';
import 'package:pne/app/domain/repositories/domain_repositories.dart';
import 'package:pne/app/presentation/gps/gps_impl_helper.dart';
import 'package:pne/app/presentation/modules/controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _GoogleStub implements GoogleAuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _VinculacionStub implements VinculacionDispositivoPolicialRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ValidacionStub implements ValidacionCiudadanoAlertaRepository {
  @override
  Future<ValidacionCiudadanoAlerta> validarCiudadanoAlerta({
    required String documento,
  }) async =>
      const ValidacionCiudadanoAlerta(codeError: 0, msj: 'noExiste', datos: []);
}

class _PermisosStub implements PermisosMiUpcRepository {
  @override
  Future<ConsultaPermisosMiUpc> consultarPermisosMiUpc({
    required String documento,
  }) async =>
      const ConsultaPermisosMiUpc(codeError: 0, msj: 'noExiste', datos: []);
}

class _GpsRegistro extends GpsController {
  int capturas = 0;
  late Completer<LatLng> posicion;
  @override
  Future<LatLng> obtenerPosicionActual() {
    capturas++;
    return posicion.future;
  }
}

class _RegistroStub implements RegistroUsuarioRepository {
  int llamadas = 0;
  LatLng? coordenadasEnviadas;
  @override
  Future<String> insertarUsuario({
    required String tipoUsuario,
    required double latitud,
    required double longitud,
    required String mail,
    required String fechaRegistro,
    required String tipoConexion,
    required String ssIDConexion,
    required String numCelular,
    required String versionAndroid,
    required String modeloCelular,
    required String cedula,
    required String ip,
    required String primerNombre,
    required String primerApellido,
    required String segundoApellido,
  }) async {
    llamadas++;
    coordenadasEnviadas = LatLng(latitud, longitud);
    return 'true|Usuario de prueba|101';
  }
}

void main() {
  late _RegistroStub registro;
  late _GpsRegistro gps;
  late RegistroUsuarioController controller;
  const networkChannel = MethodChannel(
    'dev.fluttercommunity.plus/network_info',
  );
  const connectivityChannel = MethodChannel(
    'dev.fluttercommunity.plus/connectivity',
  );
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          networkChannel,
          (call) async =>
              call.method == 'wifiIPAddress' ? '192.0.2.1' : 'Red de prueba',
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          connectivityChannel,
          (call) async => ['wifi'],
        );
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    AppConfig.ubicacion.value = const LatLng(0, 0);
    Get.put(LocalStoreProviderImpl());
    Get.put(LocalStoreImpl());
    registro = _RegistroStub();
    gps = _GpsRegistro();
    Get.put<RegistroUsuarioRepository>(registro);
    Get.put<GpsController>(gps);
    Get.put<GoogleAuthService>(_GoogleStub());
    Get.put<ValidacionCiudadanoAlertaRepository>(_ValidacionStub());
    Get.put<PermisosMiUpcRepository>(_PermisosStub());
    Get.put<VinculacionDispositivoPolicialRepository>(_VinculacionStub());
    controller = RegistroUsuarioController();
    controller.metodoRegistro.value = 'manual';
    controller.controllerPrimerNombre.text = 'Nombre';
    controller.controllerApellido1.text = 'Apellido';
    controller.controllerApellido2.text = 'Segundo';
    controller.controllerCedula.text = '0000000000';
    controller.controllerContacto.text = '0999999999';
    controller.controllerCorreo.text = 'usuario@example.com';
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(networkChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(connectivityChannel, null);
    controller.onClose();
    Get.reset();
  });

  Future<void> formulario(WidgetTester tester) => tester.pumpWidget(
    GetMaterialApp(
      home: Scaffold(
        body: Form(
          key: controller.formKeyNacional,
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );

  testWidgets(
    'abrir y guardar comparte la captura y el API espera una posición actual',
    (tester) async {
      await formulario(tester);
      expect(controller.formKeyNacional.currentState, isNotNull);
      await tester.runAsync(() async {
        gps.posicion = Completer<LatLng>();
        controller.onReady();
        expect(controller.capturandoUbicacion.value, isTrue);
        final envio = controller.registrarUsuario();
        await Future<void>.delayed(Duration.zero);
        expect(registro.llamadas, 0);
        expect(gps.capturas, 1);
        gps.posicion.complete(const LatLng(-0.1806532, -78.4678382));
        await envio;
      });
      await tester.pumpAndSettle();
      expect(registro.llamadas, 1);
      expect(
        registro.coordenadasEnviadas,
        const LatLng(-0.1806532, -78.4678382),
      );
      expect(controller.datosCargados.value, isTrue);
      expect(controller.peticionServerState.value, isFalse);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );

  testWidgets('sin ubicación válida no envía ni guarda al usuario', (
    tester,
  ) async {
    await formulario(tester);
    expect(controller.formKeyNacional.currentState, isNotNull);
    await tester.runAsync(() async {
      gps.posicion = Completer<LatLng>();
      final envio = controller.registrarUsuario();
      await Future<void>.delayed(Duration.zero);
      expect(gps.capturas, 1);
      gps.posicion.completeError(
        const UbicacionException('Permita el acceso a su ubicación.'),
      );
      await envio;
      expect(
        await Get.find<LocalStoreImpl>().getDatosUsuarioCompleto(),
        isNull,
      );
    });
    expect(registro.llamadas, 0);
    expect(controller.datosCargados.value, isFalse);
    expect(controller.mensajeUbicacion.value, contains('Permita el acceso'));
    expect(controller.peticionServerState.value, isFalse);
    expect(tester.takeException(), isNull);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
