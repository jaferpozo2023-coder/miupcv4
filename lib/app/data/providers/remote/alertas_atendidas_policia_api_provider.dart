import '../../../core/exceptions/exception_helper.dart';
import '../../models/alertas_atendidas_policia_model.dart';
import 'host/mi_upc_api_client.dart';

abstract class AlertasAtendidasPoliciaApiProvider {
  Future<AlertasAtendidasPolicia> consultarAlertasAtendidas({
    required String documento,
  });
}

class AlertasAtendidasPoliciaApiProviderImpl
    implements AlertasAtendidasPoliciaApiProvider {
  final MiUpcApiClient _client;

  AlertasAtendidasPoliciaApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<AlertasAtendidasPolicia> consultarAlertasAtendidas({
    required String documento,
  }) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-alertas-atendidas-policia',
        parametros: {'documento': documento},
      );
      return AlertasAtendidasPolicia.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
