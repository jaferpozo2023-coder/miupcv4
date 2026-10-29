import 'mi_upc_parse.dart';

class PersonalHotelRegistrado {
  final int idDgoHuespedesApp;
  final int idDgoPersonasAlertaApp;
  final int idDgoHotelesApp;
  final String codigoInstitucion;
  final String institucion;
  final String documento;
  final String nombres;
  final String nacionalidad;
  final String fechaRegistro;

  const PersonalHotelRegistrado({
    required this.idDgoHuespedesApp,
    required this.idDgoPersonasAlertaApp,
    required this.idDgoHotelesApp,
    required this.codigoInstitucion,
    required this.institucion,
    required this.documento,
    required this.nombres,
    required this.nacionalidad,
    required this.fechaRegistro,
  });

  factory PersonalHotelRegistrado.fromJson(Map<String, dynamic> json) =>
      PersonalHotelRegistrado(
        idDgoHuespedesApp: miUpcInt(json['idDgoHuespedesApp']),
        idDgoPersonasAlertaApp: miUpcInt(json['idDgoPersonasAlertaApp']),
        idDgoHotelesApp: miUpcInt(json['idDgoHotelesApp']),
        codigoInstitucion: json['codigoInstitucion']?.toString() ?? '',
        institucion: json['institucion']?.toString() ?? '',
        documento: json['documento']?.toString() ?? '',
        nombres: json['nombres']?.toString() ?? '',
        nacionalidad: json['nacionalidad']?.toString() ?? '',
        fechaRegistro: json['fechaRegistro']?.toString() ?? '',
      );
}

class RespuestaRegistroPersonalHotel {
  final int codeError;
  final String msj;
  final PersonalHotelRegistrado? datos;

  const RespuestaRegistroPersonalHotel({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory RespuestaRegistroPersonalHotel.fromJson(
    Map<String, dynamic> json,
  ) {
    final body = miUpcResponse(json, 'huespedHotel');
    final codeError = miUpcInt(body['codeError']);
    final datos = body['datos'];
    if (codeError == 0 && datos is! Map) {
      throw const FormatException(
        'Respuesta incompleta al registrar personal del hotel.',
      );
    }
    return RespuestaRegistroPersonalHotel(
      codeError: codeError,
      msj: body['msj']?.toString() ?? '',
      datos: datos is Map
          ? PersonalHotelRegistrado.fromJson(miUpcMap(datos))
          : null,
    );
  }
}
