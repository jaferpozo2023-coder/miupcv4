import 'mi_upc_parse.dart';

class ConsultaAlertasGeneradasCiudadano {
  final int codeError;
  final String msj;
  final List<AlertasGeneradasCiudadano> datos;

  const ConsultaAlertasGeneradasCiudadano({
    required this.codeError,
    required this.msj,
    required this.datos,
  });

  factory ConsultaAlertasGeneradasCiudadano.fromJson(
    Map<String, dynamic> json,
  ) {
    final body = miUpcResponse(json, 'alertasCiudadano');
    final codeError = int.tryParse(body['codeError'].toString());
    if (codeError == null || (codeError == 0 && body['datos'] is! List)) {
      throw const FormatException(
        'Respuesta incompleta de las alertas generadas por el ciudadano.',
      );
    }
    return ConsultaAlertasGeneradasCiudadano(
      codeError: codeError,
      msj: body['msj']?.toString() ?? '',
      datos: miUpcList(body['datos'])
          .map((item) => AlertasGeneradasCiudadano.fromJson(miUpcMap(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'alertasCiudadano': {
      'codeError': codeError,
      'msj': msj,
      'datos': datos.map((item) => item.toJson()).toList(),
    },
  };
}

class AlertasGeneradasCiudadano {
  final String documento;
  final int idGenPersona;
  final String apenom;
  final int totalAlertas;
  final int totalPendientes;
  final int totalEnAtencion;
  final int totalAtendidas;
  final List<AlertaGeneradaCiudadano> pendientes;
  final List<AlertaGeneradaCiudadano> enAtencion;
  final List<AlertaGeneradaCiudadano> atendidas;
  final List<AlertaGeneradaCiudadano> alertas;

  const AlertasGeneradasCiudadano({
    required this.documento,
    required this.idGenPersona,
    required this.apenom,
    required this.totalAlertas,
    required this.totalPendientes,
    required this.totalEnAtencion,
    required this.totalAtendidas,
    required this.pendientes,
    required this.enAtencion,
    required this.atendidas,
    required this.alertas,
  });

  /// La respuesta repite las alertas en la lista general y por estado.
  List<AlertaGeneradaCiudadano> get todas {
    final porId = <int, AlertaGeneradaCiudadano>{};
    for (final item in [
      ...pendientes,
      ...enAtencion,
      ...atendidas,
      ...alertas,
    ]) {
      if (item.idDgoAlertasMovilCiu > 0) {
        porId[item.idDgoAlertasMovilCiu] = item;
      }
    }
    return porId.values.toList()..sort(
      (a, b) => b.idDgoAlertasMovilCiu.compareTo(a.idDgoAlertasMovilCiu),
    );
  }

  factory AlertasGeneradasCiudadano.fromJson(Map<String, dynamic> json) {
    List<AlertaGeneradaCiudadano> lista(String key) =>
        miUpcList(json[key])
            .map((item) => AlertaGeneradaCiudadano.fromJson(miUpcMap(item)))
            .where((item) => item.idDgoAlertasMovilCiu > 0)
            .toList();
    return AlertasGeneradasCiudadano(
      documento: json['documento']?.toString().trim() ?? '',
      idGenPersona: miUpcInt(json['idGenPersona']),
      apenom: json['apenom']?.toString() ?? '',
      totalAlertas: miUpcInt(json['totalAlertas']),
      totalPendientes: miUpcInt(json['totalPendientes']),
      totalEnAtencion: miUpcInt(json['totalEnAtencion']),
      totalAtendidas: miUpcInt(json['totalAtendidas']),
      pendientes: lista('pendientes'),
      enAtencion: lista('enAtencion'),
      atendidas: lista('atendidas'),
      alertas: lista('alertas'),
    );
  }

  Map<String, dynamic> toJson() => {
    'documento': documento,
    'idGenPersona': idGenPersona,
    'apenom': apenom,
    'totalAlertas': totalAlertas,
    'totalPendientes': totalPendientes,
    'totalEnAtencion': totalEnAtencion,
    'totalAtendidas': totalAtendidas,
    'pendientes': pendientes.map((item) => item.toJson()).toList(),
    'enAtencion': enAtencion.map((item) => item.toJson()).toList(),
    'atendidas': atendidas.map((item) => item.toJson()).toList(),
    'alertas': alertas.map((item) => item.toJson()).toList(),
  };
}

class AlertaGeneradaCiudadano {
  final int idDgoAlertasMovilCiu;
  final int idDgoPersonasAlertaApp;
  final String estado;
  final String estadoAlerta;
  final String fechaAlerta;
  final String? fechaAtencion;
  final String observacion;
  final String? procedimiento;
  final String? estadoVerificacion;
  final UbicacionAlertaGenerada? ubicacionAlerta;
  final EstablecimientoAlertaGenerada? establecimiento;
  final AtencionAlertaGenerada? atencion;

  const AlertaGeneradaCiudadano({
    required this.idDgoAlertasMovilCiu,
    required this.idDgoPersonasAlertaApp,
    required this.estado,
    required this.estadoAlerta,
    required this.fechaAlerta,
    required this.fechaAtencion,
    required this.observacion,
    required this.procedimiento,
    required this.estadoVerificacion,
    required this.ubicacionAlerta,
    required this.establecimiento,
    required this.atencion,
  });

  String get estadoActual =>
      (estadoAlerta.isEmpty ? estado : estadoAlerta).trim().toUpperCase();

  factory AlertaGeneradaCiudadano.fromJson(Map<String, dynamic> json) =>
      AlertaGeneradaCiudadano(
        idDgoAlertasMovilCiu: miUpcInt(json['idDgoAlertasMovilCiu']),
        idDgoPersonasAlertaApp: miUpcInt(json['idDgoPersonasAlertaApp']),
        estado: json['estado']?.toString() ?? '',
        estadoAlerta: json['estadoAlerta']?.toString() ?? '',
        fechaAlerta: json['fechaAlerta']?.toString() ?? '',
        fechaAtencion: json['fechaAtencion']?.toString(),
        observacion: json['observacion']?.toString() ?? '',
        procedimiento: json['procedimiento']?.toString(),
        estadoVerificacion: json['estadoVerificacion']?.toString(),
        ubicacionAlerta: json['ubicacionAlerta'] is Map
            ? UbicacionAlertaGenerada.fromJson(
                miUpcMap(json['ubicacionAlerta']),
              )
            : null,
        establecimiento: json['establecimiento'] is Map
            ? EstablecimientoAlertaGenerada.fromJson(
                miUpcMap(json['establecimiento']),
              )
            : null,
        atencion: json['atencion'] is Map
            ? AtencionAlertaGenerada.fromJson(miUpcMap(json['atencion']))
            : null,
      );

  Map<String, dynamic> toJson() => {
    'idDgoAlertasMovilCiu': idDgoAlertasMovilCiu,
    'idDgoPersonasAlertaApp': idDgoPersonasAlertaApp,
    'estado': estado,
    'estadoAlerta': estadoAlerta,
    'fechaAlerta': fechaAlerta,
    'fechaAtencion': fechaAtencion,
    'observacion': observacion,
    'procedimiento': procedimiento,
    'estadoVerificacion': estadoVerificacion,
    'ubicacionAlerta': ubicacionAlerta?.toJson(),
    'establecimiento': establecimiento?.toJson(),
    'atencion': atencion?.toJson(),
  };
}

class UbicacionAlertaGenerada {
  final double? latitud;
  final double? longitud;

  const UbicacionAlertaGenerada({
    required this.latitud,
    required this.longitud,
  });

  bool get esValida =>
      latitud != null &&
      longitud != null &&
      latitud!.isFinite &&
      longitud!.isFinite &&
      latitud!.abs() <= 90 &&
      longitud!.abs() <= 180;

  factory UbicacionAlertaGenerada.fromJson(Map<String, dynamic> json) =>
      UbicacionAlertaGenerada(
        latitud: double.tryParse(json['latitud']?.toString() ?? ''),
        longitud: double.tryParse(json['longitud']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {'latitud': latitud, 'longitud': longitud};
}

class EstablecimientoAlertaGenerada {
  final String institucion;
  final String tipoUsuario;
  final String direccion;
  final String telefono;
  final String mail;
  final double? latitud;
  final double? longitud;

  const EstablecimientoAlertaGenerada({
    required this.institucion,
    required this.tipoUsuario,
    required this.direccion,
    required this.telefono,
    required this.mail,
    required this.latitud,
    required this.longitud,
  });

  factory EstablecimientoAlertaGenerada.fromJson(Map<String, dynamic> json) =>
      EstablecimientoAlertaGenerada(
        institucion: json['institucion']?.toString() ?? '',
        tipoUsuario: json['tipoUsuario']?.toString() ?? '',
        direccion: json['direccion']?.toString() ?? '',
        telefono: json['telefono']?.toString() ?? '',
        mail: json['mail']?.toString() ?? '',
        latitud: double.tryParse(json['latitud']?.toString() ?? ''),
        longitud: double.tryParse(json['longitud']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
    'institucion': institucion,
    'tipoUsuario': tipoUsuario,
    'direccion': direccion,
    'telefono': telefono,
    'mail': mail,
    'latitud': latitud,
    'longitud': longitud,
  };
}

class AtencionAlertaGenerada {
  final int? idGenUsuarioAtiende;
  final String? servidorPolicial;
  final String? procedimiento;
  final String? estadoVerificacion;
  final String? fechaAtencion;

  const AtencionAlertaGenerada({
    required this.idGenUsuarioAtiende,
    required this.servidorPolicial,
    required this.procedimiento,
    required this.estadoVerificacion,
    required this.fechaAtencion,
  });

  factory AtencionAlertaGenerada.fromJson(Map<String, dynamic> json) =>
      AtencionAlertaGenerada(
        idGenUsuarioAtiende: int.tryParse(
          json['idGenUsuarioAtiende'].toString(),
        ),
        servidorPolicial: json['servidorPolicial']?.toString(),
        procedimiento: json['procedimiento']?.toString(),
        estadoVerificacion: json['estadoVerificacion']?.toString(),
        fechaAtencion: json['fechaAtencion']?.toString(),
      );

  Map<String, dynamic> toJson() => {
    'idGenUsuarioAtiende': idGenUsuarioAtiende,
    'servidorPolicial': servidorPolicial,
    'procedimiento': procedimiento,
    'estadoVerificacion': estadoVerificacion,
    'fechaAtencion': fechaAtencion,
  };
}
