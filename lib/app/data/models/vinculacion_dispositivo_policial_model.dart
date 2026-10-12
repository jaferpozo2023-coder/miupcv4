import 'mi_upc_parse.dart';

class DispositivoPolicial {
  final int idDgoDispositivosAlerta;
  final int idGenUsuario;
  final int idGenPersona;
  final String documento;
  final String unidad;
  final String instalacion;
  final String dispositivo;
  final String plataforma;
  final bool tokenRegistrado;
  final bool dispositivoVinculado;

  const DispositivoPolicial({
    required this.idDgoDispositivosAlerta,
    required this.idGenUsuario,
    required this.idGenPersona,
    required this.documento,
    required this.unidad,
    required this.instalacion,
    required this.dispositivo,
    required this.plataforma,
    required this.tokenRegistrado,
    required this.dispositivoVinculado,
  });

  factory DispositivoPolicial.fromJson(Map<String, dynamic> json) =>
      DispositivoPolicial(
        idDgoDispositivosAlerta: miUpcInt(json['idDgoDispositivosAlerta']),
        idGenUsuario: miUpcInt(json['idGenUsuario']),
        idGenPersona: miUpcInt(json['idGenPersona']),
        documento: json['documento']?.toString() ?? '',
        unidad: json['unidad']?.toString() ?? '',
        instalacion: json['instalacion']?.toString() ?? '',
        dispositivo: json['dispositivo']?.toString() ?? '',
        plataforma: json['plataforma']?.toString() ?? '',
        tokenRegistrado: miUpcBool(json['tokenRegistrado']),
        dispositivoVinculado: miUpcBool(json['dispositivoVinculado']),
      );
}

class VinculacionDispositivoPolicial {
  final int codeError;
  final String msj;
  final DispositivoPolicial? datos;

  const VinculacionDispositivoPolicial({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory VinculacionDispositivoPolicial.fromJson(Map<String, dynamic> json) {
    final body = miUpcResponse(json, 'dispositivoPolicial');
    final data = body['datos'];
    return VinculacionDispositivoPolicial(
      codeError: miUpcInt(body['codeError']),
      msj: body['msj']?.toString() ?? '',
      datos: data is Map ? DispositivoPolicial.fromJson(miUpcMap(data)) : null,
    );
  }
}
