import 'mi_upc_parse.dart';

class CiudadanoAlerta {
  final int idDgoPersonasAlertaApp;
  final int idGenPersona;
  final String documento;
  final String apenom;
  final String codigoInstitucion;
  final String institucion;
  final String tipoUsuario;
  final String direccion;
  final String telefono;
  final String mail;
  final String latitud;
  final String longitud;
  final int idGenEstado;

  const CiudadanoAlerta({
    required this.idDgoPersonasAlertaApp,
    required this.idGenPersona,
    required this.documento,
    required this.apenom,
    required this.codigoInstitucion,
    required this.institucion,
    required this.tipoUsuario,
    required this.direccion,
    required this.telefono,
    required this.mail,
    required this.latitud,
    required this.longitud,
    required this.idGenEstado,
  });

  factory CiudadanoAlerta.fromJson(Map<String, dynamic> json) =>
      CiudadanoAlerta(
        idDgoPersonasAlertaApp: miUpcInt(json['idDgoPersonasAlertaApp']),
        idGenPersona: miUpcInt(json['idGenPersona']),
        documento: json['documento']?.toString() ?? '',
        apenom: json['apenom']?.toString() ?? '',
        codigoInstitucion: json['codigoInstitucion']?.toString() ?? '',
        institucion: json['institucion']?.toString() ?? '',
        tipoUsuario: json['tipoUsuario']?.toString() ?? '',
        direccion: json['direccion']?.toString() ?? '',
        telefono: json['telefono']?.toString() ?? '',
        mail: json['mail']?.toString() ?? '',
        latitud: json['latitud']?.toString() ?? '',
        longitud: json['longitud']?.toString() ?? '',
        idGenEstado: miUpcInt(json['idGenEstado']),
      );
}

class ValidacionCiudadanoAlerta {
  final int codeError;
  final String msj;
  final List<CiudadanoAlerta> datos;

  const ValidacionCiudadanoAlerta({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory ValidacionCiudadanoAlerta.fromJson(Map<String, dynamic> json) {
    final body = miUpcResponse(json, 'ciudadanoAlerta');
    return ValidacionCiudadanoAlerta(
      codeError: miUpcInt(body['codeError']),
      msj: body['msj']?.toString() ?? '',
      datos: miUpcList(body['datos'])
          .map((item) => CiudadanoAlerta.fromJson(miUpcMap(item)))
          .toList(growable: false),
    );
  }
}
