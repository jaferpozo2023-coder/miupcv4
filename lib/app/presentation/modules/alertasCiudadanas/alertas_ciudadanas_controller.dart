import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/exceptions/exceptions.dart';
import '../../../data/models/detalle_alerta_ciudadana_model.dart';
import '../../../data/models/alertas_generadas_ciudadano_model.dart';
import '../../../data/models/permisos_mi_upc_model.dart';
import '../../../data/models/personal_hotel_model.dart';
import '../../../data/models/validacion_ciudadano_alerta_model.dart';
import '../../../data/repository/data_repositories.dart';
import '../../../domain/repositories/domain_repositories.dart';

enum EstadoConsultaPermisos { pendiente, confirmada, noDisponible, sinRegistro }

class AlertasCiudadanasController extends GetxController
    with WidgetsBindingObserver {
  AlertasCiudadanasController({
    Future<bool> Function()? verificarPermisoNotificaciones,
  }) : _verificarPermisoNotificaciones =
           verificarPermisoNotificaciones ?? _solicitarPermisoNotificaciones;

  final Future<bool> Function() _verificarPermisoNotificaciones;
  final PermisosMiUpcRepository _permisos = Get.find();
  final ValidacionCiudadanoAlertaRepository _validacion = Get.find();
  final CrearAlertaCiudadanaRepository _crear = Get.find();
  final AtenderAlertaCiudadanaRepository _atender = Get.find();
  final AlertasAtendidasPoliciaRepository _historial = Get.find();
  final LocalStoreImpl _local = Get.find();
  final AlertasPoliciaRepository _bandejaPolicia = Get.find();
  final AlertasGeneradasCiudadanoRepository _generadasCiudadano = Get.find();
  final PersonalHotelRepository _personalHotel = Get.find();
  final viendoHistorial = false.obs;
  final cargandoHistorial = false.obs;
  bool _historialCargado = false;
  bool _estuvoEnSegundoPlano = false;
  Future<void>? _cargaPendiente;
  int _consultaGeneradas = 0;

  final cargandoAlertasGeneradas = false.obs;
  final errorAlertasGeneradas = ''.obs;
  final historialCiudadano = <AlertasGeneradasCiudadano>[].obs;
  final personalHotelRegistrado = <PersonalHotelRegistrado>[].obs;
  final registrandoPersonalHotel = false.obs;
  final errorPersonalHotel = ''.obs;
  final permisoNotificacionesActivo = false.obs;
  final verificandoPermisoNotificaciones = true.obs;

  List<AlertaGeneradaCiudadano> get alertasGeneradas {
    final porId = <int, AlertaGeneradaCiudadano>{};
    for (final historial in historialCiudadano) {
      for (final alerta in historial.todas) {
        porId[alerta.idDgoAlertasMovilCiu] = alerta;
      }
    }
    return porId.values.toList()..sort(
      (a, b) => b.idDgoAlertasMovilCiu.compareTo(a.idDgoAlertasMovilCiu),
    );
  }

  int get totalAlertasGeneradas =>
      historialCiudadano.fold(0, (total, item) => total + item.totalAlertas);
  int get totalGeneradasPendientes =>
      historialCiudadano.fold(0, (total, item) => total + item.totalPendientes);
  int get totalGeneradasEnAtencion =>
      historialCiudadano.fold(0, (total, item) => total + item.totalEnAtencion);
  int get totalGeneradasAtendidas =>
      historialCiudadano.fold(0, (total, item) => total + item.totalAtendidas);

  final cargando = false.obs;
  final enviando = false.obs;
  final peticionInstitucional = false.obs;
  final bandejaDisponible = false.obs;
  final error = ''.obs;
  final resultado = ''.obs;
  final permiso = Rxn<PermisoMiUpc>();
  final ciudadanoValidado = Rxn<CiudadanoAlerta>();
  final estadoPermisos = EstadoConsultaPermisos.pendiente.obs;
  final alertas = <DetalleAlertaCiudadana>[].obs;
  final seleccionada = Rxn<DetalleAlertaCiudadana>();
  final alertaNotificacion = Rxn<DetalleAlertaCiudadana>();
  final verificacion = ''.obs;
  final observacion = TextEditingController();
  final procedimiento = TextEditingController();
  String _documento = '';
  bool _dialogoNotificacionAbierto = false;

  bool get esCiudadano => permiso.value?.puedeEnviarAlertas ?? false;
  bool get esUsuarioHotel {
    final ciudadano = ciudadanoValidado.value;
    return esCiudadano &&
        ciudadano != null &&
        ciudadano.idDgoPersonasAlertaApp > 0 &&
        ciudadano.esHotel;
  }

  bool get esPolicia =>
      !esCiudadano && (permiso.value?.puedeAtenderAlertas ?? false);
  bool get notificacionesBloqueadas =>
      !verificandoPermisoNotificaciones.value &&
      !permisoNotificacionesActivo.value;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _estuvoEnSegundoPlano = true;
    } else if (state == AppLifecycleState.resumed && _estuvoEnSegundoPlano) {
      _estuvoEnSegundoPlano = false;
      cargar();
    }
  }

  @override
  void onReady() {
    super.onReady();
    cargar();
  }

  @override
  void onClose() {
    _consultaGeneradas++;
    WidgetsBinding.instance.removeObserver(this);
    observacion.dispose();
    procedimiento.dispose();
    super.onClose();
  }

  Future<void> cargar() {
    if (_cargaPendiente != null) return _cargaPendiente!;
    if (cargando.value || enviando.value || isClosed) return Future.value();
    return _cargaPendiente = _cargar().whenComplete(() {
      _cargaPendiente = null;
    });
  }

  void _limpiarAcceso() {
    _limpiarHistorialCiudadano();
    personalHotelRegistrado.clear();
    errorPersonalHotel.value = '';
    permiso.value = null;
    ciudadanoValidado.value = null;
    alertas.clear();
    seleccionada.value = null;
    procedimiento.clear();
    verificacion.value = '';
    resultado.value = '';
    _historialCargado = false;
  }

  void _aplicarPermisos(ConsultaPermisosMiUpc respuesta) {
    if (respuesta.codeError != 0) {
      throw StateError(
        respuesta.msj.isEmpty
            ? 'No se pudieron consultar los permisos Mi UPC.'
            : respuesta.msj,
      );
    }
    estadoPermisos.value = EstadoConsultaPermisos.confirmada;
    permiso.value = respuesta.datos.firstWhereOrNull(
      (item) => item.documento == _documento,
    );

    if (!esCiudadano) {
      ciudadanoValidado.value = null;
      _limpiarHistorialCiudadano();
    }

    if (!esPolicia) {
      alertas.clear();
      seleccionada.value = null;
      _historialCargado = false;
    }
  }

  Future<void> _cargar() async {
    cargando.value = true;
    peticionInstitucional.value = true;
    error.value = '';
    bandejaDisponible.value = false;
    final idSeleccionada = seleccionada.value?.id;
    var permisosConsultados = false;
    try {
      final notificacionesActivas = await asegurarPermisoNotificaciones();
      if (isClosed) return;
      if (!notificacionesActivas) {
        _limpiarAcceso();
        estadoPermisos.value = EstadoConsultaPermisos.pendiente;
        error.value = '';
        return;
      }
      final usuario = await _local.getDatosUsuarioCompleto();
      if (isClosed) return;
      final documento = usuario?['cedula']?.toString().trim() ?? '';
      if (documento != _documento) {
        _limpiarAcceso();
        observacion.clear();
        estadoPermisos.value = EstadoConsultaPermisos.pendiente;
      }
      _documento = documento;
      if (_documento.isEmpty) {
        estadoPermisos.value = EstadoConsultaPermisos.sinRegistro;
        error.value = 'Complete su registro con la cédula para consultar el acceso a alertas.';
        return;
      }
      final respuesta = await _permisos.consultarPermisosMiUpc(
        documento: _documento,
      );
      if (isClosed) return;
      _aplicarPermisos(respuesta);
      permisosConsultados = true;
      if (esCiudadano) {
        ciudadanoValidado.value = null;
        final ciudadano = await _consultarCiudadanoValidado();
        if (isClosed) return;
        if (ciudadano == null) {
          throw StateError(
            'No se encontró una validación ciudadana activa para esta cuenta.',
          );
        }
        ciudadanoValidado.value = ciudadano;
      }
      if (esPolicia) {
        final respuestaBandeja = await _bandejaPolicia.consultarAlertasPolicia(
          documento: _documento,
        );
        if (isClosed) return;
        if (respuestaBandeja.codeError != 0) {
          throw StateError(respuestaBandeja.msj);
        }
        final datos = respuestaBandeja.datos.where(
          (item) => item.documento == _documento,
        );
        final porId = <int, DetalleAlertaCiudadana>{};
        for (final bandeja in datos) {
          for (final item in [...bandeja.pendientes, ...bandeja.atendidas]) {
            porId[item.id] = item;
          }
        }
        alertas.assignAll(
          porId.values.toList()..sort((a, b) => b.id.compareTo(a.id)),
        );
        bandejaDisponible.value = true;
        _historialCargado = false;
        final id = int.tryParse(Get.parameters['alerta'] ?? '');
        final actual = idSeleccionada;
        final alerta = alertas.firstWhereOrNull(
          (item) => item.id == (id ?? actual),
        );
        if (alerta != null) {
          seleccionar(alerta);
          if (Get.parameters['notificacion'] == 'true') {
            alertaNotificacion.value = alerta;
          }
        }
      }
    } catch (e) {
      if (isClosed) return;
      if (!permisosConsultados) {
        estadoPermisos.value = EstadoConsultaPermisos.noDisponible;
      }
      error.value = _mensajeError(e);
    } finally {
      if (!isClosed) {
        cargando.value = false;
        peticionInstitucional.value = false;
      }
    }
  }

  Future<void> mostrarHistorial(bool mostrar) async {
    if (cargando.value || enviando.value || cargandoHistorial.value) return;
    if (!permisoNotificacionesActivo.value &&
        !await asegurarPermisoNotificaciones()) {
      error.value =
          'Active los permisos de notificación para consultar y gestionar alertas.';
      return;
    }
    viendoHistorial.value = mostrar;
    seleccionada.value = null;
    if (!mostrar || _historialCargado || !esPolicia) {
      return;
    }
    cargandoHistorial.value = true;
    error.value = '';
    try {
      final respuesta = await _historial.consultarAlertasAtendidas(
        documento: _documento,
      );
      if (respuesta.codeError != 0) throw StateError(respuesta.msj);
      final pendientes = alertas.where((item) => !item.atendida).toList();
      final atendidas = respuesta.datos
          .where((item) => item.documento == _documento)
          .expand((item) => item.alertas);
      alertas.assignAll([...pendientes, ...atendidas]);
      _historialCargado = true;
    } catch (e) {
      error.value = _mensajeError(e);
    } finally {
      cargandoHistorial.value = false;
    }
  }

  void mostrarPendientes() {
    viendoHistorial.value = false;
    seleccionada.value = null;
    error.value = '';
    resultado.value = '';
  }

  void _limpiarHistorialCiudadano() {
    _consultaGeneradas++;
    historialCiudadano.clear();
    errorAlertasGeneradas.value = '';
    cargandoAlertasGeneradas.value = false;
  }

  Future<void> cargarAlertasGeneradas() async {
    if (isClosed ||
        cargando.value ||
        enviando.value ||
        cargandoAlertasGeneradas.value ||
        !esCiudadano) {
      return;
    }

    if (!await asegurarPermisoNotificaciones()) {
      errorAlertasGeneradas.value =
          'Active las notificaciones para utilizar el módulo de alertas.';
      return;
    }

    final consulta = ++_consultaGeneradas;
    final documento = _documento;
    cargandoAlertasGeneradas.value = true;
    errorAlertasGeneradas.value = '';
    historialCiudadano.clear();

    bool vigente() =>
        !isClosed && consulta == _consultaGeneradas && documento == _documento;

    try {
      final usuario = await _local.getDatosUsuarioCompleto();
      if (!vigente()) return;
      if (documento.isEmpty ||
          usuario?['cedula']?.toString().trim() != documento) {
        throw StateError(
          'Su registro cambió. Cierre el diálogo y actualice sus datos antes de consultar las alertas.',
        );
      }
      final respuesta = await _generadasCiudadano.consultarAlertasGeneradas(
        documento: documento,
      );
      if (!vigente()) return;
      // La cuenta puede cambiar mientras el servidor responde.
      final usuarioActual = await _local.getDatosUsuarioCompleto();
      if (!vigente()) return;
      if (usuarioActual?['cedula']?.toString().trim() != documento) {
        throw StateError(
          'Su registro cambió. Cierre el diálogo y actualice sus datos antes de consultar las alertas.',
        );
      }
      if (respuesta.codeError != 0) {
        throw StateError(
          respuesta.msj.isEmpty
              ? 'No se pudieron consultar sus alertas generadas.'
              : respuesta.msj,
        );
      }
      historialCiudadano.assignAll(
        respuesta.datos.where((item) => item.documento == documento),
      );
    } catch (e) {
      if (vigente()) errorAlertasGeneradas.value = _mensajeError(e);
    } finally {
      if (vigente()) cargandoAlertasGeneradas.value = false;
    }
  }

  Future<bool> registrarPersonalHotel({
    required String documento,
    required String nombres,
    required String nacionalidad,
  }) async {
    if (registrandoPersonalHotel.value) return false;
    final ciudadano = ciudadanoValidado.value;
    if (!esUsuarioHotel ||
        ciudadano == null ||
        ciudadano.idDgoPersonasAlertaApp <= 0) {
      errorPersonalHotel.value =
          'La cuenta no tiene permisos para registrar personal del hotel.';
      return false;
    }
    if (!await asegurarPermisoNotificaciones()) {
      errorPersonalHotel.value =
          'Active las notificaciones para utilizar las funciones del módulo de alertas.';
      return false;
    }

    final idPersona = ciudadano.idDgoPersonasAlertaApp;
    final documentoSesion = _documento;
    registrandoPersonalHotel.value = true;
    errorPersonalHotel.value = '';
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
          'Active la ubicación del dispositivo para registrar al huésped.',
        );
      }
      var permisoUbicacion = await Geolocator.checkPermission();
      if (permisoUbicacion == LocationPermission.denied) {
        permisoUbicacion = await Geolocator.requestPermission();
      }
      if (permisoUbicacion == LocationPermission.denied ||
          permisoUbicacion == LocationPermission.deniedForever) {
        throw StateError(
          'Se necesita el permiso de ubicación para registrar al huésped.',
        );
      }
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!posicion.latitude.isFinite ||
          !posicion.longitude.isFinite ||
          posicion.latitude.abs() > 90 ||
          posicion.longitude.abs() > 180 ||
          (posicion.latitude == 0 && posicion.longitude == 0)) {
        throw StateError(
          'No se obtuvo una ubicación válida. Vuelva a intentar.',
        );
      }
      final respuesta = await _personalHotel.registrarPersonalHotel(
        idDgoPersonasAlertaApp: idPersona,
        documento: documento,
        nombres: nombres,
        nacionalidad: nacionalidad,
        latitud: posicion.latitude,
        longitud: posicion.longitude,
      );
      final registrado = respuesta.datos;
      if (respuesta.codeError != 0 ||
          registrado == null ||
          registrado.idDgoHuespedesApp <= 0 ||
          registrado.idDgoPersonasAlertaApp != idPersona) {
        throw StateError(
          respuesta.msj.isEmpty
              ? 'No se pudo confirmar el registro del personal.'
              : respuesta.msj,
        );
      }
      if (isClosed ||
          _documento != documentoSesion ||
          permiso.value?.ciudadano?.idDgoPersonasAlertaApp != idPersona) {
        if (!isClosed) {
          errorPersonalHotel.value = 'La cuenta cambió durante el registro. Actualice la pantalla antes de continuar.';
        }
        return false;
      }
      personalHotelRegistrado.insert(0, registrado);
      return true;
    } catch (e) {
      errorPersonalHotel.value = _mensajeError(e);
      return false;
    } finally {
      registrandoPersonalHotel.value = false;
    }
  }

  void seleccionar(DetalleAlertaCiudadana alerta) {
    seleccionada.value = alerta;
    viendoHistorial.value = alerta.atendida;
    procedimiento.text = alerta.procedimiento;
    verificacion.value = alerta.verificacion;
    resultado.value = '';
  }

  Future<void> prepararAlertaNotificada(int idAlerta) async {
    if (isClosed || idAlerta <= 0) return;
    await cargar();
    if (isClosed) return;

    final alerta = alertas.firstWhereOrNull((item) => item.id == idAlerta);
    if (alerta == null) {
      error.value =
          'Se recibió la alerta N.º $idAlerta, pero no fue posible cargar su detalle desde la bandeja policial.';
      return;
    }

    seleccionar(alerta);
    alertaNotificacion.value = alerta;
  }

  bool marcarDialogoNotificacionAbierto() {
    if (_dialogoNotificacionAbierto || alertaNotificacion.value == null) {
      return false;
    }
    _dialogoNotificacionAbierto = true;
    return true;
  }

  void cerrarDialogoNotificacion() {
    _dialogoNotificacionAbierto = false;
    alertaNotificacion.value = null;
  }

  Future<bool> asegurarPermisoNotificaciones() async {
    if (isClosed) return false;
    verificandoPermisoNotificaciones.value = true;
    try {
      final activo = await _verificarPermisoNotificaciones();
      if (!isClosed) permisoNotificacionesActivo.value = activo;
      return activo;
    } catch (e) {
      if (!isClosed) permisoNotificacionesActivo.value = false;
      debugPrint('No fue posible verificar el permiso de notificaciones: $e');
      return false;
    } finally {
      if (!isClosed) verificandoPermisoNotificaciones.value = false;
    }
  }

  Future<bool> activarNotificaciones() async {
    final activo = await asegurarPermisoNotificaciones();
    if (!isClosed) {
      error.value = activo
          ? ''
          : 'Las notificaciones son obligatorias para utilizar el módulo de alertas.';
    }
    return activo;
  }

  Future<void> abrirAjustesNotificaciones() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      if (!isClosed) {
        error.value =
            'No fue posible abrir los ajustes de la aplicación. Active manualmente las notificaciones desde los ajustes del dispositivo.';
      }
    }
  }

  static Future<bool> _solicitarPermisoNotificaciones() async {
    final messaging = FirebaseMessaging.instance;
    var settings = await messaging.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      return true;
    }
    settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<CiudadanoAlerta?> _consultarCiudadanoValidado() async {
    final respuesta = await _validacion.validarCiudadanoAlerta(
      documento: _documento,
    );
    if (respuesta.codeError != 0) {
      throw StateError(
        respuesta.msj.isEmpty
            ? 'No se pudo validar el registro del ciudadano.'
            : respuesta.msj,
      );
    }
    return respuesta.datos.firstWhereOrNull(
      (item) => item.documento == _documento && item.idDgoPersonasAlertaApp > 0,
    );
  }

  Future<bool> enviar() async {
    if (cargando.value || enviando.value || !esCiudadano) return false;
    if (observacion.text.trim().length < 5) {
      error.value = 'Describa lo ocurrido con al menos 5 caracteres.';
      return false;
    }
    if (!await asegurarPermisoNotificaciones()) {
      error.value =
          'Active los permisos de notificación para enviar una SOS ALERTA.';
      return false;
    }
    enviando.value = true;
    peticionInstitucional.value = true;
    error.value = '';
    resultado.value = '';
    try {
      // Se valida nuevamente el permiso antes de enviar.
      final permisos = await _permisos.consultarPermisosMiUpc(
        documento: _documento,
      );
      _aplicarPermisos(permisos);
      if (!esCiudadano) {
        throw StateError(
          'Su cuenta no tiene permiso para enviar alertas ciudadanas.',
        );
      }
      final ciudadano = await _consultarCiudadanoValidado();
      if (ciudadano == null) {
        throw StateError(
          'El ciudadano no está habilitado para enviar alertas.',
        );
      }
      ciudadanoValidado.value = ciudadano;
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
          'Active la ubicación del dispositivo para enviar la alerta.',
        );
      }
      var gps = await Geolocator.checkPermission();
      if (gps == LocationPermission.denied) {
        gps = await Geolocator.requestPermission();
      }
      if (gps == LocationPermission.denied ||
          gps == LocationPermission.deniedForever) {
        throw StateError(
          'Se necesita el permiso de ubicación para enviar la alerta.',
        );
      }
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      final respuesta = await _crear.crearAlertaCiudadana(
        idDgoPersonasAlertaApp: ciudadano.idDgoPersonasAlertaApp,
        latitud: posicion.latitude,
        longitud: posicion.longitude,
        observacion: observacion.text.trim(),
      );
      if (respuesta.codeError != 0 ||
          respuesta.datos == null ||
          respuesta.datos!.idDgoAlertasMovilCiu <= 0) {
        throw StateError(
          respuesta.msj.isEmpty
              ? 'No se pudo confirmar el envío de la alerta.'
              : respuesta.msj,
        );
      }
      observacion.clear();
      resultado.value =
          'Alerta N.º ${respuesta.datos!.idDgoAlertasMovilCiu} enviada correctamente.';
      return true;
    } catch (e) {
      error.value = _mensajeError(e);
      return false;
    } finally {
      enviando.value = false;
      peticionInstitucional.value = false;
    }
  }

  Future<bool> atender() async {
    final alerta = seleccionada.value;
    if (cargando.value ||
        enviando.value ||
        !esPolicia ||
        alerta == null ||
        alerta.atendida) {
      return false;
    }
    if (procedimiento.text.trim().length < 5 ||
        !['VERIFICADA', 'NO_VERIFICADA'].contains(verificacion.value)) {
      error.value = 'Describa el procedimiento y seleccione el resultado de la verificación.';
      return false;
    }
    if (!await asegurarPermisoNotificaciones()) {
      error.value =
          'Active las notificaciones para atender y gestionar alertas.';
      return false;
    }
    enviando.value = true;
    peticionInstitucional.value = true;
    error.value = '';
    resultado.value = '';
    try {
      final respuestaPermisos = await _permisos.consultarPermisosMiUpc(
        documento: _documento,
      );
      _aplicarPermisos(respuestaPermisos);
      final acceso = permiso.value;
      if (!esPolicia) {
        throw StateError('Su cuenta no tiene permiso para atender alertas.');
      }
      final respuesta = await _atender.atenderAlertaCiudadana(
        idDgoAlertasMovilCiu: alerta.id,
        idGenUsuario: acceso!.servidorPolicial!.idGenUsuario,
        procedimiento: procedimiento.text.trim(),
        estadoVerificacion: verificacion.value,
      );
      final atencion = respuesta.datos;
      if (respuesta.codeError != 0 ||
          atencion == null ||
          atencion.idDgoAlertasMovilCiu != alerta.id ||
          atencion.idGenUsuarioAtiende !=
              acceso.servidorPolicial!.idGenUsuario ||
          atencion.estadoAlerta != 'ATENDIDA') {
        throw StateError(
          respuesta.msj.isEmpty
              ? 'No se pudo confirmar la atención de la alerta.'
              : respuesta.msj,
        );
      }
      final actualizada = DetalleAlertaCiudadana.fromJson({
        ...alerta.toJson(),
        'estadoAlerta': atencion.estadoAlerta,
        'estadoVerificacion': atencion.estadoVerificacion,
        'procedimiento': procedimiento.text.trim(),
        'fechaAtencion': atencion.fechaAtencion,
      });
      final index = alertas.indexWhere((item) => item.id == alerta.id);
      if (index >= 0) alertas[index] = actualizada;
      seleccionada.value = actualizada;
      _historialCargado = false;
      resultado.value = 'Procedimiento registrado correctamente.';
      return true;
    } catch (e) {
      error.value = _mensajeError(e);
      return false;
    } finally {
      enviando.value = false;
      peticionInstitucional.value = false;
    }
  }

  String _mensajeError(Object error) => error is ServerException
      ? error.cause
      : error.toString().replaceFirst('Bad state: ', '');
}
