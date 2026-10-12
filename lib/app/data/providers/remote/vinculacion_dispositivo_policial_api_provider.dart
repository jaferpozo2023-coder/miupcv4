import '../../models/vinculacion_dispositivo_policial_model.dart';
import 'host/mi_upc_api_client.dart';
import '../../../core/exceptions/exception_helper.dart';

abstract class VinculacionDispositivoPolicialApiProvider {
  Future<VinculacionDispositivoPolicial> vincularDispositivoPolicial({
    required String documento,
    required String instalacion,
    required String dispositivo,
    required String plataforma,
    required String tokenNotificacion,
  });
}

class VinculacionDispositivoPolicialApiProviderImpl
    implements VinculacionDispositivoPolicialApiProvider {
  final MiUpcApiClient _client;

  VinculacionDispositivoPolicialApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<VinculacionDispositivoPolicial> vincularDispositivoPolicial({
    required String documento,
    required String instalacion,
    required String dispositivo,
    required String plataforma,
    required String tokenNotificacion,
  }) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-vincula-dispositivo-policial',
        parametros: {
          'documento': documento,
          'instalacion': instalacion,
          'dispositivo': dispositivo,
          'plataforma': plataforma,
          'tokenNotificacion': tokenNotificacion,
        },
      );
      return VinculacionDispositivoPolicial.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
