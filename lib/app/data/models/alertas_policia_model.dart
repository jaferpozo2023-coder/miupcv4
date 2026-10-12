import 'detalle_alerta_ciudadana_model.dart';
import 'mi_upc_parse.dart';

class ConsultaAlertasPolicia {
  final int codeError;
  final String msj;
  final List<BandejaAlertasPolicia> datos;

  const ConsultaAlertasPolicia({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory ConsultaAlertasPolicia.fromJson(Map<String, dynamic> json) {
    if (json['alertasPolicia'] is! Map) {
      throw const FormatException('Respuesta inválida de la bandeja policial.');
    }
    final body = miUpcMap(json['alertasPolicia']);
    if (body['datos'] is! List && miUpcInt(body['codeError']) == 0) {
      throw const FormatException('La bandeja policial no incluyó sus datos.');
    }
    return ConsultaAlertasPolicia(
      codeError: miUpcInt(body['codeError']),
      msj: body['msj']?.toString() ?? '',
      datos: miUpcList(body['datos'])
          .map((item) => BandejaAlertasPolicia.fromJson(miUpcMap(item)))
          .toList(),
    );
  }
}

class BandejaAlertasPolicia {
  final int idGenUsuario;
  final String documento;
  final String servidorPolicial;
  final int totalPendientes;
  final int totalAtendidas;
  final int total;
  final List<DetalleAlertaCiudadana> pendientes;
  final List<DetalleAlertaCiudadana> atendidas;

  const BandejaAlertasPolicia({
    required this.idGenUsuario,
    required this.documento,
    required this.servidorPolicial,
    required this.totalPendientes,
    required this.totalAtendidas,
    required this.total,
    required this.pendientes,
    required this.atendidas,
  });

  factory BandejaAlertasPolicia.fromJson(Map<String, dynamic> json) =>
      BandejaAlertasPolicia(
        idGenUsuario: miUpcInt(json['idGenUsuario']),
        documento: json['documento']?.toString() ?? '',
        servidorPolicial: json['servidorPolicial']?.toString() ?? '',
        totalPendientes: miUpcInt(json['totalPendientes']),
        totalAtendidas: miUpcInt(json['totalAtendidas']),
        total: miUpcInt(json['total']),
        pendientes: miUpcList(json['pendientes'])
            .map((item) => DetalleAlertaCiudadana.fromJson(miUpcMap(item)))
            .where((item) => item.id > 0)
            .toList(),
        atendidas: miUpcList(json['atendidas'])
            .map((item) => DetalleAlertaCiudadana.fromJson(miUpcMap(item)))
            .where((item) => item.id > 0)
            .toList(),
      );
}
