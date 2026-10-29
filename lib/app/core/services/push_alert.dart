import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Contenido visible y destino de una notificación de MI UPC.
class PushAlert {
  const PushAlert({
    required this.title,
    required this.body,
    required this.notificationId,
    this.messageId,
    this.alertId,
  });

  factory PushAlert.fromRemoteMessage(RemoteMessage message) {
    String? text(Object? value) {
      final result = value?.toString().trim();
      return result == null || result.isEmpty ? null : result;
    }

    final title =
        text(message.notification?.title) ??
        text(message.data['titulo']) ??
        text(message.data['title']) ??
        'MI UPC';
    final body =
        text(message.notification?.body) ??
        text(message.data['cuerpo']) ??
        text(message.data['body']) ??
        'Recibiste una nueva notificación.';
    final id = int.tryParse(
      message.data['idDgoAlertasMovilCiu']?.toString() ?? '',
    );
    final key =
        message.messageId ??
        '${message.sentTime?.millisecondsSinceEpoch}|$title|$body|$id';
    // Identificador estable, positivo y compatible con Android (32 bits).
    var hash = 0;
    for (final code in key.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return PushAlert(
      title: title,
      body: body,
      notificationId: hash,
      messageId: message.messageId,
      alertId: id != null && id > 0 ? id : null,
    );
  }

  final String title;
  final String body;
  final String? messageId;
  final int notificationId;
  final int? alertId;

  bool get isUrgent => title.toUpperCase() == 'WEB';
  bool get isFollowUp => title.toUpperCase() == 'SEGUIMIENTO';

  String toPayload() => jsonEncode({
    'title': title,
    'body': body,
    'messageId': messageId,
    'notificationId': notificationId,
    'alertId': alertId,
  });

  static PushAlert? fromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    try {
      final json = jsonDecode(payload);
      if (json is! Map<String, dynamic> ||
          json['title'] is! String ||
          json['body'] is! String ||
          json['notificationId'] is! int) {
        return null;
      }
      final id = int.tryParse(json['alertId']?.toString() ?? '');
      return PushAlert(
        title: json['title'] as String,
        body: json['body'] as String,
        notificationId: json['notificationId'] as int,
        messageId: json['messageId'] as String?,
        alertId: id != null && id > 0 ? id : null,
      );
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static bool hasVisibleContent(RemoteMessage message) =>
      message.notification != null ||
      [
        'titulo',
        'title',
        'cuerpo',
        'body',
        'idDgoAlertasMovilCiu',
      ].any((key) => message.data[key]?.toString().trim().isNotEmpty ?? false);
}
