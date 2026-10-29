import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pne/app/core/services/local_push_notifications.dart';
import 'package:pne/app/core/services/push_alert.dart';
import 'package:pne/app/core/services/push_notification_service.dart';

RemoteMessage message(String id, {int? alertId, bool notification = true}) =>
    RemoteMessage(
      messageId: id,
      notification: notification
          ? const RemoteNotification(
              title: 'Nueva alerta',
              body: 'Revisar evento',
            )
          : null,
      data: {
        if (alertId != null) 'idDgoAlertasMovilCiu': '$alertId',
        if (!notification) 'titulo': 'Nueva alerta',
        if (!notification) 'cuerpo': 'Revisar evento',
      },
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AndroidFlutterLocalNotificationsPlugin.registerWith();

  test(
    'normaliza payloads de Firebase y conserva el destino al tocar el aviso',
    () {
      final alert = PushAlert.fromRemoteMessage(message('fcm-1', alertId: 42));
      final dataAlert = PushAlert.fromRemoteMessage(
        message('fcm-2', alertId: 42, notification: false),
      );
      expect(dataAlert.title, alert.title);
      expect(dataAlert.body, alert.body);
      expect(PushAlert.fromPayload(alert.toPayload())!.alertId, 42);
      expect(PushAlert.fromPayload('{broken'), isNull);
      expect(PushAlert.fromPayload('{"title":1}'), isNull);
      expect(alert.notificationId, inInclusiveRange(0, 0x7fffffff));
      expect(
        PushAlert.fromRemoteMessage(message('fcm-1', alertId: 42))
            .notificationId,
        alert.notificationId,
      );
    },
  );

  test('ignora campos vacíos e identificadores de alerta inválidos', () {
    final alert = PushAlert.fromRemoteMessage(
      const RemoteMessage(
        notification: RemoteNotification(title: '  ', body: ''),
        data: {
          'title': 'Seguimiento',
          'body': 'Texto completo',
          'idDgoAlertasMovilCiu': '-1',
        },
      ),
    );
    expect(alert.title, 'Seguimiento');
    expect(alert.body, 'Texto completo');
    expect(alert.alertId, isNull);
    expect(alert.isFollowUp, isTrue);
    expect(
      PushAlert.hasVisibleContent(const RemoteMessage(data: {'sync': 'true'})),
      isFalse,
    );
  });

  test('encola alertas y evita repetir el mismo mensaje de FCM', () async {
    final service = PushNotificationService();
    addTearDown(service.dispose);
    await service.receiveForeground(message('first', alertId: 11));
    await service.receiveForeground(message('second', alertId: 12));
    await service.receiveForeground(message('second', alertId: 12));
    expect(service.current!.alertId, 11);
    expect(service.waitingCount, 1);
    service.dismiss();
    expect(service.current!.alertId, 12);
    service.dismiss();
    expect(service.current, isNull);
  });

  test(
    'espera a que termine el inicio antes de navegar y consume una sola vez',
    () async {
      final service = PushNotificationService();
      addTearDown(service.dispose);
      await service.receiveForeground(message('first', alertId: 11));
      // El toque del sistema reconstruye el contenido desde JSON.
      final tapped = PushAlert.fromPayload(service.current!.toPayload())!;
      service.open(tapped);
      expect(service.current, isNull);
      expect(service.takePendingOpen(), isNull);
      service.markNavigationReady();
      expect(service.takePendingOpen()!.alertId, 11);
      expect(service.takePendingOpen(), isNull);
    },
  );

  testWidgets('los avisos generales caducan y las alertas esperan una acción', (
    tester,
  ) async {
    final service = PushNotificationService();
    addTearDown(service.dispose);
    await service.receiveForeground(message('general'));
    await tester.pump(const Duration(seconds: 13));
    expect(service.current, isNull);
    await service.receiveForeground(message('alert', alertId: 99));
    await tester.pump(const Duration(seconds: 30));
    expect(service.current!.alertId, 99);
    service.dismiss();
  });

  test(
    'configura sonido, vibración y presentación del sistema sin doble banner',
    () async {
      const channel = MethodChannel(
        'dexterous.com/flutter/local_notifications',
      );
      final calls = <MethodCall>[];
      const audio = MethodChannel('mi_upc/alert_audio');
      final audioCalls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(audio, (call) async {
            audioCalls.add(call);
            return null;
          });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'initialize') return true;
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(audio, null);
      });
      final notifications = LocalPushNotifications();
      await notifications.initialize();
      final channels = calls.where(
        (call) => call.method == 'createNotificationChannel',
      );
      expect(channels, hasLength(2));
      for (final call in channels) {
        final details = call.arguments as Map;
        expect(details['sound'], 'alerta');
        expect(details['audioAttributesUsage'], 4);
        expect(details['enableVibration'], isTrue);
        expect(details['vibrationPattern'], [0, 250, 120, 350]);
      }
      final alert = PushAlert.fromRemoteMessage(message('system', alertId: 77));
      await notifications.show(alert, foreground: true);
      final foreground = calls.last.arguments as Map;
      expect(
        foreground['platformSpecifics']['channelId'],
        'mi_upc_primer_plano_v2',
      );
      expect(foreground['platformSpecifics']['importance'], 3);
      expect(
        PushAlert.fromPayload(foreground['payload'] as String)!.alertId,
        77,
      );
      await notifications.show(alert, foreground: false);
      final background = calls.last.arguments as Map;
      expect(background['platformSpecifics']['channelId'], 'mi_upc_alertas_v2');
      expect(background['platformSpecifics']['importance'], 4);
      expect(background['platformSpecifics']['category'], 'alarm');
      expect(background['platformSpecifics']['onlyAlertOnce'], isTrue);
      expect(audioCalls.map((call) => call.method), ['configure', 'prepare', 'prepare']);
    },
  );
}
