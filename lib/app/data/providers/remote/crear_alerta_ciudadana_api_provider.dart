import '../../models/crear_alerta_ciudadana_model.dart';
import 'host/mi_upc_api_client.dart';
import '../../../core/exceptions/exception_helper.dart';

abstract class CrearAlertaCiudadanaApiProvider {
  Future<RespuestaAlertaCiudadana> crearAlertaCiudadana({
    required int idDgoPersonasAlertaApp,
    required double latitud,
    required double longitud,
    required String observacion,
  });
}

class CrearAlertaCiudadanaApiProviderImpl
    implements CrearAlertaCiudadanaApiProvider {
  final MiUpcApiClient _client;

  CrearAlertaCiudadanaApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<RespuestaAlertaCiudadana> crearAlertaCiudadana({
    required int idDgoPersonasAlertaApp,
    required double latitud,
    required double longitud,
    required String observacion,
  }) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-alerta-ciudadana',
        parametros: {
          'idDgoPersonasAlertaApp': idDgoPersonasAlertaApp,
          'latitud': latitud.toString(),
          'longitud': longitud.toString(),
          'observacion': observacion,
        },
      );
      return RespuestaAlertaCiudadana.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
