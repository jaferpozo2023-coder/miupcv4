import 'dart:convert';

import '../../providers_impl.dart' show UrlApiProvider;

typedef MiUpcPost = Future<String> Function({
  required String segmento,
  required Map<String, dynamic> body,
});

/// Transporte compartido; cada endpoint conserva su propio provider y modelo.
class MiUpcApiClient {
  final MiUpcPost _post;

  MiUpcApiClient({MiUpcPost? post}) : _post = post ?? _defaultPost;

  static Future<String> _defaultPost({
    required String segmento,
    required Map<String, dynamic> body,
  }) => UrlApiProvider.post(segmento: segmento, body: body);

  Future<Map<String, dynamic>> post({
    required String opc,
    required Map<String, dynamic> parametros,
  }) async {
    final response = await _post(
      segmento: 'polco/index.php',
      body: {
        ...parametros,
        'modulo': 'ddced13c854fb2c03d6e01ce5bfd7e08',
        'opc': opc,
      },
    );
    final decoded = jsonDecode(response);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Respuesta inválida del servicio Mi UPC.');
    }
    return decoded;
  }
}
