import '../../../models/crear_alerta_ciudadana_model.dart';
import '../../../providers/remote/crear_alerta_ciudadana_api_provider.dart';
import '../../../../domain/repositories/remote/apis/crear_alerta_ciudadana_repository.dart';

class CrearAlertaCiudadanaApiImpl implements CrearAlertaCiudadanaRepository {
  final CrearAlertaCiudadanaApiProvider _provider;

  CrearAlertaCiudadanaApiImpl(this._provider);

  @override
  Future<RespuestaAlertaCiudadana> crearAlertaCiudadana({
    required int idDgoPersonasAlertaApp,
    required double latitud,
    required double longitud,
    required String observacion,
  }) => _provider.crearAlertaCiudadana(
    idDgoPersonasAlertaApp: idDgoPersonasAlertaApp,
    latitud: latitud,
    longitud: longitud,
    observacion: observacion,
  );
}
