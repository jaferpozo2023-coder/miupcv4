part of '../controllers.dart';

class MenuPrincipalController extends GetxController
    with WidgetsBindingObserver {
  static const String _prefPermisoAlertasBase =
      'mi_upc_permiso_alertas_ciudadanas_v1';

  final RxBool peticionServerState = false.obs;
  final Rx<Uint8List?> fotoPerfilBytes = Rx<Uint8List?>(null);
  final RxString userPref = ''.obs;
  final RxString metodoRegistro = ''.obs;
  final RxString correoUsuario = ''.obs;
  final RxString telefonoUsuario = ''.obs;
  final RxString documentoUsuario = ''.obs;
  final Rx<ConnectionStatus> status = ConnectionStatus.online.obs;
  final RxList<Modulo> listaModulo = <Modulo>[].obs;
  final RxString errorCargaModulos = ''.obs;
  final RxBool mostrarModuloAlertas = false.obs;
  final RxBool permisoAlertasInicializado = false.obs;
  final RxBool permisoNotificacionesInicializado = false.obs;
  final RxBool permisoNotificacionesActivo = false.obs;
  final CheckInternetConnection internetChecker;
  final GpsController gpsController = Get.find<GpsController>();
  final ModulosRepository _apiModulosRepository = Get.find<ModulosRepository>();
  final LocalStoreImpl _localStoreImpl = Get.find<LocalStoreImpl>();
  final PermisosMiUpcRepository _permisosMiUpc = Get.find();
  StreamSubscription<ConnectionStatus>? connectionSubscription;
  late final Future<void> _cargaLocalInicial;
  bool _cargandoModulos = false;
  bool _recargarModulosPendiente = false;
  bool _respuestaRemotaModulosValida = false;
  bool _estuvoEnSegundoPlano = false;
  ConnectionStatus? _ultimoEstadoConexion;
  int _consultaPermisos = 0;
  String _documentoPermisos = '';

  MenuPrincipalController({CheckInternetConnection? internetChecker})
    : internetChecker = internetChecker ?? CheckInternetConnection();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _cargaLocalInicial = _inicializarDatosLocales();
    unawaited(cargarFotoPerfil());
    connectionStatusController();
    unawaited(_initNotificaciones());
  }

  Future<void> _inicializarDatosLocales() async {
    // Primero recuperamos usuario + permiso cacheado y después publicamos
    // los módulos locales. Así evitamos el efecto visual 4 -> 5.
    await cargarDatosUsuario();
    if (isClosed) return;
    await _cargarModulosOffline();
  }

  @override
  void onReady() {
    super.onReady();
    PushNotificationService.instance.markNavigationReady();
    unawaited(_inicializarModulos());
  }

  Future<void> _inicializarModulos() async {
    await _cargaLocalInicial;
    if (isClosed) return;
    await cargarDatosLista();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _estuvoEnSegundoPlano = true;
      return;
    }
    if (state == AppLifecycleState.resumed && _estuvoEnSegundoPlano) {
      _estuvoEnSegundoPlano = false;
      unawaited(cargarDatosUsuario());
      unawaited(actualizarPermisoNotificaciones());
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _consultaPermisos++;
    connectionSubscription?.cancel();
    internetChecker.close();
    super.onClose();
  }

  Future<void> cargarFotoPerfil() async {
    try {
      fotoPerfilBytes.value = await _localStoreImpl.getFoto();
    } catch (e) {
      fotoPerfilBytes.value = null;
      debugPrint('Error cargando foto de perfil: $e');
    }
  }

  void connectionStatusController() {
    if (connectionSubscription != null) return;
    connectionSubscription = internetChecker.internetStatus().listen((
      newStatus,
    ) {
      final estadoAnterior = _ultimoEstadoConexion;
      _ultimoEstadoConexion = newStatus;
      status.value = newStatus;
      if (newStatus == ConnectionStatus.offline) {
        if (listaModulo.isEmpty) unawaited(_cargarModulosOffline());
        return;
      }
      if (estadoAnterior == ConnectionStatus.offline) {
        unawaited(cargarDatosLista(forzar: true));
        unawaited(actualizarPermisosAlertas());
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
      debugPrint('Error al cargar módulos guardados: $error\n$stackTrace');
      if (listaModulo.isEmpty)
        errorCargaModulos.value =
            'No fue posible cargar los módulos guardados.';
    }
  }

  Future<void> cargarDatosLista({bool forzar = false}) async {
    if (_cargandoModulos) {
      if (forzar) _recargarModulosPendiente = true;
      return;
    }
    _cargandoModulos = true;
    final mostrarCargaGlobal = listaModulo.isEmpty;
    if (mostrarCargaGlobal) {
      errorCargaModulos.value = '';
      peticionServerState.value = true;
    }
    try {
      final lista = await _apiModulosRepository.buscaListaModulos();
      if (lista.isEmpty) {
        if (listaModulo.isEmpty) await _cargarModulosOffline();
        if (listaModulo.isEmpty)
          errorCargaModulos.value =
              'No hay módulos disponibles en este momento.';
        return;
      }
      _respuestaRemotaModulosValida = true;
      final listaFiltrada = _ordenarModulos(lista);
      listaModulo.assignAll(listaFiltrada);
      errorCargaModulos.value = listaFiltrada.isEmpty
          ? 'No hay módulos disponibles para esta cuenta.'
          : '';
      unawaited(_guardarModulosCache(listaFiltrada));
    } on ServerException catch (error) {
      debugPrint('No se pudieron actualizar los módulos: ${error.cause}');
      if (listaModulo.isEmpty) await _cargarModulosOffline();
      if (listaModulo.isEmpty) errorCargaModulos.value = 'No se pudieron cargar los módulos. Comprueba tu conexión e inténtalo de nuevo.';
    } catch (error, stackTrace) {
      debugPrint('Error inesperado al cargar módulos: $error\n$stackTrace');
      if (listaModulo.isEmpty) await _cargarModulosOffline();
      if (listaModulo.isEmpty)
        errorCargaModulos.value =
            'No se pudieron cargar los módulos. Inténtalo de nuevo.';
    } finally {
      if (mostrarCargaGlobal) peticionServerState.value = false;
      _cargandoModulos = false;
      if (_recargarModulosPendiente && !isClosed) {
        _recargarModulosPendiente = false;
        unawaited(cargarDatosLista());
      }
    }
  }

  Future<void> _guardarModulosCache(List<Modulo> modulos) async {
    try {
      await _localStoreImpl.setDatosListaModulos(listModulos: modulos);
    } catch (e) {
      debugPrint('No se pudo actualizar la caché de módulos: $e');
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

  String _keyPermisoAlertas(String documento) =>
      '${_prefPermisoAlertasBase}_${documento.trim()}';

  void _sincronizarDocumentoPermisos(String documento) {
    if (documento == _documentoPermisos) return;
    _consultaPermisos++;
    _documentoPermisos = documento;
    // Al cambiar de ciudadano no conservamos visualmente el permiso anterior.
    // Inmediatamente después se recupera la caché de la nueva cédula.
    mostrarModuloAlertas.value = false;
    permisoAlertasInicializado.value = false;
  }

  Future<void> _cargarPermisoAlertasLocal(String documento) async {
    final doc = documento.trim();
    if (doc.isEmpty) {
      mostrarModuloAlertas.value = false;
      permisoAlertasInicializado.value = true;
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _keyPermisoAlertas(doc);
      final existeCache = prefs.containsKey(key);
      final permitido = existeCache ? (prefs.getBool(key) ?? false) : false;
      if (documentoUsuario.value.trim().isNotEmpty &&
          doc != documentoUsuario.value.trim())
        return;
      mostrarModuloAlertas.value = permitido;
      permisoAlertasInicializado.value = existeCache;
      debugPrint(
        'MENÚ -> permiso alertas local [$doc]: $permitido / cache: $existeCache',
      );
    } catch (e) {
      mostrarModuloAlertas.value = false;
      permisoAlertasInicializado.value = false;
      debugPrint('MENÚ -> error leyendo permiso local: $e');
    }
  }

  Future<void> _guardarPermisoAlertasLocal(
    String documento,
    bool permitido,
  ) async {
    final doc = documento.trim();
    if (doc.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyPermisoAlertas(doc), permitido);
      debugPrint('MENÚ -> permiso alertas guardado [$doc]: $permitido');
    } catch (e) {
      debugPrint('MENÚ -> error guardando permiso local: $e');
    }
  }

  Future<void> actualizarPermisosAlertas() async {
    if (isClosed) return;
    final documento = documentoUsuario.value.trim();
    _sincronizarDocumentoPermisos(documento);
    final consulta = ++_consultaPermisos;
    if (documento.isEmpty) {
      mostrarModuloAlertas.value = false;
      permisoAlertasInicializado.value = true;
      return;
    }
    try {
      debugPrint('MENÚ -> consultando permiso remoto para $documento');
      final respuesta = await _permisosMiUpc.consultarPermisosMiUpc(
        documento: documento,
      );
      if (isClosed ||
          consulta != _consultaPermisos ||
          documento != documentoUsuario.value.trim())
        return;
      // Si el servicio responde con error conservamos el último permiso cacheado.
      if (respuesta.codeError != 0) {
        debugPrint(
          'MENÚ -> consulta de permisos respondió código ${respuesta.codeError}',
        );
        permisoAlertasInicializado.value = true;
        return;
      }
      final permitido = respuesta.datos.any(
        (permiso) =>
            permiso.documento == documento &&
            permiso.tienePermiso &&
            (permiso.permisoCiudadano || permiso.permisoPolicial),
      );
      mostrarModuloAlertas.value = permitido;
      permisoAlertasInicializado.value = true;
      unawaited(_guardarPermisoAlertasLocal(documento, permitido));
      debugPrint('MENÚ -> permiso alertas servidor [$documento]: $permitido');
    } catch (error) {
      // Ante una falla de red mantenemos la última validación local.
      permisoAlertasInicializado.value = true;
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
        descripcion: 'Las coordenadas aún no están listas. Vuelva a intentar.',
      );
      return;
    }
    gpsController.cancelarSeguimiento();
    Get.toNamed(
      AppRoutes.MAPAUPC,
      parameters: {'id': '0', 'imagen': modulo?.imgBase64 ?? ''},
    );
  }

  Future<void> _initNotificaciones() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await PushNotificationService.instance.requestPermissionAndSubscribe();
      }
    } catch (error) {
      debugPrint('No fue posible autorizar las notificaciones: $error');
    } finally {
      await actualizarPermisoNotificaciones();
    }
  }

  bool get puedeMostrarModuloAlertas =>
      mostrarModuloAlertas.value &&
      permisoAlertasInicializado.value &&
      permisoNotificacionesInicializado.value &&
      permisoNotificacionesActivo.value;

  Future<bool> actualizarPermisoNotificaciones() async {
    if (isClosed) return false;
    if (Firebase.apps.isEmpty) {
      permisoNotificacionesActivo.value = false;
      permisoNotificacionesInicializado.value = true;
      return false;
    }

    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      final activo =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!isClosed) {
        permisoNotificacionesActivo.value = activo;
        permisoNotificacionesInicializado.value = true;
      }
      return activo;
    } catch (error, stackTrace) {
      debugPrint(
        'No fue posible verificar el permiso de notificaciones: $error\n$stackTrace',
      );
      if (!isClosed) {
        permisoNotificacionesActivo.value = false;
        permisoNotificacionesInicializado.value = true;
      }
      return false;
    }
  }

  String obtenerSaludo() {
    final hora = DateTime.now().hour;
    if (hora >= 5 && hora < 12) return 'Buenos días';
    if (hora >= 12 && hora < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  Map<String, dynamic> getMetodoAuthUI(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'google':
        return {
          'icono': Icons.g_mobiledata_rounded,
          'titulo': 'Google',
          'subtitulo': 'Acceso seguro',
          'color': const Color(0xFFDB4437),
        };
      case 'facebook':
        return {
          'icono': Icons.facebook_rounded,
          'titulo': 'Facebook',
          'subtitulo': 'Acceso vinculado',
          'color': const Color(0xFF1877F2),
        };
      default:
        return {
          'icono': Icons.badge_rounded,
          'titulo': 'Datos de Usuario',
          'subtitulo': 'Identidad registrada',
          'color': const Color(0xFF00B8A9),
        };
    }
  }

  Future<void> cargarDatosUsuario() async {
    try {
      final resultados = await Future.wait<dynamic>([
        _localStoreImpl.getDatosUsuarioCompleto(),
        _localStoreImpl.getUserName(),
        _localStoreImpl.getDatosUsuario(),
        _localStoreImpl.getDatosMail(),
        _localStoreImpl.getTelefono(),
        _localStoreImpl.getMetodoRegistro(),
      ]);
      if (isClosed) return;
      final data = resultados[0] as Map?;
      final nombreGuardado = (resultados[1] ?? '').toString().trim();
      final nombreAlterno = (resultados[2] ?? '').toString().trim();
      final mailAlterno = (resultados[3] ?? '').toString().trim();
      final telefonoAlterno = (resultados[4] ?? '').toString().trim();
      final metodo = (resultados[5] ?? '').toString().trim();
      final documento = (data?['cedula'] ?? '').toString().trim();

      _sincronizarDocumentoPermisos(documento);
      documentoUsuario.value = documento;

      // Recuperamos el último permiso confirmado para ESTA cédula antes
      // de que la lista local de módulos sea publicada en pantalla.
      await _cargarPermisoAlertasLocal(documento);
      if (isClosed) return;

      userPref.value = nombreGuardado;
      if (userPref.value.isEmpty && data != null) {
        userPref.value = [data['nombre'], data['apellido1'], data['apellido2']]
            .where(
              (value) => value != null && value.toString().trim().isNotEmpty,
            )
            .join(' ')
            .trim();
      }
      if (userPref.value.isEmpty) userPref.value = nombreAlterno;
      correoUsuario.value = (data?['correo'] ?? '').toString().trim();
      if (correoUsuario.value.isEmpty) correoUsuario.value = mailAlterno;
      telefonoUsuario.value = (data?['telefono'] ?? '').toString().trim();
      if (telefonoUsuario.value.isEmpty) {
        telefonoUsuario.value = telefonoAlterno;
      }
      metodoRegistro.value = metodo;

      // La validación remota se realiza en segundo plano y actualiza la caché.
      unawaited(actualizarPermisosAlertas());
    } catch (e, stackTrace) {
      permisoAlertasInicializado.value = true;
      debugPrint('No se pudieron cargar los datos del menú: $e\n$stackTrace');
    }
  }
}
