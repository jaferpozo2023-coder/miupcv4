import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/exceptions/exceptions.dart';
import '../../../data/models/detalle_alerta_ciudadana_model.dart';
import '../../../data/models/permisos_mi_upc_model.dart';
import '../../../data/repository/data_repositories.dart';
import '../../../domain/repositories/domain_repositories.dart';

enum EstadoConsultaPermisos { pendiente, confirmada, noDisponible, sinRegistro }

class AlertasCiudadanasController extends GetxController
    with WidgetsBindingObserver {
  final PermisosMiUpcRepository _permisos = Get.find();
  final ValidacionCiudadanoAlertaRepository _validacion = Get.find();
  final CrearAlertaCiudadanaRepository _crear = Get.find();
  final AtenderAlertaCiudadanaRepository _atender = Get.find();
  final AlertasAtendidasPoliciaRepository _historial = Get.find();
  final LocalStoreImpl _local = Get.find();
  final AlertasPoliciaRepository _bandejaPolicia = Get.find();
  final viendoHistorial = false.obs;
  bool _historialCargado = false;
  bool _estuvoEnSegundoPlano = false;
  Future<void>? _cargaPendiente;

  final cargando = false.obs;
  final enviando = false.obs;
  final peticionInstitucional = false.obs;
  final bandejaDisponible = false.obs;
  final error = ''.obs;
  final resultado = ''.obs;
  final permiso = Rxn<PermisoMiUpc>();
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
  bool get esPolicia =>
      !esCiudadano && (permiso.value?.puedeAtenderAlertas ?? false);

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
    permiso.value = null;
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
    viendoHistorial.value = mostrar;
    seleccionada.value = null;
    if (!mostrar ||
        _historialCargado ||
        !esPolicia ||
        cargando.value ||
        enviando.value) {
      return;
    }
    cargando.value = true;
    peticionInstitucional.value = true;
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
      cargando.value = false;
      peticionInstitucional.value = false;
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

  Future<bool> enviar() async {
    if (cargando.value || enviando.value || !esCiudadano) return false;
    if (observacion.text.trim().length < 5) {
      error.value = 'Describa lo ocurrido con al menos 5 caracteres.';
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
      final validacion = await _validacion.validarCiudadanoAlerta(
        documento: _documento,
      );
      final ciudadano = validacion.datos.firstWhereOrNull(
        (item) => item.documento == _documento,
      );
      if (validacion.codeError != 0 ||
          ciudadano == null ||
          ciudadano.idDgoPersonasAlertaApp <= 0) {
        throw StateError(
          'El ciudadano no está habilitado para enviar alertas.',
        );
      }
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

  Future<void> atender() async {
    final alerta = seleccionada.value;
    if (cargando.value ||
        enviando.value ||
        !esPolicia ||
        alerta == null ||
        alerta.atendida) {
      return;
    }
    if (procedimiento.text.trim().length < 5 ||
        !['VERIFICADA', 'NO_VERIFICADA'].contains(verificacion.value)) {
      error.value = 'Describa el procedimiento y seleccione el resultado de la verificación.';
      return;
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
      viendoHistorial.value = true;
      _historialCargado = false;
      resultado.value = 'Procedimiento registrado correctamente.';
    } catch (e) {
      error.value = _mensajeError(e);
    } finally {
      enviando.value = false;
      peticionInstitucional.value = false;
    }
  }

  String _mensajeError(Object error) => error is ServerException
      ? error.cause
      : error.toString().replaceFirst('Bad state: ', '');
}
