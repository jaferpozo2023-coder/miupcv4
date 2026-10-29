import 'dart:async';
import 'dart:collection';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_push_notifications.dart';
import 'push_alert.dart';

/// Una sola recepción para toda la app, independiente de la pantalla activa.
class PushNotificationService extends ChangeNotifier {
  PushNotificationService({LocalPushNotifications? notifications})
    : _notifications = notifications ?? LocalPushNotifications();

  static final instance = PushNotificationService();
  final LocalPushNotifications _notifications;
  final Queue<PushAlert> _queue = Queue<PushAlert>();
  final Set<String> _receivedIds = <String>{};
  final List<StreamSubscription<RemoteMessage>> _subscriptions = [];
  Future<void>? _initialization;
  Timer? _dismissTimer;
  PushAlert? _current;
  PushAlert? _pendingOpen;
  bool _navigationReady = false;
  bool _localReady = false;

  PushAlert? get current => _current;
  PushAlert? get pendingOpen => _navigationReady ? _pendingOpen : null;
  int get waitingCount => _queue.length;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen((message) {
        unawaited(receiveForeground(message));
      }),
    );
    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        open(PushAlert.fromRemoteMessage(message));
      }),
    );
    try {
      await _notifications.initialize(
        onResponse: (response) {
          final alert = PushAlert.fromPayload(response.payload);
          if (alert != null) open(alert);
        },
      );
      _localReady = true;
      final localInitial = await _notifications.initialAlert();
      if (localInitial != null) open(localInitial);
    } catch (error) {
      debugPrint('No se pudo configurar el sonido de notificaciones: $error');
    }
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) open(PushAlert.fromRemoteMessage(initial));
    } catch (error) {
      debugPrint('No se pudo recuperar la notificación inicial: $error');
    }
  }

  Future<void> requestPermissionAndSubscribe() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: LocalPushNotifications.iosCriticalAlertsEnabled,
    );
    await messaging.subscribeToTopic('upceventos1');
  }

  Future<void> receiveForeground(RemoteMessage message) async {
    if (!PushAlert.hasVisibleContent(message)) return;
    final messageId = message.messageId;
    if (messageId != null && !_receivedIds.add(messageId)) return;
    if (_receivedIds.length > 100) _receivedIds.remove(_receivedIds.first);
    final alert = PushAlert.fromRemoteMessage(message);
    _queue.add(alert);
    _showNext();
    if (!_localReady) return;
    try {
      await _notifications.show(alert, foreground: true);
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final settings = await FirebaseMessaging.instance
            .getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          await HapticFeedback.vibrate();
        }
      }
    } catch (error) {
      debugPrint('No se pudo reproducir el aviso de notificación: $error');
    }
  }

  Future<void> testSound() async {
    await _notifications.show(
      PushAlert(
        title: 'Prueba de sonido MI UPC',
        body: 'Esta es una prueba del sonido de las alertas.',
        notificationId: DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      ),
      foreground: true,
    );
  }

  void _showNext() {
    if (_current != null || _queue.isEmpty) {
      notifyListeners();
      return;
    }
    _current = _queue.removeFirst();
    // Las alertas ciudadanas permanecen visibles hasta que se atiendan o cierren.
    if (_current!.alertId == null) {
      _dismissTimer = Timer(const Duration(seconds: 12), dismiss);
    }
    notifyListeners();
  }

  void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _current = null;
    _showNext();
  }

  void open(PushAlert alert) {
    _pendingOpen = alert;
    _queue.removeWhere((item) => item.notificationId == alert.notificationId);
    if (_current?.notificationId == alert.notificationId) dismiss();
    notifyListeners();
  }

  void markNavigationReady() {
    _navigationReady = true;
    notifyListeners();
  }

  PushAlert? takePendingOpen() {
    final alert = pendingOpen;
    if (alert != null) {
      _pendingOpen = null;
      if (_localReady) {
        unawaited(
          _notifications.cancel(alert).catchError((Object error) {
            debugPrint('No se pudo limpiar la notificación atendida: $error');
          }),
        );
      }
    }
    return alert;
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }
}
