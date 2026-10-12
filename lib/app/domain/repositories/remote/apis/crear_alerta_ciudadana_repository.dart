import '../../../../data/models/crear_alerta_ciudadana_model.dart';

abstract class CrearAlertaCiudadanaRepository {
  Future<RespuestaAlertaCiudadana> crearAlertaCiudadana({
    required int idDgoPersonasAlertaApp,
    required double latitud,
    required double longitud,
    required String observacion,
  });
}
