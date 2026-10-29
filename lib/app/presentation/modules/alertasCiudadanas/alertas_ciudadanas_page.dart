import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/detalle_alerta_ciudadana_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_widgets.dart';
import 'alertas_ciudadanas_controller.dart';
import 'alertas_generadas_ciudadano_dialog.dart';
import 'personal_hotel_dialog.dart';

const _navy = Color(0xFF061D33);
const _blue = Color(0xFF0A4F73);
const _blueSoft = Color(0xFF0D6E8A);
const _cyan = Color(0xFF55DFE8);
const _red = Color(0xFFED4457);
const _green = Color(0xFF15966F);
const _ink = Color(0xFF17324A);
const _muted = Color(0xFF667C8F);
const _line = Color(0xFFD8E5ED);

class AlertasCiudadanasPage extends GetView<AlertasCiudadanasController> {
  const AlertasCiudadanasPage({super.key});

  @override
  Widget build(BuildContext context) => WorkAreaItemsPageWidget(
    titleAppBar: 'Centro de alertas',
    btnAtras: true,
    peticionServer: controller.peticionInstitucional,
    paddin: const EdgeInsets.fromLTRB(12, 12, 12, 24),
    contenido: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Obx(() {
          Widget contenido;

          if (controller.verificandoPermisoNotificaciones.value) {
            contenido = _verificandoNotificaciones();
          } else if (!controller.permisoNotificacionesActivo.value) {
            contenido = _notificacionesRequeridas(context);
          } else if (controller.cargando.value) {
            contenido = _estadoCargaPrincipal();
          } else {
            final alertaNotificada = controller.alertaNotificacion.value;
            if (alertaNotificada != null &&
                controller.marcarDialogoNotificacionAbierto()) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _mostrarDialogoNotificacion(context, alertaNotificada);
              });
            }

            contenido = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.esCiudadano)
                  _ciudadano(context)
                else if (controller.esPolicia)
                  _policia(context)
                else if (controller.estadoPermisos.value !=
                    EstadoConsultaPermisos.confirmada)
                  _consultaNoDisponible()
                else
                  _sinPermiso(),
                if (controller.error.isNotEmpty &&
                    !(controller.esPolicia &&
                        !controller.bandejaDisponible.value)) ...[
                  const SizedBox(height: 10),
                  _message(controller.error.value, isError: true),
                ],
                if (controller.resultado.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _message(controller.resultado.value),
                ],
              ],
            );
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey<String>(
                '${controller.verificandoPermisoNotificaciones.value}-'
                '${controller.permisoNotificacionesActivo.value}-'
                '${controller.cargando.value}-'
                '${controller.esCiudadano}-'
                '${controller.esPolicia}',
              ),
              child: contenido,
            ),
          );
        }),
      ),
    ),
  );

  Widget _estadoCargaPrincipal() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 44),
    child: Center(
      child: Container(
        width: 270,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x15102845),
              blurRadius: 22,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.8,
                color: _blue,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Sincronizando centro de alertas',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Validando permisos y novedades disponibles…',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _mostrarDialogoNotificacion(
    BuildContext context,
    DetalleAlertaCiudadana alerta,
  ) async {
    if (!context.mounted) {
      controller.cerrarDialogoNotificacion();
      return;
    }

    try {
      await Get.dialog<void>(
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 520,
              maxHeight: MediaQuery.sizeOf(context).height * .82,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _cyan.withValues(alpha: .45)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x6607172D),
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 14, 17),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_navy, _blue, Color(0xFF15558A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _cyan.withValues(alpha: .8),
                            ),
                          ),
                          child: Image.asset(
                            'assets/icon/icon_mi_upc.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.shield_rounded,
                              color: _blue,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NUEVA ALERTA CIUDADANA',
                                style: TextStyle(
                                  color: _cyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'INCIDENTE  #${alerta.id}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: Get.back,
                          tooltip: 'Cerrar detalle',
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.notifications_active_rounded,
                                color: _red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  alerta.tipo.isEmpty
                                      ? 'ALERTA CIUDADANA'
                                      : alerta.tipo.toUpperCase(),
                                  style: const TextStyle(
                                    color: _ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .5,
                                  ),
                                ),
                              ),
                              _statusPill(
                                alerta.estado.toUpperCase(),
                                isDone: alerta.atendida,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _dialogInfo('FECHA / HORA', alerta.fecha),
                          _dialogInfo('INSTITUCIÓN', alerta.institucion),
                          _dialogInfo('CIUDADANO', alerta.ciudadano),
                          _dialogInfo('CONTACTO', alerta.telefonoCiudadano),
                          _dialogInfo('DIRECCIÓN', alerta.direccion),
                          Container(
                            margin: const EdgeInsets.only(top: 7),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6F3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFFFFD7C8),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'OBSERVACIÓN REPORTADA',
                                  style: TextStyle(
                                    color: _red,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: .75,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  alerta.observacion.isEmpty
                                      ? 'Sin observación adicional'
                                      : alerta.observacion,
                                  style: const TextStyle(
                                    color: _ink,
                                    fontSize: 13,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (alerta.tieneUbicacion)
                            _dialogInfo(
                              'COORDENADAS',
                              '${alerta.latitud!.toStringAsFixed(6)}, ${alerta.longitud!.toStringAsFixed(6)}',
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: _actionButton(
                      label: alerta.atendida
                          ? 'VER FICHA DE LA ALERTA'
                          : 'ABRIR Y ATENDER ALERTA',
                      icon: Icons.arrow_forward_rounded,
                      accent: alerta.atendida ? const Color(0xFF127F79) : _red,
                      onPressed: Get.back,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: true,
        useSafeArea: true,
      );
    } finally {
      controller.cerrarDialogoNotificacion();
    }
  }

  Widget _dialogInfo(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? 'No informado' : value,
            style: const TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _enviarAlerta(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final generada = await controller.enviar();
    if (!generada || !context.mounted) return;

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      dialogBorderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(18),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: Color(0xFF147D58),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Alerta generada correctamente',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _blue,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            controller.resultado.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 14, height: 1.4),
          ),
        ],
      ),
      btnOkText: 'VOLVER AL INICIO',
      btnOkColor: _blue,
      btnOkOnPress: () {},
    ).show();

    if (!context.mounted) return;
    Get.until(
      (route) => route.settings.name == AppRoutes.MENU || route.isFirst,
    );
    if (Get.currentRoute != AppRoutes.MENU) {
      Get.offAllNamed(AppRoutes.MENU);
    }
  }

  Future<void> _atenderAlerta(BuildContext context) async {
    final atendida = await controller.atender();
    if (!atendida || !context.mounted) return;

    await AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      headerAnimationLoop: false,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      dialogBorderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(18),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 48,
              color: Color(0xFF147D58),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Atención registrada',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _blue,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'La alerta fue verificada y registrada. Se muestra la bandeja de pendientes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, height: 1.45),
          ),
        ],
      ),
      btnOkText: 'VER PENDIENTES',
      btnOkColor: _blue,
      btnOkOnPress: controller.mostrarPendientes,
    ).show();
  }

  Future<void> _mostrarAlertasGeneradas(BuildContext context) async {
    if (!controller.esCiudadano || Get.isDialogOpen == true) return;
    FocusScope.of(context).unfocus();
    unawaited(controller.cargarAlertasGeneradas());
    await Get.dialog<void>(
      AlertasGeneradasCiudadanoDialog(controller: controller),
      useSafeArea: true,
      barrierDismissible: true,
    );
  }

  Future<void> _mostrarRegistroPersonalHotel(BuildContext context) async {
    if (!controller.esUsuarioHotel || Get.isDialogOpen == true) return;
    FocusScope.of(context).unfocus();
    controller.errorPersonalHotel.value = '';
    await Get.dialog<void>(
      PersonalHotelDialog(controller: controller),
      useSafeArea: true,
      barrierDismissible: true,
    );
  }

  Widget _ciudadano(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _hero(
        eyebrow: 'MI UPC  /  CANAL CIUDADANO',
        title: 'Alerta ciudadana',
        subtitle:
            'Reporte una novedad y mantenga seguimiento de la atención policial.',
        icon: Icons.radar_rounded,
        accent: _cyan,
        tag: 'CANAL SEGURO',
      ),
      const SizedBox(height: 12),
      LayoutBuilder(
        builder: (context, constraints) {
          final horizontal = constraints.maxWidth >= 560;

          final historial = _quickActionCard(
            key: const ValueKey('ver-alertas-generadas-ciudadano'),
            icon: Icons.history_rounded,
            title: 'Mis alertas',
            subtitle: 'Consulte estado y atención',
            accent: _blueSoft,
            onTap: controller.enviando.value
                ? null
                : () => _mostrarAlertasGeneradas(context),
          );

          final hotel = controller.esUsuarioHotel
              ? _quickActionCard(
                  key: const ValueKey('registrar-personal-hotel'),
                  icon: Icons.apartment_rounded,
                  title: 'Personal del hotel',
                  subtitle: 'Registre huéspedes o personal',
                  accent: _green,
                  onTap: controller.enviando.value
                      ? null
                      : () => _mostrarRegistroPersonalHotel(context),
                )
              : null;

          if (!horizontal) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                historial,
                if (hotel != null) ...[
                  const SizedBox(height: 8),
                  hotel,
                ],
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: historial),
              if (hotel != null) ...[
                const SizedBox(width: 10),
                Expanded(child: hotel),
              ],
            ],
          );
        },
      ),
      const SizedBox(height: 12),
      _surface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 15),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFF9FCFE),
                    Color(0xFFF2F8FB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: const _SectionHeading(
                index: '01',
                title: 'Detalle de la novedad',
                subtitle:
                    'Describa lo ocurrido. La ubicación se adjuntará al momento del envío.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: controller.observacion,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 1000,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      height: 1.45,
                    ),
                    decoration: _inputDecoration(
                      label: '¿Qué está ocurriendo?',
                      hint:
                          'Describa brevemente la situación, lugar y cualquier dato relevante…',
                      icon: Icons.edit_note_rounded,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _locationNotice(),
                  const SizedBox(height: 14),
                  _emergencyNotice(),
                  const SizedBox(height: 16),
                  _actionButton(
                    label: controller.enviando.value
                        ? 'TRANSMITIENDO ALERTA…'
                        : 'ENVIAR ALERTA',
                    icon: Icons.sos_rounded,
                    accent: _red,
                    busy: controller.enviando.value,
                    onPressed: controller.enviando.value
                        ? null
                        : () => _enviarAlerta(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _quickActionCard({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required VoidCallback? onTap,
  }) =>
      Material(
        key: key,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x10102845),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: accent.withValues(alpha: .23),
                    ),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: onTap == null
                      ? _muted.withValues(alpha: .35)
                      : accent,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _locationNotice() => Container(
    padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF0FAFB),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFBDE9EC)),
    ),
    child: const Row(
      children: [
        _MiniStatusIcon(
          icon: Icons.my_location_rounded,
          color: _blue,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ubicación lista para adjuntar',
                style: TextStyle(
                  color: _ink,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Se solicitará el GPS únicamente al transmitir la alerta.',
                style: TextStyle(
                  color: _muted,
                  fontSize: 10.8,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Icon(
          Icons.verified_user_rounded,
          color: _green,
          size: 18,
        ),
      ],
    ),
  );

  Widget _emergencyNotice() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF6F7),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFFFD5DA)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          color: _red,
          size: 18,
        ),
        SizedBox(width: 9),
        Expanded(
          child: Text(
            'Use este canal ante situaciones que requieran atención policial. Evite reportes de prueba o información incompleta.',
            style: TextStyle(
              color: _ink,
              fontSize: 10.7,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _policia(BuildContext context) {
    final alerta = controller.seleccionada.value;
    final pendientes = controller.alertas
        .where((item) => !item.atendida)
        .length;
    final atendidas = controller.alertas.where((item) => item.atendida).length;
    final lista = controller.alertas
        .where((item) => item.atendida == controller.viendoHistorial.value)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hero(
          eyebrow: 'MI UPC  /  CENTRO DE OPERACIONES',
          title: 'Atención policial',
          subtitle:
              'Bandeja de alertas ciudadanas asignadas a su unidad operativa.',
          icon: Icons.shield_moon_rounded,
          accent: _cyan,
          tag: 'ENLACE OPERATIVO',
          trailing: _iconAction(
            icon: Icons.sync_rounded,
            tooltip: 'Actualizar bandeja',
            onPressed: controller.cargar,
          ),
        ),
        const SizedBox(height: 14),
        _policeProfile(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _metric(
                label: 'PENDIENTES',
                value: pendientes,
                icon: Icons.radar_rounded,
                accent: _red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(
                label: 'ATENDIDAS',
                value: atendidas,
                icon: Icons.task_alt_rounded,
                accent: _cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (alerta != null) ...[
          _backToQueue(),
          const SizedBox(height: 8),
          _detalle(alerta, context),
        ] else if (!controller.bandejaDisponible.value)
          _bandejaNoDisponible()
        else ...[
          _queueHeader(lista.length),
          const SizedBox(height: 10),
          if (controller.cargandoHistorial.value)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _blueSoft,
                  ),
                ),
              ),
            )
          else if (lista.isEmpty)
            _emptyQueue()
          else
            ...lista.map(_alertTile),
          if (controller.viendoHistorial.value &&
              controller.error.isNotEmpty &&
              !controller.cargandoHistorial.value)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => controller.mostrarHistorial(true),
                icon: const Icon(Icons.refresh_rounded, size: 17),
                label: const Text('Reintentar historial'),
              ),
            ),
        ],
      ],
    );
  }

  Widget _policeProfile() {
    final permiso = controller.permiso.value;
    final servidor = permiso?.servidorPolicial;
    if (permiso == null || servidor == null) {
      return _surface(
        child: const Text(
          'El permiso policial está activo, pero la respuesta no incluyó el detalle del servidor.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
        ),
      );
    }

    return _surface(
      key: const ValueKey('police-profile-card'),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7F9),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.badge_outlined, color: _blue, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PERFIL DE SERVIDOR POLICIAL',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      permiso.apenom.isEmpty
                          ? 'Servidor policial'
                          : permiso.apenom,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _datoServidor(
                  Icons.apartment_rounded,
                  'UNIDAD',
                  servidor.unidad,
                ),
                const Divider(height: 16, color: _line, thickness: .6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final scale =
                        MediaQuery.textScalerOf(context).scale(12) / 12;
                    final columns = constraints.maxWidth >= 260 && scale <= 1.3
                        ? 2
                        : 1;
                    final width =
                        (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        SizedBox(
                          width: width,
                          child: _datoServidor(
                            Icons.smartphone_rounded,
                            'DISPOSITIVO',
                            servidor.dispositivo,
                          ),
                        ),
                        SizedBox(
                          width: width,
                          child: _datoServidor(
                            Icons.devices_rounded,
                            'PLATAFORMA',
                            servidor.plataforma,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              _statusPill(
                servidor.activo ? 'ACTIVO' : 'INACTIVO',
                isDone: servidor.activo,
              ),
              _statusPill(
                servidor.dispositivoVinculado
                    ? 'DISPOSITIVO VINCULADO'
                    : 'DISPOSITIVO SIN VINCULAR',
                isDone: servidor.dispositivoVinculado,
              ),
              _statusPill(
                servidor.tokenRegistrado
                    ? 'TOKEN REGISTRADO'
                    : 'TOKEN PENDIENTE',
                isDone: servidor.tokenRegistrado,
              ),
              _statusPill(
                permiso.permisoPolicial
                    ? 'PERMISO POLICIAL'
                    : 'SIN PERMISO POLICIAL',
                isDone: permiso.permisoPolicial,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datoServidor(IconData icon, String label, String value) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: _blue),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value.isEmpty ? 'No informado' : value,
              style: const TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _bandejaNoDisponible() => _surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: _red, size: 22),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Bandeja no disponible',
                style: TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Los permisos y el perfil policial sí se recibieron correctamente. El servidor no reconoció la consulta de alertas asignadas; no es posible mostrar ni confirmar alertas hasta que ese servicio esté disponible.',
          style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
        ),
        if (controller.error.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            controller.error.value,
            style: const TextStyle(
              color: Color(0xFF9C2532),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: controller.cargar,
          icon: const Icon(Icons.sync_rounded),
          label: const Text('REINTENTAR CONSULTA'),
        ),
      ],
    ),
  );

  Widget _queueHeader(int count) => _surface(
    padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BANDEJA DE ALERTAS',
                style: TextStyle(
                  color: _ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.05,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count ${controller.viendoHistorial.value ? 'registros' : 'casos por gestionar'}',
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          ),
          segments: const [
            ButtonSegment(value: false, label: Text('Pendientes')),
            ButtonSegment(value: true, label: Text('Historial')),
          ],
          selected: {controller.viendoHistorial.value},
          onSelectionChanged: (values) =>
              controller.mostrarHistorial(values.single),
        ),
      ],
    ),
  );

  Widget _alertTile(DetalleAlertaCiudadana item) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => controller.seleccionar(item),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C102E4E),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _alertGlyph(item.atendida),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'INCIDENTE  #${item.id}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: .4,
                            ),
                          ),
                        ),
                        _statusPill(
                          item.atendida ? 'ATENDIDA' : 'PENDIENTE',
                          isDone: item.atendida,
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item.institucion.isEmpty
                          ? item.observacion
                          : item.institucion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${item.tipo.isEmpty ? 'ALERTA CIUDADANA' : item.tipo.toUpperCase()}  ·  ${item.fecha}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _detalle(DetalleAlertaCiudadana alerta, BuildContext context) =>
      _surface(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_navy, _blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Row(
                children: [
                  _alertGlyph(alerta.atendida, large: true),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FICHA DE INCIDENTE',
                          style: TextStyle(
                            color: _cyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ALERTA  #${alerta.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusPill(
                    alerta.estado.toUpperCase(),
                    isDone: alerta.atendida,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SectionHeading(
                    index: '01',
                    title: 'Información recibida',
                    subtitle: 'Datos reportados por el ciudadano.',
                  ),
                  const SizedBox(height: 14),
                  _infoGrid(alerta),
                  const SizedBox(height: 16),
                  _observationPanel(alerta.observacion),
                  const SizedBox(height: 18),
                  _locationPanel(alerta),
                  const SizedBox(height: 18),
                  if (alerta.atendida)
                    _procedureSummary(alerta)
                  else
                    _procedureForm(alerta, context),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _infoGrid(DetalleAlertaCiudadana alerta) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 520 ? 2 : 1;
      final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
      final entries = <Widget>[
        _dataCell(Icons.schedule_rounded, 'FECHA / HORA', alerta.fecha),
        _dataCell(Icons.apartment_rounded, 'INSTITUCIÓN', alerta.institucion),
        _dataCell(Icons.person_outline_rounded, 'CIUDADANO', alerta.ciudadano),
        _dataCell(Icons.phone_outlined, 'CONTACTO', alerta.telefonoCiudadano),
        _dataCell(
          Icons.badge_outlined,
          'TIPO DE USUARIO',
          alerta.tipoCiudadano,
        ),
      ];
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: entries
            .map((entry) => SizedBox(width: width, child: entry))
            .toList(),
      );
    },
  );

  Widget _dataCell(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _line),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _blue, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .65,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'No informado' : value,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _observationPanel(String observation) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8F5),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFFFD7C8)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.record_voice_over_rounded, color: _red, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'OBSERVACIÓN DEL CIUDADANO',
                style: TextStyle(
                  color: _ink,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                observation.isEmpty ? 'Sin observación' : observation,
                style: const TextStyle(color: _ink, fontSize: 13, height: 1.45),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _locationPanel(DetalleAlertaCiudadana alerta) {
    if (!alerta.tieneUbicacion) {
      return _dataCell(
        Icons.location_disabled_outlined,
        'UBICACIÓN',
        'La notificación no incluyó coordenadas válidas.',
      );
    }
    final lat = alerta.latitud!;
    final lng = alerta.longitud!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(
          index: '02',
          title: 'Ubicación del incidente',
          subtitle: 'Coordenadas compartidas al emitir la alerta.',
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            height: 230,
            child: FlutterMap(
              key: ValueKey('ubicacion-alerta-${alerta.id}'),
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 16,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.miupc',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        color: _red,
                        size: 46,
                      ),
                    ),
                  ],
                ),
                const SimpleAttributionWidget(
                  source: Text('OpenStreetMap contributors'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                '${lat.toStringAsFixed(6)}  /  ${lng.toStringAsFixed(6)}',
                style: const TextStyle(
                  color: _blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final abierto = await launchUrl(
                  Uri.https('www.google.com', '/maps/search/', {
                    'api': '1',
                    'query': '$lat,$lng',
                  }),
                  mode: LaunchMode.externalApplication,
                );
                if (!abierto) {
                  controller.error.value = 'No fue posible abrir la ubicación.';
                }
              },
              icon: const Icon(Icons.near_me_outlined, size: 17),
              label: const Text('Navegar'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _procedureForm(
    DetalleAlertaCiudadana alerta,
    BuildContext context,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _SectionHeading(
        index: '03',
        title: 'Registro de intervención',
        subtitle: 'Documente la actuación y confirme el resultado.',
      ),
      const SizedBox(height: 14),
      TextField(
        controller: controller.procedimiento,
        minLines: 4,
        maxLines: 7,
        maxLength: 2000,
        textCapitalization: TextCapitalization.sentences,
        style: const TextStyle(color: _ink, height: 1.45),
        decoration: _inputDecoration(
          label: 'Procedimiento realizado',
          hint: 'Acciones ejecutadas, contacto y resultado de la intervención…',
          icon: Icons.assignment_outlined,
        ),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        key: ValueKey('verificacion-${alerta.id}'),
        initialValue:
            const [
              'VERIFICADA',
              'NO_VERIFICADA',
            ].contains(controller.verificacion.value)
            ? controller.verificacion.value
            : null,
        isExpanded: true,
        decoration: _inputDecoration(
          label: 'Resultado de verificación',
          hint: 'Seleccione el resultado',
          icon: Icons.fact_check_outlined,
        ),
        items: const [
          DropdownMenuItem(
            value: 'VERIFICADA',
            child: Text('Novedad verificada'),
          ),
          DropdownMenuItem(
            value: 'NO_VERIFICADA',
            child: Text('Novedad no verificada'),
          ),
        ],
        onChanged: controller.enviando.value
            ? null
            : (value) => controller.verificacion.value = value ?? '',
      ),
      const SizedBox(height: 16),
      _actionButton(
        label: controller.enviando.value
            ? 'REGISTRANDO INTERVENCIÓN…'
            : 'CERRAR Y REGISTRAR PROCEDIMIENTO',
        icon: Icons.task_alt_rounded,
        accent: const Color(0xFF127F79),
        busy: controller.enviando.value,
        onPressed: controller.enviando.value
            ? null
            : () => _atenderAlerta(context),
      ),
    ],
  );

  Widget _procedureSummary(DetalleAlertaCiudadana alerta) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFFF0FAF7),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFBDE6D8)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(
          index: '03',
          title: 'Intervención registrada',
          subtitle: 'La atención de este caso fue completada.',
        ),
        const SizedBox(height: 13),
        _compactDetail('Fecha de atención', alerta.fechaAtencion),
        _compactDetail('Verificación', alerta.verificacion),
        _compactDetail('Procedimiento', alerta.procedimiento),
      ],
    ),
  );

  Widget _compactDetail(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: _ink, fontSize: 12, height: 1.4),
        children: [
          TextSpan(
            text: '$label  ',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: value.isEmpty ? 'No informado' : value),
        ],
      ),
    ),
  );

  Widget _verificandoNotificaciones() => _surface(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: _cyan.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _cyan.withValues(alpha: .30)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(15),
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _blue),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Verificando notificaciones',
          textAlign: TextAlign.center,
          style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'El Centro de Alertas requiere notificaciones activas para garantizar la recepción oportuna de novedades y cambios de estado.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
        ),
      ],
    ),
  );

  Widget _notificacionesRequeridas(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFF9FCFE), Color(0xFFF1F7FB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFCADDE8)),
      boxShadow: const [
        BoxShadow(color: Color(0x17102E4E), blurRadius: 22, offset: Offset(0, 8)),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_navy, _blue, Color(0xFF15558A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _red.withValues(alpha: .55)),
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  color: _red,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MI UPC / CENTRO DE ALERTAS',
                      style: TextStyle(
                        color: _cyan,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Notificaciones requeridas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Para utilizar las Alertas Ciudadanas debe mantener activado el permiso de notificaciones.',
                style: TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Este permiso permite recibir alertas asignadas, cambios de estado y novedades relacionadas con la atención. Mientras permanezca desactivado, el módulo se mantendrá bloqueado.',
                style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7F4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFFD6CA)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.security_rounded, color: _red, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'La aplicación verifica este permiso al ingresar y cada vez que regresa al Centro de Alertas.',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _actionButton(
                label: 'ACTIVAR NOTIFICACIONES',
                icon: Icons.notifications_active_rounded,
                accent: _red,
                onPressed: () async {
                  final activo = await controller.activarNotificaciones();
                  if (activo && context.mounted) {
                    await controller.cargar();
                  }
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: controller.abrirAjustesNotificaciones,
                icon: const Icon(Icons.settings_outlined),
                label: const Text('ABRIR AJUSTES DE LA APLICACIÓN'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _blue,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  side: const BorderSide(color: _line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              TextButton.icon(
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('VOLVER'),
                style: TextButton.styleFrom(foregroundColor: _muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sinPermiso() => _surface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hero(
          eyebrow: 'MI UPC  /  CONTROL DE ACCESO',
          title: 'Acceso restringido',
          subtitle:
              'No se encontró un permiso ciudadano o policial habilitado.',
          icon: Icons.admin_panel_settings_outlined,
          accent: _cyan,
          tag: 'VALIDACIÓN REQUERIDA',
        ),
        const SizedBox(height: 16),
        _actionButton(
          label: 'REVISAR REGISTRO Y CÉDULA',
          icon: Icons.badge_outlined,
          accent: _blue,
          onPressed: () => Get.toNamed(AppRoutes.REGISTROUSUARIO),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: controller.cargar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Consultar permisos nuevamente'),
        ),
      ],
    ),
  );

  Widget _consultaNoDisponible() {
    final sinRegistro =
        controller.estadoPermisos.value == EstadoConsultaPermisos.sinRegistro;
    return _surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _hero(
            eyebrow: 'MI UPC  /  CONTROL DE ACCESO',
            title: sinRegistro
                ? 'Complete su registro'
                : 'Consulta no disponible',
            subtitle: sinRegistro
                ? 'Registre su cédula para consultar el acceso a alertas.'
                : 'No se pudieron consultar sus permisos. Vuelva a intentar cuando tenga conexión con el servidor.',
            icon: sinRegistro ? Icons.badge_outlined : Icons.cloud_off_rounded,
            accent: _cyan,
            tag: sinRegistro ? 'REGISTRO REQUERIDO' : 'CONSULTA PENDIENTE',
          ),
          const SizedBox(height: 16),
          _actionButton(
            label: sinRegistro
                ? 'REVISAR REGISTRO Y CÉDULA'
                : 'REINTENTAR CONSULTA',
            icon: sinRegistro ? Icons.badge_outlined : Icons.refresh_rounded,
            accent: _blue,
            onPressed: sinRegistro
                ? () => Get.toNamed(AppRoutes.REGISTROUSUARIO)
                : controller.cargar,
          ),
        ],
      ),
    );
  }

  Widget _hero({
    required String eyebrow,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String tag,
    Widget? trailing,
  }) =>
      Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              _navy,
              Color(0xFF093F61),
              Color(0xFF0A6278),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, .58, 1],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: _cyan.withValues(alpha: .28),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x35102645),
              blurRadius: 22,
              offset: Offset(0, 9),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -34,
              top: -48,
              child: Container(
                width: 168,
                height: 168,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .05),
                    width: 22,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 38,
              bottom: -58,
              child: Transform.rotate(
                angle: -.35,
                child: Container(
                  width: 160,
                  height: 84,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _cyan.withValues(alpha: .08),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent,
                      accent.withValues(alpha: .25),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(17, 15, 15, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accent.withValues(alpha: .42),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: .12),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: accent, size: 27),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eyebrow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _cyan,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        if (subtitle.trim().isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .72),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        _tag(tag, accent),
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing,
                  ],
                ],
              ),
            ),
          ],
        ),
      );

  Widget _tag(String label, Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent.withValues(alpha: .38)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _metric({
    required String label,
    required int value,
    required IconData icon,
    required Color accent,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: _navy,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: accent.withValues(alpha: .35)),
    ),
    child: Row(
      children: [
        Icon(icon, color: accent, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .67),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$value',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _alertGlyph(bool done, {bool large = false}) => Container(
    width: large ? 48 : 42,
    height: large ? 48 : 42,
    decoration: BoxDecoration(
      color: (done ? _cyan : _red).withValues(alpha: .12),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: (done ? _cyan : _red).withValues(alpha: .4)),
    ),
    child: Icon(
      done ? Icons.task_alt_rounded : Icons.notification_important_rounded,
      color: done ? const Color(0xFF117A78) : _red,
      size: large ? 26 : 23,
    ),
  );

  Widget _statusPill(String label, {required bool isDone}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: (isDone ? const Color(0xFF147D72) : _red).withValues(alpha: .10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: (isDone ? const Color(0xFF147D72) : _red).withValues(alpha: .32),
      ),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: isDone ? const Color(0xFF147D72) : _red,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: .45,
      ),
    ),
  );

  Widget _emptyQueue() => _surface(
    child: Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF7F9),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.radar_rounded, color: _blue, size: 30),
        ),
        const SizedBox(height: 13),
        Text(
          controller.viendoHistorial.value
              ? 'Sin registros atendidos'
              : 'Bandeja despejada',
          style: const TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Actualice la bandeja para sincronizar las alertas asignadas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: controller.cargar,
          icon: const Icon(Icons.sync_rounded),
          label: const Text('Sincronizar bandeja'),
        ),
      ],
    ),
  );

  Widget _backToQueue() => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: () => controller.seleccionada.value = null,
      icon: const Icon(Icons.arrow_back_rounded, size: 18),
      label: const Text('VOLVER A LA BANDEJA'),
      style: TextButton.styleFrom(
        foregroundColor: _blue,
        textStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
        ),
      ),
    ),
  );

  Widget _iconAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) => IconButton(
    tooltip: tooltip,
    onPressed: onPressed,
    style: IconButton.styleFrom(
      foregroundColor: _cyan,
      backgroundColor: Colors.white.withValues(alpha: .08),
      side: BorderSide(color: _cyan.withValues(alpha: .35)),
    ),
    icon: Icon(icon),
  );

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color accent,
    required VoidCallback? onPressed,
    bool busy = false,
  }) =>
      SizedBox(
        height: 52,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: onPressed == null
                  ? [
                      const Color(0xFF8393A0),
                      const Color(0xFF687A87),
                    ]
                  : [
                      accent,
                      Color.lerp(accent, _navy, .36)!,
                    ],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: onPressed == null
                ? const []
                : [
                    BoxShadow(
                      color: accent.withValues(alpha: .22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: FilledButton.icon(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            icon: busy
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(icon, size: 19),
            label: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10.8,
                fontWeight: FontWeight.w900,
                letterSpacing: .55,
              ),
            ),
          ),
        ),
      );

  Widget _surface({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(18),
  }) =>
      Container(
        key: key,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _line),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14102845),
              blurRadius: 20,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: child,
      );

  Widget _message(String text, {bool isError = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: isError ? const Color(0xFFFFF0F0) : const Color(0xFFEAF8F1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: isError ? const Color(0xFFFFC7CC) : const Color(0xFFB7E5CC),
      ),
    ),
    child: Row(
      children: [
        Icon(
          isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
          color: isError ? _red : const Color(0xFF147D58),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isError
                  ? const Color(0xFF9C2532)
                  : const Color(0xFF176544),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    alignLabelWithHint: true,
    prefixIcon: Icon(icon, color: _blue),
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    counterStyle: const TextStyle(color: _muted, fontSize: 10),
    labelStyle: const TextStyle(color: _blue, fontWeight: FontWeight.w700),
    hintStyle: const TextStyle(color: Color(0xFF8B9AAC), fontSize: 12),
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: _blue, width: 1.7),
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  final String index;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 31,
        height: 31,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_blue, _blueSoft],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x180A4F73),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          index,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            letterSpacing: .5,
          ),
        ),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _ink,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: _muted,
                fontSize: 10.8,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _MiniStatusIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _MiniStatusIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 35,
    height: 35,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .09),
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: color.withValues(alpha: .20),
      ),
    ),
    child: Icon(icon, color: color, size: 18),
  );
}
