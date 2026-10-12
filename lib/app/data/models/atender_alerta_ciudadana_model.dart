import 'mi_upc_parse.dart';

class AtencionAlertaCiudadana {
  final int idDgoAlertasMovilCiu;
  final int idGenUsuarioAtiende;
  final String estadoAlerta;
  final String estadoVerificacion;
  final String fechaAtencion;

  const AtencionAlertaCiudadana({
    required this.idDgoAlertasMovilCiu,
    required this.idGenUsuarioAtiende,
    required this.estadoAlerta,
    required this.estadoVerificacion,
    required this.fechaAtencion,
  });

  factory AtencionAlertaCiudadana.fromJson(Map<String, dynamic> json) =>
      AtencionAlertaCiudadana(
        idDgoAlertasMovilCiu: miUpcInt(json['idDgoAlertasMovilCiu']),
        idGenUsuarioAtiende: miUpcInt(json['idGenUsuarioAtiende']),
        estadoAlerta: json['estadoAlerta']?.toString() ?? '',
        estadoVerificacion: json['estadoVerificacion']?.toString() ?? '',
        fechaAtencion: json['fechaAtencion']?.toString() ?? '',
      );
}

class RespuestaAtencionAlertaCiudadana {
  final int codeError;
  final String msj;
  final AtencionAlertaCiudadana? datos;

  const RespuestaAtencionAlertaCiudadana({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory RespuestaAtencionAlertaCiudadana.fromJson(Map<String, dynamic> json) {
    final body = miUpcResponse(json, 'atencionAlertaCiudadana');
    final data = body['datos'];
    return RespuestaAtencionAlertaCiudadana(
      codeError: miUpcInt(body['codeError']),
      msj: body['msj']?.toString() ?? '',
      datos: data is Map
          ? AtencionAlertaCiudadana.fromJson(miUpcMap(data))
          : null,
    );
  }
}
