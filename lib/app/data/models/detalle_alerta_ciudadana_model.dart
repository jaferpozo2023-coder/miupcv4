import 'mi_upc_parse.dart';

/// Detalle compartido por la bandeja y el historial de alertas ciudadanas.
class DetalleAlertaCiudadana {
  final int id;
  final String tipo;
  final String observacion;
  final String institucion;
  final String direccion;
  final String fecha;
  final double? latitud;
  final double? longitud;
  final String estado;
  final String verificacion;
  final String procedimiento;
  final String ciudadano;
  final String tipoCiudadano;
  final String telefonoCiudadano;
  final String fechaAtencion;

  const DetalleAlertaCiudadana({
    required this.id,
    required this.tipo,
    required this.observacion,
    required this.institucion,
    required this.direccion,
    required this.fecha,
    required this.latitud,
    required this.longitud,
    required this.estado,
    required this.verificacion,
    required this.procedimiento,
    this.ciudadano = '',
    this.tipoCiudadano = '',
    this.telefonoCiudadano = '',
    this.fechaAtencion = '',
  });

  bool get tieneUbicacion =>
      latitud != null &&
      longitud != null &&
      latitud!.isFinite &&
      longitud!.isFinite &&
      latitud!.abs() <= 90 &&
      longitud!.abs() <= 180;

  bool get atendida => estado.toUpperCase() == 'ATENDIDA';

  factory DetalleAlertaCiudadana.fromJson(Map<String, dynamic> json) {
    final ubicacion = miUpcMap(json['ubicacionAlerta']);
    final establecimiento = miUpcMap(json['establecimiento']);
    final persona = miUpcMap(json['ciudadano']);
    return DetalleAlertaCiudadana(
      id: miUpcInt(json['idDgoAlertasMovilCiu']),
      tipo: json['tipoAlerta']?.toString() ?? '',
      observacion: json['observacion']?.toString() ?? '',
      institucion:
          (establecimiento['institucion'] ?? json['institucion'])?.toString() ??
          '',
      direccion:
          (establecimiento['direccion'] ?? json['direccion'])?.toString() ?? '',
      fecha: json['fechaAlerta']?.toString() ?? '',
      latitud: double.tryParse(
        (ubicacion['latitud'] ?? json['latitud'])?.toString() ?? '',
      ),
      longitud: double.tryParse(
        (ubicacion['longitud'] ?? json['longitud'])?.toString() ?? '',
      ),
      estado: json['estadoAlerta']?.toString() ?? 'GENERADA',
      verificacion: json['estadoVerificacion']?.toString() ?? '',
      procedimiento: json['procedimiento']?.toString() ?? '',
      ciudadano:
          (persona['apenom'] ?? json['nombreCiudadano'])?.toString() ?? '',
      tipoCiudadano:
          (persona['tipoUsuario'] ?? json['tipoCiudadano'])?.toString() ?? '',
      telefonoCiudadano:
          (persona['telefono'] ?? json['telefonoCiudadano'])?.toString() ?? '',
      fechaAtencion: json['fechaAtencion']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'idDgoAlertasMovilCiu': id,
    'tipoAlerta': tipo,
    'observacion': observacion,
    'institucion': institucion,
    'direccion': direccion,
    'fechaAlerta': fecha,
    'latitud': latitud,
    'longitud': longitud,
    'estadoAlerta': estado,
    'estadoVerificacion': verificacion,
    'procedimiento': procedimiento,
    'nombreCiudadano': ciudadano,
    'tipoCiudadano': tipoCiudadano,
    'telefonoCiudadano': telefonoCiudadano,
    'fechaAtencion': fechaAtencion,
  };
}
