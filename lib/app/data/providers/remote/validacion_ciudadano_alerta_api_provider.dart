import '../../models/validacion_ciudadano_alerta_model.dart';
import 'host/mi_upc_api_client.dart';
import '../../../core/exceptions/exception_helper.dart';

abstract class ValidacionCiudadanoAlertaApiProvider {
  Future<ValidacionCiudadanoAlerta> validarCiudadanoAlerta({
    required String documento,
  });
}

class ValidacionCiudadanoAlertaApiProviderImpl
    implements ValidacionCiudadanoAlertaApiProvider {
  final MiUpcApiClient _client;

  ValidacionCiudadanoAlertaApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<ValidacionCiudadanoAlerta> validarCiudadanoAlerta({
    required String documento,
  }) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-valida-ciudadano-alerta',
        parametros: {'documento': documento},
      );
      return ValidacionCiudadanoAlerta.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
