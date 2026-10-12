int miUpcInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

bool miUpcBool(dynamic value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true' || value?.toString() == '1';
}

Map<String, dynamic> miUpcMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

List<dynamic> miUpcList(dynamic value) => value is List ? value : <dynamic>[];

Map<String, dynamic> miUpcResponse(Map<String, dynamic> json, String key) {
  final body = miUpcMap(json[key]);
  if (!body.containsKey('codeError')) {
    throw const FormatException('Respuesta incompleta del servicio Mi UPC.');
  }
  return body;
}
