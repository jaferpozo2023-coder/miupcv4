import '../../models/atender_alerta_ciudadana_model.dart';
import 'host/mi_upc_api_client.dart';
import '../../../core/exceptions/exception_helper.dart';

abstract class AtenderAlertaCiudadanaApiProvider {
  Future<RespuestaAtencionAlertaCiudadana> atenderAlertaCiudadana({
    required int idDgoAlertasMovilCiu,
    required int idGenUsuario,
    required String procedimiento,
    required String estadoVerificacion,
  });
}

class AtenderAlertaCiudadanaApiProviderImpl
    implements AtenderAlertaCiudadanaApiProvider {
  final MiUpcApiClient _client;

  AtenderAlertaCiudadanaApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<RespuestaAtencionAlertaCiudadana> atenderAlertaCiudadana({
    required int idDgoAlertasMovilCiu,
    required int idGenUsuario,
    required String procedimiento,
    required String estadoVerificacion,
  }) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-atender-alerta-ciudadana',
        parametros: {
          'idDgoAlertasMovilCiu': idDgoAlertasMovilCiu,
          'idGenUsuario': idGenUsuario,
          'procedimiento': procedimiento,
          'estadoVerificacion': estadoVerificacion,
        },
      );
      return RespuestaAtencionAlertaCiudadana.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
