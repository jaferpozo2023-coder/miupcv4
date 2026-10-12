import 'detalle_alerta_ciudadana_model.dart';
import 'mi_upc_parse.dart';

class AlertasAtendidasPolicia {
  final int codeError;
  final String msj;
  final List<HistorialAlertasPolicia> datos;

  const AlertasAtendidasPolicia({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory AlertasAtendidasPolicia.fromJson(Map<String, dynamic> json) {
    if (json['alertasAtendidasPolicia'] is! Map) {
      throw const FormatException('Respuesta inválida del historial policial.');
    }
    final body = miUpcMap(json['alertasAtendidasPolicia']);
    if (body['datos'] is! List && miUpcInt(body['codeError']) == 0) {
      throw const FormatException(
        'El historial policial no incluyó sus datos.',
      );
    }
    return AlertasAtendidasPolicia(
      codeError: miUpcInt(body['codeError']),
      msj: body['msj']?.toString() ?? '',
      datos: miUpcList(body['datos'])
          .map((item) => HistorialAlertasPolicia.fromJson(miUpcMap(item)))
          .toList(),
    );
  }
}

class HistorialAlertasPolicia {
  final int idGenUsuario;
  final String documento;
  final String servidorPolicial;
  final int totalAtendidas;
  final List<DetalleAlertaCiudadana> alertas;

  const HistorialAlertasPolicia({
    required this.idGenUsuario,
    required this.documento,
    required this.servidorPolicial,
    required this.totalAtendidas,
    required this.alertas,
  });

  factory HistorialAlertasPolicia.fromJson(Map<String, dynamic> json) =>
      HistorialAlertasPolicia(
        idGenUsuario: miUpcInt(json['idGenUsuario']),
        documento: json['documento']?.toString() ?? '',
        servidorPolicial: json['servidorPolicial']?.toString() ?? '',
        totalAtendidas: miUpcInt(json['totalAtendidas']),
        alertas: miUpcList(json['alertas'])
            .map((item) => DetalleAlertaCiudadana.fromJson(miUpcMap(item)))
            .where((item) => item.id > 0)
            .toList(),
      );
}
