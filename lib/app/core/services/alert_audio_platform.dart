import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Ajuste temporal del volumen de alarma: no modifica el volumen multimedia.
class AlertAudioPlatform {
  static const _channel = MethodChannel('mi_upc/alert_audio');

  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<void> configure() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod<void>('configure');
    } on MissingPluginException {
      debugPrint('Reinstale la app para activar la recepción directa de alertas.');
    } on PlatformException catch (error) {
      debugPrint('No se pudo configurar la recepción directa: ${error.code}');
    }
  }

  static Future<void> prepare() async {
    if (!isAndroid) return;
    try {
      await _channel.invokeMethod<void>('prepare');
    } on MissingPluginException {
      debugPrint(
        'Reinstale la app para activar el módulo de audio prioritario.',
      );
    } on PlatformException catch (error) {
      debugPrint('No se pudo preparar el audio prioritario: ${error.code}');
    }
  }

  static Future<Map<String, dynamic>> status() async {
    if (!isAndroid) return {};
    final result = await _channel.invokeMapMethod<String, dynamic>('status');
    return result ?? {};
  }
}
