part of '../controllers.dart';

class MenuPrincipalController extends GetxController
    with WidgetsBindingObserver {
  // ======================= ⚙️ ESTADOS ==========================
  final RxBool peticionServerState = false.obs;
  final Rx<Uint8List?> fotoPerfilBytes = Rx<Uint8List?>(null);
  final RxString userPref = ''.obs;
  final RxString metodoRegistro = ''.obs;
  final CheckInternetConnection internetChecker;

  MenuPrincipalController({CheckInternetConnection? internetChecker})
    : internetChecker = internetChecker ?? CheckInternetConnection();
  StreamSubscription<ConnectionStatus>? connectionSubscription;
  StreamSubscription<RemoteMessage>? _mensajeSubscription;
  StreamSubscription<RemoteMessage>? _abrirMensajeSubscription;
  bool _cargandoModulos = false;
  bool _respuestaRemotaModulosValida = false;
  bool _estuvoEnSegundoPlano = false;
  int _consultaPermisos = 0;
  final Rx<ConnectionStatus> status = ConnectionStatus.online.obs;
  final RxString correoUsuario = ''.obs;
  final RxString telefonoUsuario = ''.obs;
  final RxString documentoUsuario = ''.obs;
  // ======================= 🧩 DEPENDENCIAS ======================
  final GpsController gpsController = Get.find<GpsController>();
  final ModulosRepository _apiModulosRepository = Get.find<ModulosRepository>();
  final LocalStoreImpl _localStoreImpl = Get.find<LocalStoreImpl>();
  final PermisosMiUpcRepository _permisosMiUpc = Get.find();
  final mostrarModuloAlertas = false.obs;
  // ======================= 🗂️ DATOS ============================
  final RxList<Modulo> listaModulo = <Modulo>[].obs;
  final RxString errorCargaModulos = ''.obs;

  Rx<Modulo> datosModulos = Modulo(
    descripcionModulo: '',
    imgBase64: '',
    idGenEstado: 0,
    idUpcModulosMovil: 0,
    imagenModulo: '',
    ordenModulo: 0,
    tituloModulo: '',
  ).obs;

  Rx<GaleryCameraModel?> mGaleryCameraModel = Rx<GaleryCameraModel?>(null);

  String acuerdo = "";

  // =============================================================
  // 🔹 CICLO DE VIDA
  // =============================================================
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _cargarModulosOffline();
    cargarDatosUsuario();
    cargarFotoPerfil();
    connectionStatusController();
    unawaited(_initNotificaciones());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _estuvoEnSegundoPlano = true;
    } else if (state == AppLifecycleState.resumed && _estuvoEnSegundoPlano) {
      _estuvoEnSegundoPlano = false;
      unawaited(cargarDatosUsuario());
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _consultaPermisos++;
    connectionSubscription?.cancel();
    _mensajeSubscription?.cancel();
    _abrirMensajeSubscription?.cancel();
    internetChecker.close();
    super.onClose();
  }

  // =============================================================
  // 🧠 INICIALIZACIÓN Y CONFIGURACIÓN
  // =============================================================
  Future<void> cargarFotoPerfil() async {
    try {
      final bytes = await _localStoreImpl.getFoto();
      if (bytes != null) {
        debugPrint(
          "🖼️ Foto de perfil cargada correctamente (${bytes.length} bytes)",
        );
        fotoPerfilBytes.value = bytes;
      } else {
        fotoPerfilBytes.value = null;
        debugPrint("⚠️ No se encontró foto de perfil en almacenamiento local.");
      }
    } catch (e) {
      fotoPerfilBytes.value = null;
      debugPrint("❌ Error al cargar foto de perfil: $e");
    }
  }

  // =============================================================
  // 🌐 CONTROL DE CONEXIÓN
  // =============================================================
  void connectionStatusController() {
    if (connectionSubscription != null) return;

    connectionSubscription = internetChecker.internetStatus().listen((
      newStatus,
    ) {
      status.value = newStatus;
      if (newStatus == ConnectionStatus.online) {
        unawaited(cargarDatosLista());
        unawaited(actualizarPermisosAlertas());
      } else if (listaModulo.isEmpty) {
        unawaited(_cargarModulosOffline());
      }
    });
  }

  Future<void> _cargarModulosOffline() async {
    try {
      final list = await _localStoreImpl.getListModulos();
      if (!_respuestaRemotaModulosValida &&
          listaModulo.isEmpty &&
          list.isNotEmpty) {
        listaModulo.assignAll(_ordenarModulos(list));
        errorCargaModulos.value = '';
      } else if (listaModulo.isEmpty &&
          status.value == ConnectionStatus.offline) {
        errorCargaModulos.value =
            'No hay módulos guardados y no se detectó conexión a Internet.';
      }
    } catch (error, stackTrace) {
      debugPrint('Error al cargar los módulos guardados: $error\n$stackTrace');
      if (listaModulo.isEmpty) {
        errorCargaModulos.value =
            'No fue posible cargar los módulos guardados.';
      }
    }
  }

  // =============================================================
  // 📦 CARGA DE MÓDULOS
  // =============================================================
  Future<void> cargarDatosLista() async {
    if (_cargandoModulos) return;
    _cargandoModulos = true;

    try {
      peticionServerState(true);

      final lista = await _apiModulosRepository.buscaListaModulos();

      if (lista.isEmpty) {
        await _cargarModulosOffline();
        if (listaModulo.isEmpty) {
          errorCargaModulos.value =
              'No hay módulos disponibles en este momento.';
        }
        return;
      }

      _respuestaRemotaModulosValida = true;
      final listaFiltrada = _ordenarModulos(lista);

      listaModulo.assignAll(listaFiltrada);
      errorCargaModulos.value = listaFiltrada.isEmpty
          ? 'No hay módulos disponibles para esta cuenta.'
          : '';

      await _localStoreImpl.setDatosListaModulos(listModulos: listaFiltrada);
    } on ServerException catch (error) {
      debugPrint('No se pudieron actualizar los módulos: ${error.cause}');
      await _cargarModulosOffline();
      if (listaModulo.isEmpty) {
        errorCargaModulos.value = 'No se pudieron cargar los módulos. Comprueba tu conexión e inténtalo de nuevo.';
      }
    } catch (error, stackTrace) {
      debugPrint('Error inesperado al cargar los módulos: $error\n$stackTrace');
      await _cargarModulosOffline();
      if (listaModulo.isEmpty) {
        errorCargaModulos.value =
            'No se pudieron cargar los módulos. Inténtalo de nuevo.';
      }
    } finally {
      peticionServerState(false);
      _cargandoModulos = false;
    }
  }

  List<Modulo> _ordenarModulos(List<Modulo> modulos) {
    return modulos
        .where(
          (item) =>
              normalizarTituloModulo(item.tituloModulo) != 'ALERTAS TEMPRANAS',
        )
        .toList()
      ..sort((a, b) {
        final orden = a.ordenModulo.compareTo(b.ordenModulo);
        return orden != 0
            ? orden
            : a.idUpcModulosMovil.compareTo(b.idUpcModulosMovil);
      });
  }

  String normalizarTituloModulo(String texto) {
    return texto
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'[ÁÀÄ]'), 'A')
        .replaceAll(RegExp(r'[ÉÈË]'), 'E')
        .replaceAll(RegExp(r'[ÍÌÏ]'), 'I')
        .replaceAll(RegExp(r'[ÓÒÖ]'), 'O')
        .replaceAll(RegExp(r'[ÚÙÜ]'), 'U')
        .replaceAll('Ñ', 'N');
  }

  // =============================================================
  // 🧍‍♂️ PERMISOS Y ALERTAS
  // =============================================================
  Future<void> actualizarPermisosAlertas() async {
    final consulta = ++_consultaPermisos;
    final documento = documentoUsuario.value.trim();
    mostrarModuloAlertas.value = false;
    if (documento.isEmpty || isClosed) return;

    try {
      final respuesta = await _permisosMiUpc.consultarPermisosMiUpc(
        documento: documento,
      );
      if (isClosed ||
          consulta != _consultaPermisos ||
          documento != documentoUsuario.value.trim()) {
        return;
      }
      if (respuesta.codeError != 0) return;
      mostrarModuloAlertas.value = respuesta.datos.any(
        (permiso) =>
            permiso.documento == documento &&
            permiso.tienePermiso &&
            (permiso.permisoCiudadano || permiso.permisoPolicial),
      );
    } catch (error) {
      debugPrint('No se pudieron consultar los permisos del menú: $error');
    }
  }

  bool esModuloAlertas(Modulo modulo) {
    final titulo = normalizarTituloModulo(modulo.tituloModulo);
    return titulo.contains('DENUNCIAS') ||
        titulo.contains('ALERTAS CIUDADANAS');
  }

  Future<void> verificarGps({Modulo? modulo}) async {
    final gpsActivo = await gpsController.verificarGPS();
    if (!gpsActivo) return;

    gpsController.iniciarSeguimiento();

    if (AppConfig.ubicacion.value.latitude == 0.0) {
      DialogosAwesome.getInformation(
        descripcion: "Las coordenadas aún no están listas. Vuelva a intentar.",
      );
      return;
    }

    gpsController.cancelarSeguimiento();

    final data = {"id": "0", "imagen": modulo?.imgBase64 ?? ""};

    Get.toNamed(AppRoutes.MAPAUPC, parameters: data);
  }

  // =============================================================
  // 🔔 NOTIFICACIONES (FCM)
  // =============================================================
  Future<void> _initNotificaciones() async {
    if (Firebase.apps.isEmpty) return;
    try {
      _mensajeSubscription = FirebaseMessaging.onMessage.listen((message) {
        unawaited(_recibirAlerta(message));
      });
      _abrirMensajeSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
        message,
      ) {
        unawaited(_recibirAlerta(message));
      });
      final inicial = await FirebaseMessaging.instance.getInitialMessage();
      if (inicial != null) await _recibirAlerta(inicial);
    } catch (e) {
      debugPrint('No fue posible iniciar las notificaciones: $e');
    }
  }

  Future<void> _recibirAlerta(RemoteMessage message) async {
    try {
      final idAlerta = int.tryParse(
        message.data['idDgoAlertasMovilCiu']?.toString() ?? '',
      );
      if (idAlerta == null || idAlerta <= 0) return;

      if (Get.currentRoute == AppRoutes.alertasCiudadanas &&
          Get.isRegistered<AlertasCiudadanasController>()) {
        await Get.find<AlertasCiudadanasController>().prepararAlertaNotificada(
          idAlerta,
        );
      } else {
        unawaited(
          Get.toNamed(
            AppRoutes.alertasCiudadanas,
            parameters: {'alerta': idAlerta.toString(), 'notificacion': 'true'},
          ),
        );
      }
    } catch (e) {
      debugPrint('No se pudo procesar la notificación de alerta: $e');
    }
  }

  String obtenerSaludo() {
    final hora = DateTime.now().hour;

    if (hora >= 5 && hora < 12) {
      return 'Buenos días';
    } else if (hora >= 12 && hora < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  Map<String, dynamic> getMetodoAuthUI(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'google':
        return {
          'icono': Icons.g_mobiledata_rounded,
          'titulo': 'Autenticado con Google',
          'subtitulo': 'Acceso social seguro',
          'color': const Color(0xFFDB4437),
        };
      case 'facebook':
        return {
          'icono': Icons.facebook_rounded,
          'titulo': 'Autenticado con Facebook',
          'subtitulo': 'Acceso social vinculado',
          'color': const Color(0xFF1877F2),
        };
      default:
        return {
          'icono': Icons.badge_rounded,
          'titulo': 'Registro manual',
          'subtitulo': 'Perfil creado localmente',
          'color': const Color(0xFF00A896),
        };
    }
  }

  Future<void> cargarDatosUsuario() async {
    _consultaPermisos++;
    mostrarModuloAlertas.value = false;
    try {
      final data = await _localStoreImpl.getDatosUsuarioCompleto();
      final nombre = await _localStoreImpl.getUserName();
      userPref.value = nombre.trim();
      if (userPref.value.isEmpty && data != null) {
        userPref.value = [data['nombre'], data['apellido1'], data['apellido2']]
            .where(
              (value) => value != null && value.toString().trim().isNotEmpty,
            )
            .join(' ')
            .trim();
      }
      if (userPref.value.isEmpty) {
        userPref.value = (await _localStoreImpl.getDatosUsuario()).trim();
      }
      documentoUsuario.value = (data?['cedula'] ?? '').toString().trim();
      correoUsuario.value = (data?['correo'] ?? '').toString().trim();
      if (correoUsuario.value.isEmpty) {
        correoUsuario.value = (await _localStoreImpl.getDatosMail()).trim();
      }
      telefonoUsuario.value = (data?['telefono'] ?? '').toString().trim();
      if (telefonoUsuario.value.isEmpty) {
        telefonoUsuario.value = (await _localStoreImpl.getTelefono()).trim();
      }
      metodoRegistro.value = (await _localStoreImpl.getMetodoRegistro() ?? '')
          .trim();
      await actualizarPermisosAlertas();
    } catch (e) {
      debugPrint('No se pudieron cargar los datos del menú: $e');
    }
  }
}
