import '../../../core/exceptions/exception_helper.dart';
import '../../models/alertas_generadas_ciudadano_model.dart';
import 'host/mi_upc_api_client.dart';

abstract class AlertasGeneradasCiudadanoApiProvider {
  Future<ConsultaAlertasGeneradasCiudadano> consultarAlertasGeneradas({
    required String documento,
  });
}

class AlertasGeneradasCiudadanoApiProviderImpl
    implements AlertasGeneradasCiudadanoApiProvider {
  final MiUpcApiClient _client;

  AlertasGeneradasCiudadanoApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<ConsultaAlertasGeneradasCiudadano> consultarAlertasGeneradas({
    required String documento,
  }) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-alertas-generadas-ciudadano',
        parametros: {'documento': documento.trim()},
      );
      return ConsultaAlertasGeneradasCiudadano.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
