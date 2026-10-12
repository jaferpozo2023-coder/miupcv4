import 'mi_upc_parse.dart';
import 'validacion_ciudadano_alerta_model.dart';

class ServidorPolicialMiUpc {
  final int idGenUsuario;
  final int idDgoDispositivosAlerta;
  final String unidad;
  final String instalacion;
  final String dispositivo;
  final String plataforma;
  final bool dispositivoVinculado;
  final bool tokenRegistrado;
  final bool activo;

  const ServidorPolicialMiUpc({
    required this.idGenUsuario,
    required this.idDgoDispositivosAlerta,
    required this.unidad,
    required this.instalacion,
    required this.dispositivo,
    required this.plataforma,
    required this.dispositivoVinculado,
    required this.tokenRegistrado,
    required this.activo,
  });

  factory ServidorPolicialMiUpc.fromJson(Map<String, dynamic> json) =>
      ServidorPolicialMiUpc(
        idGenUsuario: miUpcInt(json['idGenUsuario']),
        idDgoDispositivosAlerta: miUpcInt(json['idDgoDispositivosAlerta']),
        unidad: json['unidad']?.toString() ?? '',
        instalacion: json['instalacion']?.toString() ?? '',
        dispositivo: json['dispositivo']?.toString() ?? '',
        plataforma: json['plataforma']?.toString() ?? '',
        dispositivoVinculado: miUpcBool(json['dispositivoVinculado']),
        tokenRegistrado: miUpcBool(json['tokenRegistrado']),
        activo: miUpcBool(json['activo']),
      );
}

class PermisoMiUpc {
  final String documento;
  final int idGenPersona;
  final String apenom;
  final bool tienePermiso;
  final bool permisoCiudadano;
  final bool permisoPolicial;
  final List<String> tiposPermiso;
  final CiudadanoAlerta? ciudadano;
  final ServidorPolicialMiUpc? servidorPolicial;

  bool get puedeEnviarAlertas => tienePermiso && permisoCiudadano;

  bool get puedeAtenderAlertas =>
      tienePermiso &&
      permisoPolicial &&
      servidorPolicial != null &&
      servidorPolicial!.activo &&
      servidorPolicial!.idGenUsuario > 0;

  const PermisoMiUpc({
    required this.documento,
    required this.idGenPersona,
    required this.apenom,
    required this.tienePermiso,
    required this.permisoCiudadano,
    required this.permisoPolicial,
    required this.tiposPermiso,
    required this.ciudadano,
    required this.servidorPolicial,
  });

  factory PermisoMiUpc.fromJson(Map<String, dynamic> json) {
    final citizen = json['ciudadano'];
    final police = json['servidorPolicial'];
    return PermisoMiUpc(
      documento: json['documento']?.toString() ?? '',
      idGenPersona: miUpcInt(json['idGenPersona']),
      apenom: json['apenom']?.toString() ?? '',
      tienePermiso: miUpcBool(json['tienePermiso']),
      permisoCiudadano: miUpcBool(json['permisoCiudadano']),
      permisoPolicial: miUpcBool(json['permisoPolicial']),
      tiposPermiso: miUpcList(json['tiposPermiso'])
          .map((item) => item.toString())
          .toList(growable: false),
      ciudadano: citizen is Map
          ? CiudadanoAlerta.fromJson(miUpcMap(citizen))
          : null,
      servidorPolicial: police is Map
          ? ServidorPolicialMiUpc.fromJson(miUpcMap(police))
          : null,
    );
  }
}

class ConsultaPermisosMiUpc {
  final int codeError;
  final String msj;
  final List<PermisoMiUpc> datos;

  const ConsultaPermisosMiUpc({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory ConsultaPermisosMiUpc.fromJson(Map<String, dynamic> json) {
    final body = miUpcResponse(json, 'permisosMiUpc');
    final codeError = int.tryParse(body['codeError'].toString());
    if (codeError == null || (codeError == 0 && body['datos'] is! List)) {
      throw const FormatException(
        'Respuesta incompleta del servicio de permisos Mi UPC.',
      );
    }
    return ConsultaPermisosMiUpc(
      codeError: codeError,
      msj: body['msj']?.toString() ?? '',
      datos: miUpcList(body['datos'])
          .map((item) => PermisoMiUpc.fromJson(miUpcMap(item)))
          .toList(growable: false),
    );
  }
}
