import '../../../../data/models/atender_alerta_ciudadana_model.dart';

abstract class AtenderAlertaCiudadanaRepository {
  Future<RespuestaAtencionAlertaCiudadana> atenderAlertaCiudadana({
    required int idDgoAlertasMovilCiu,
    required int idGenUsuario,
    required String procedimiento,
    required String estadoVerificacion,
  });
}
