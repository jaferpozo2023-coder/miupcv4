import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/push_notification_service.dart';
import '../modules/alertasCiudadanas/alertas_ciudadanas_controller.dart';
import '../routes/app_routes.dart';
import 'push_alert_card.dart';

/// Se monta sobre el navegador para cubrir también formularios y diálogos.
class PushNotificationHost extends StatefulWidget {
  const PushNotificationHost({super.key, required this.child, this.service});

  final Widget child;
  final PushNotificationService? service;

  @override
  State<PushNotificationHost> createState() => _PushNotificationHostState();
}

class _PushNotificationHostState extends State<PushNotificationHost> {
  late final _service = widget.service ?? PushNotificationService.instance;
  bool _openScheduled = false;

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChange);
    _scheduleOpen();
  }

  void _onChange() {
    setState(() {});
    _scheduleOpen();
  }

  void _scheduleOpen() {
    if (_openScheduled || _service.pendingOpen == null) return;
    _openScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openScheduled = false;
      if (mounted) unawaited(_openNotification());
    });
  }

  Future<void> _openNotification() async {
    final alert = _service.takePendingOpen();
    if (alert == null) return;
    try {
      final id = alert.alertId;
      if (id == null) {
        await Get.dialog<void>(
          AlertDialog(
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFF195BA6),
              size: 32,
            ),
            title: Text(
              alert.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0B2E59),
              ),
            ),
            content: SingleChildScrollView(child: Text(alert.body)),
            actions: [
              TextButton(
                onPressed: () => Get.back<void>(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      } else if (Get.currentRoute == AppRoutes.alertasCiudadanas &&
          Get.isRegistered<AlertasCiudadanasController>()) {
        await Get.find<AlertasCiudadanasController>().prepararAlertaNotificada(
          id,
        );
      } else {
        unawaited(
          Get.toNamed<void>(
            AppRoutes.alertasCiudadanas,
            parameters: {'alerta': '$id', 'notificacion': 'true'},
          ),
        );
      }
    } catch (error) {
      debugPrint('No se pudo abrir la notificación: $error');
    }
  }

  @override
  void dispose() {
    _service.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = _service.current;
    return Overlay.wrap(
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              minimum: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    maxHeight: MediaQuery.sizeOf(context).height * 0.65,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    reverseDuration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, -0.12),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    ),
                    child: alert == null
                        ? const SizedBox.shrink()
                        : PushAlertCard(
                            key: ValueKey(alert.notificationId),
                            alert: alert,
                            waitingCount: _service.waitingCount,
                            onOpen: () => _service.open(alert),
                            onDismiss: _service.dismiss,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
