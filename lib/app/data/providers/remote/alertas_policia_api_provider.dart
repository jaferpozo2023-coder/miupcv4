import '../../../core/exceptions/exception_helper.dart';
import '../../models/alertas_policia_model.dart';
import 'host/mi_upc_api_client.dart';

abstract class AlertasPoliciaApiProvider {
  Future<ConsultaAlertasPolicia> consultarAlertasPolicia({
    required String documento,
  });
}

class AlertasPoliciaApiProviderImpl implements AlertasPoliciaApiProvider {
  final MiUpcApiClient _client;

  AlertasPoliciaApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<ConsultaAlertasPolicia> consultarAlertasPolicia({
    required String documento,
  }) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-alertas-atendidas-policia',
        parametros: {'documento': documento},
      );
      return ConsultaAlertasPolicia.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
