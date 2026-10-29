import 'dart:typed_data';

import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'alert_audio_platform.dart';
import 'push_alert.dart';

/// Presentación del sistema: también se utiliza desde el isolate de FCM.
class LocalPushNotifications {
  static const channelId = 'mi_upc_alertas_v2';
  static const foregroundChannelId = 'mi_upc_primer_plano_v2';
  static const soundName = 'alerta';
  // Activar únicamente cuando Apple y el perfil de firma incluyan el entitlement.
  static const iosCriticalAlertsEnabled = bool.fromEnvironment(
    'IOS_CRITICAL_ALERTS_ENABLED',
  );
  static final vibrationPattern = Int64List.fromList([0, 250, 120, 350]);

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize({
    DidReceiveNotificationResponseCallback? onResponse,
  }) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: onResponse,
    );
    await configureChannels();
    await AlertAudioPlatform.configure();
  }

  Future<void> configureChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final bypass = await android?.hasNotificationPolicyAccess() ?? false;
    for (final channel in [
      AndroidNotificationChannel(
        channelId,
        'Alertas MI UPC',
        description: 'Alertas ciudadanas con sonido y vibración.',
        importance: Importance.high,
        sound: const RawResourceAndroidNotificationSound(soundName),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        bypassDnd: bypass,
        vibrationPattern: vibrationPattern,
      ),
      AndroidNotificationChannel(
        foregroundChannelId,
        'Alertas MI UPC en primer plano',
        description: 'Alertas ciudadanas con sonido y vibración.',
        importance: Importance.defaultImportance,
        sound: const RawResourceAndroidNotificationSound(soundName),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        vibrationPattern: vibrationPattern,
      ),
    ]) {
      await android?.createNotificationChannel(channel);
    }
  }

  Future<PushAlert?> initialAlert() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp == true
        ? PushAlert.fromPayload(details?.notificationResponse?.payload)
        : null;
  }

  Future<void> show(PushAlert alert, {required bool foreground}) async {
    await AlertAudioPlatform.prepare();
    await _plugin.show(
      id: alert.notificationId,
      title: alert.title,
      body: alert.body,
      payload: alert.toPayload(),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          foreground ? foregroundChannelId : channelId,
          'Alertas MI UPC',
          icon: 'ic_notification',
          color: const Color(0xFF195BA6),
          importance: foreground
              ? Importance.defaultImportance
              : Importance.high,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound(soundName),
          audioAttributesUsage: AudioAttributesUsage.alarm,
          enableVibration: true,
          vibrationPattern: vibrationPattern,
          styleInformation: BigTextStyleInformation(alert.body),
          category: AndroidNotificationCategory.alarm,
          onlyAlertOnce: true,
        ),
        iOS: DarwinNotificationDetails(
          sound: '$soundName.wav',
          interruptionLevel: iosCriticalAlertsEnabled
              ? InterruptionLevel.critical
              : InterruptionLevel.active,
          criticalSoundVolume: iosCriticalAlertsEnabled ? 1.0 : null,
          presentSound: true,
          presentAlert: !foreground,
          presentBanner: !foreground,
          presentList: true,
          presentBadge: false,
          threadIdentifier: 'mi_upc_alertas',
        ),
      ),
    );
  }

  Future<void> cancel(PushAlert alert) =>
      _plugin.cancel(id: alert.notificationId);

  Future<void> requestPriorityAccess() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationPolicyAccess();
    await configureChannels();
  }
}
