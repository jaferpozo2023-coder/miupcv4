import '../../../models/atender_alerta_ciudadana_model.dart';
import '../../../providers/remote/atender_alerta_ciudadana_api_provider.dart';
import '../../../../domain/repositories/remote/apis/atender_alerta_ciudadana_repository.dart';

class AtenderAlertaCiudadanaApiImpl
    implements AtenderAlertaCiudadanaRepository {
  final AtenderAlertaCiudadanaApiProvider _provider;

  AtenderAlertaCiudadanaApiImpl(this._provider);

  @override
  Future<RespuestaAtencionAlertaCiudadana> atenderAlertaCiudadana({
    required int idDgoAlertasMovilCiu,
    required int idGenUsuario,
    required String procedimiento,
    required String estadoVerificacion,
  }) => _provider.atenderAlertaCiudadana(
    idDgoAlertasMovilCiu: idDgoAlertasMovilCiu,
    idGenUsuario: idGenUsuario,
    procedimiento: procedimiento,
    estadoVerificacion: estadoVerificacion,
  );
}
