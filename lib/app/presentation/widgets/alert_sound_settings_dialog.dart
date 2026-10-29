import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../core/services/alert_audio_platform.dart';
import '../../core/services/local_push_notifications.dart';
import '../../core/services/push_notification_service.dart';

class AlertSoundSettingsDialog extends StatefulWidget {
  const AlertSoundSettingsDialog({super.key});

  @override
  State<AlertSoundSettingsDialog> createState() =>
      _AlertSoundSettingsDialogState();
}

class _AlertSoundSettingsDialogState extends State<AlertSoundSettingsDialog>
    with WidgetsBindingObserver {
  bool _loading = true;
  bool _notificationsEnabled = false;
  bool _priorityEnabled = false;
  bool _testing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      final status = await AlertAudioPlatform.status();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _notificationsEnabled = AlertAudioPlatform.isAndroid
            ? status['notificationsEnabled'] == true &&
                  status['channelEnabled'] == true &&
                  status['soundEnabled'] == true
            : settings.authorizationStatus == AuthorizationStatus.authorized;
        _priorityEnabled = AlertAudioPlatform.isAndroid
            ? status['policyAccess'] == true && status['bypassDnd'] == true
            : settings.criticalAlert == AppleNotificationSetting.enabled;
        _error = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No fue posible consultar los permisos del dispositivo.';
        });
      }
    }
  }

  Future<void> _permission() async {
    try {
      await PushNotificationService.instance.requestPermissionAndSubscribe();
      await _refresh();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'No fue posible solicitar el permiso.');
      }
    }
  }

  Future<void> _priority() async {
    try {
      await LocalPushNotifications().requestPriorityAccess();
      await _refresh();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Abra los ajustes de No molestar y permita las alertas de MI UPC.',
        );
      }
    }
  }

  Future<void> _test() async {
    setState(() => _testing = true);
    try {
      await PushNotificationService.instance.testSound();
      await Future<void>.delayed(const Duration(seconds: 4));
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No fue posible reproducir la prueba. Reinstale la versión actual de la app.',
        );
      }
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(
      Icons.volume_up_rounded,
      color: Color(0xFF195BA6),
      size: 32,
    ),
    title: const Text(
      'Sonido de alertas',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0B2E59),
      ),
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else ...[
            _status('Notificaciones con sonido', _notificationsEnabled),
            const SizedBox(height: 10),
            _status('Sonido prioritario', _priorityEnabled),
            const SizedBox(height: 16),
            Text(
              AlertAudioPlatform.isAndroid
                  ? 'La alerta usa el volumen de alarma, lo eleva durante el aviso y lo restaura al terminar. Permita el acceso a No molestar para recibir avisos prioritarios.'
                  : LocalPushNotifications.iosCriticalAlertsEnabled
                  ? 'Active las alertas críticas en los ajustes del iPhone para recibir el sonido prioritario.'
                  : 'El sonido prioritario aún no está disponible en esta versión para iPhone. Las alertas usan el sonido configurado y los ajustes de sonido del teléfono.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFBD303D))),
            ],
            const SizedBox(height: 16),
            if (!_notificationsEnabled)
              TextButton(
                onPressed: _permission,
                child: const Text('Permitir notificaciones'),
              ),
            if (AlertAudioPlatform.isAndroid && !_priorityEnabled)
              TextButton(
                onPressed: _priority,
                child: const Text('Permitir en No molestar'),
              ),
            FilledButton.icon(
              onPressed: _notificationsEnabled && !_testing ? _test : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(_testing ? 'Reproduciendo…' : 'Probar sonido'),
            ),
          ],
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cerrar'),
      ),
    ],
  );

  Widget _status(String label, bool enabled) => Row(
    children: [
      Icon(
        enabled ? Icons.check_circle_outline : Icons.info_outline,
        size: 20,
        color: enabled ? const Color(0xFF247448) : const Color(0xFF95610B),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '$label: ${enabled ? 'activo' : 'pendiente'}',
          style: const TextStyle(fontSize: 13),
        ),
      ),
    ],
  );
}
