enum AccionUbicacion { reintentar, ajustesAplicacion, ajustesUbicacion }

class UbicacionException implements Exception {
  final String mensaje;
  final AccionUbicacion accion;

  const UbicacionException(
    this.mensaje, {
    this.accion = AccionUbicacion.reintentar,
  });

  @override
  String toString() => mensaje;
}
