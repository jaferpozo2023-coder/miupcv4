import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:pne/app/core/app_config.dart';
import 'package:pne/app/core/exceptions/ubicacion_exception.dart';
import 'package:pne/app/presentation/gps/gps_impl_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/geolocator');
  late GpsController gps;
  late List<String> llamadas;
  late int permiso;
  late int permisoSolicitado;
  late bool habilitado;
  late Map<String, dynamic> posicion;
  Completer<Map<String, dynamic>>? posicionPendiente;

  setUp(() {
    Get.testMode = true;
    AppConfig.ubicacion.value = const LatLng(0, 0);
    AppConfig.ubicacionLista.value = false;
    gps = Get.put(GpsController());
    llamadas = [];
    permiso = 0;
    permisoSolicitado = 2;
    habilitado = true;
    posicionPendiente = null;
    posicion = {
      'latitude': -0.1806532,
      'longitude': -78.4678382,
      'accuracy': 10.0,
    };
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          llamadas.add(call.method);
          return switch (call.method) {
            'checkPermission' => permiso,
            'requestPermission' => permisoSolicitado,
            'isLocationServiceEnabled' => habilitado,
            'getCurrentPosition' =>
              posicionPendiente == null
                  ? posicion
                  : await posicionPendiente!.future,
            _ => null,
          };
        });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    Get.reset();
  });

  test(
    'solicita el permiso y espera la posición antes de marcarla lista',
    () async {
      expect(gps.ubicacionLista.value, isFalse);
      final resultado = await gps.obtenerPosicionActual();
      expect(llamadas, [
        'checkPermission',
        'requestPermission',
        'isLocationServiceEnabled',
        'getCurrentPosition',
      ]);
      expect(resultado, const LatLng(-0.1806532, -78.4678382));
      expect(AppConfig.ubicacion.value, resultado);
      expect(gps.ubicacionLista.value, isTrue);
      expect(gps.obteniendoUbicacion.value, isFalse);
    },
  );

  test(
    'el permiso denegado no captura ni conserva una posición como válida',
    () async {
      permisoSolicitado = 0;
      await expectLater(
        gps.obtenerPosicionActual(),
        throwsA(isA<UbicacionException>()),
      );
      expect(llamadas, ['checkPermission', 'requestPermission']);
      expect(AppConfig.ubicacionLista.value, isFalse);
    },
  );

  test(
    'el permiso bloqueado indica abrir los ajustes de la aplicación',
    () async {
      permiso = 1;
      await expectLater(
        gps.obtenerPosicionActual(),
        throwsA(
          isA<UbicacionException>().having(
            (e) => e.accion,
            'accion',
            AccionUbicacion.ajustesAplicacion,
          ),
        ),
      );
      expect(llamadas, ['checkPermission']);
    },
  );

  test('el GPS apagado indica activar la ubicación', () async {
    permiso = 2;
    habilitado = false;
    await expectLater(
      gps.obtenerPosicionActual(),
      throwsA(
        isA<UbicacionException>().having(
          (e) => e.accion,
          'accion',
          AccionUbicacion.ajustesUbicacion,
        ),
      ),
    );
    expect(llamadas, isNot(contains('getCurrentPosition')));
  });

  test('descarta cero cero y permite una latitud en el ecuador', () async {
    permiso = 2;
    posicion = {'latitude': 0.0, 'longitude': 0.0};
    await expectLater(
      gps.obtenerPosicionActual(),
      throwsA(isA<UbicacionException>()),
    );
    expect(gps.ubicacionLista.value, isFalse);
    posicion = {'latitude': 0.0, 'longitude': -78.46};
    expect(await gps.obtenerPosicionActual(), const LatLng(0, -78.46));
  });

  test('las llamadas simultáneas comparten la captura y la siguiente obtiene una lectura nueva', () async {
    permiso = 2;
    posicionPendiente = Completer();
    final primera = gps.obtenerPosicionActual();
    final segunda = gps.obtenerPosicionActual();
    expect(identical(primera, segunda), isTrue);
    posicionPendiente!.complete(posicion);
    await primera;
    await segunda;
    posicionPendiente = null;
    posicion = {'latitude': -0.19, 'longitude': -78.48};
    expect(await gps.obtenerPosicionActual(), const LatLng(-0.19, -78.48));
    expect(llamadas.where((item) => item == 'getCurrentPosition').length, 2);
  });

  testWidgets('un GPS que no responde termina con una acción de reintento', (
    tester,
  ) async {
    permiso = 2;
    posicionPendiente = Completer();
    final resultado = gps.obtenerPosicionActual();
    final comprobacion = expectLater(
      resultado,
      throwsA(
        isA<UbicacionException>().having(
          (e) => e.mensaje,
          'mensaje',
          contains('a tiempo'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 21));
    await comprobacion;
    expect(gps.obteniendoUbicacion.value, isFalse);
    expect(AppConfig.ubicacionLista.value, isFalse);
    posicionPendiente!.complete(posicion);
    await tester.pump();
  });
}
