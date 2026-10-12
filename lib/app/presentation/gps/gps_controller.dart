part of 'gps_impl_helper.dart';

class GpsController extends GetxController {
  StreamSubscription<myGeolocator.Position>? positionSubscription;
  Rx<LatLng> ubicacion = new LatLng(0.0, 0.0).obs;
  var obteniendoUbicacion = false.obs;
  var ubicacionLista = false.obs;
  Future<LatLng>? _posicionActualPendiente;

  @override
  void onInit() {
    // TODO: implement onInit
    ubicacionLista.value = AppConfig.ubicacionLista.value;
    super.onInit();
  }

  /// Espera una lectura actual del GPS, incluyendo el permiso del sistema.
  Future<LatLng> obtenerPosicionActual() =>
      _posicionActualPendiente ??= _capturarPosicionActual().whenComplete(
        () => _posicionActualPendiente = null,
      );

  Future<LatLng> _capturarPosicionActual() async {
    obteniendoUbicacion.value = true;
    ubicacionLista.value = false;
    AppConfig.ubicacionLista.value = false;
    try {
      var permiso = await myGeolocator.Geolocator.checkPermission();
      if (permiso == myGeolocator.LocationPermission.denied) {
        permiso = await myGeolocator.Geolocator.requestPermission();
      }
      if (permiso == myGeolocator.LocationPermission.deniedForever) {
        throw const UbicacionException(
          'Active el permiso de ubicación de MI UPC en los ajustes del teléfono.',
          accion: AccionUbicacion.ajustesAplicacion,
        );
      }
      if (permiso != myGeolocator.LocationPermission.whileInUse &&
          permiso != myGeolocator.LocationPermission.always) {
        throw const UbicacionException(
          'Permita el acceso a su ubicación para completar el registro.',
        );
      }
      if (!await myGeolocator.Geolocator.isLocationServiceEnabled()) {
        throw const UbicacionException(
          'Active la ubicación del teléfono para obtener su posición actual.',
          accion: AccionUbicacion.ajustesUbicacion,
        );
      }
      final posicion = await myGeolocator.Geolocator.getCurrentPosition(
        locationSettings: const myGeolocator.LocationSettings(
          accuracy: myGeolocator.LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!posicion.latitude.isFinite ||
          !posicion.longitude.isFinite ||
          posicion.latitude.abs() > 90 ||
          posicion.longitude.abs() > 180 ||
          (posicion.latitude == 0 && posicion.longitude == 0)) {
        throw const UbicacionException(
          'No se obtuvo una posición válida. Vuelva a intentar la captura de ubicación.',
        );
      }
      final coordenadas = LatLng(posicion.latitude, posicion.longitude);
      ubicacion.value = coordenadas;
      AppConfig.ubicacion.value = coordenadas;
      ubicacionLista.value = true;
      AppConfig.ubicacionLista.value = true;
      return coordenadas;
    } on TimeoutException {
      throw const UbicacionException(
        'No se pudo obtener su ubicación a tiempo. Acérquese a un espacio abierto y vuelva a intentar.',
      );
    } finally {
      obteniendoUbicacion.value = false;
    }
  }

  Future<bool> verificarGPS() async {
    // PermisoGPS verifica si el usuario ya dio permisos
    bool permisoGPS = await Permission.location.isGranted;
    //True el usuario dio permisos

    if (!permisoGPS) {
      String msj =
          "Necesitamos acceder a la ubicación del Dispositivo.\n\n Para que puedas ver las Unidades de Policia Comunitaria";
      DialogosAwesome.getWarning(
        descripcion: msj,
        btnOkOnPress: () async {
          permisoGPS = await checkGpsPermisoStatus2();
          Get.back();
        },
      );
    }

    //verificamos que el GPS del dispositivo este encendido
    final gpsActivo = await myGeolocator.Geolocator.isLocationServiceEnabled();
    if (!gpsActivo) {
      String msj =
          "Necesitamos acceder a la ubicación del Dispositivo.\n\n Para que puedas ver las Unidades de Policia Comunitaria";
      DialogosAwesome.getWarning(
        descripcion: msj,
        btnOkOnPress: () {
          Get.back();
        },
      );
    }

    if (permisoGPS && gpsActivo) {
      return true;
    } else {
      return false;
    }
  }

  //Verifica si tiene los Permisos y el GPS Activo
  Future<String> checkPermisosGpsActivated() async {
    // PermisoGPS verifica si el usuario ya dio permisos
    final permisoGPS = await Permission.location.isGranted;

    // GPS está activo verifica si el gps del dispositivo se encuentra activo
    final gpsActivo = await myGeolocator.Geolocator.isLocationServiceEnabled();

    if (permisoGPS && gpsActivo) {
      DialogosAwesome.getError(descripcion: "todo ok");
      return "true";
    } else if (!permisoGPS) {
      String msj =
          "Necesitamos acceder a la ubicación del Dispositivo.\n\n Para que puedas ver las Unidades de Policia Comunitaria";
      DialogosAwesome.getWarning(
        descripcion: msj,
        btnOkOnPress: () {
          checkGpsPermisoStatus("aaa");
          Get.back();
        },
      );
      return msj;
    } else {
      String msj =
          "Necesitamos acceder a la ubicación del Dispositivo.\n\n Para que puedas ver las Unidades de Policia Comunitaria";
      DialogosAwesome.getError(descripcion: msj);
      return msj;
    }
  }

  Future<bool> checkGpsPermisoStatus2() async {
    final status = await Permission.location.request();

    bool result = false;
    switch (status) {
      case PermissionStatus.granted:
        // GPS está activo verifica si el gps del dispositivo se encuentra activo
        final gpsActivo =
            await myGeolocator.Geolocator.isLocationServiceEnabled();
        result = true;

        break;

      case PermissionStatus.limited:
      //indeterminado

      case PermissionStatus.denied:
      //denegado

      case PermissionStatus.restricted:
      //restringida

      case PermissionStatus.permanentlyDenied:
        //permisos denegas por completo
        //Redirecciona al usuario para que de manuera manual asigne los permisos
        result = await openAppSettings();
      case PermissionStatus.provisional:
      // TODO: Handle this case.
    }

    return result;
  }

  Future checkGpsPermisoStatus(String pantalla) async {
    final status = await Permission.location.request();

    switch (status) {
      case PermissionStatus.granted:
        // GPS está activo verifica si el gps del dispositivo se encuentra activo
        final gpsActivo =
            await myGeolocator.Geolocator.isLocationServiceEnabled();
        print(status);
        print(gpsActivo);
        if (gpsActivo) {
          //aceptado
          Get.offAllNamed(pantalla);
        }

        break;

      case PermissionStatus.limited:
      //indeterminado

      case PermissionStatus.denied:
      //denegado

      case PermissionStatus.restricted:
      //restringida

      case PermissionStatus.permanentlyDenied:
        //permisos denegas por completo
        //Redirecciona al usuario para que de manuera manual asigne los permisos
        openAppSettings();
      case PermissionStatus.provisional:
      // TODO: Handle this case.
    }
  }

  Future iniciarSeguimiento() async {
    AppConfig.ubicacionLista.value = false;
    print("iniciarSeguimiento ${ubicacion.value.longitude}");
    if (this.positionSubscription == null) {
      obteniendoUbicacion(true);
      print("iniciarSeguimiento");
      final positionStream = myGeolocator.Geolocator.getPositionStream(
        locationSettings: MyGps.getConfig,
      );
      this.positionSubscription = positionStream
          .handleError((error) {
            print("tcambia ubicacion ${error}");
            this.positionSubscription!.cancel();
            this.positionSubscription = null;
            obteniendoUbicacion(false);
          })
          .listen((position) {
            AppConfig.ubicacion.value = LatLng(
              position.latitude,
              position.longitude,
            );
            AppConfig.ubicacionLista.value = true;
            ubicacion.value = LatLng(position.latitude, position.longitude);
            print(
              "cambia ubicacion ${ubicacion.value.latitude}, ${ubicacion.value.longitude}",
            );
            ubicacionLista.value = true;
            ubicacionLista.refresh();
            ubicacion.refresh();
            obteniendoUbicacion(false);
          });
    }
  }

  void cancelarSeguimiento() {
    this.positionSubscription?.cancel();
    this.positionSubscription = null;
  }
}
