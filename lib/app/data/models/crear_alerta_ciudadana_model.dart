import 'mi_upc_parse.dart';

class AlertaCiudadanaCreada {
  final int idDgoAlertasMovilCiu;
  final String estadoAlerta;
  final String fechaAlerta;
  final String institucion;
  final int notificacionesEnviadas;

  const AlertaCiudadanaCreada({
    required this.idDgoAlertasMovilCiu,
    required this.estadoAlerta,
    required this.fechaAlerta,
    required this.institucion,
    required this.notificacionesEnviadas,
  });

  factory AlertaCiudadanaCreada.fromJson(Map<String, dynamic> json) =>
      AlertaCiudadanaCreada(
        idDgoAlertasMovilCiu: miUpcInt(json['idDgoAlertasMovilCiu']),
        estadoAlerta: json['estadoAlerta']?.toString() ?? '',
        fechaAlerta: json['fechaAlerta']?.toString() ?? '',
        institucion: json['institucion']?.toString() ?? '',
        notificacionesEnviadas: miUpcInt(json['notificacionesEnviadas']),
      );
}

class RespuestaAlertaCiudadana {
  final int codeError;
  final String msj;
  final AlertaCiudadanaCreada? datos;

  const RespuestaAlertaCiudadana({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory RespuestaAlertaCiudadana.fromJson(Map<String, dynamic> json) {
    final body = miUpcResponse(json, 'alertaCiudadana');
    final data = body['datos'];
    return RespuestaAlertaCiudadana(
      codeError: miUpcInt(body['codeError']),
      msj: body['msj']?.toString() ?? '',
      datos: data is Map
          ? AlertaCiudadanaCreada.fromJson(miUpcMap(data))
          : null,
    );
  }
}
