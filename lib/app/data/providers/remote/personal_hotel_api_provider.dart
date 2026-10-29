import '../../../core/exceptions/exception_helper.dart';
import '../../models/personal_hotel_model.dart';
import 'host/mi_upc_api_client.dart';

abstract class PersonalHotelApiProvider {
  Future<RespuestaRegistroPersonalHotel> registrarPersonalHotel({
    required int idDgoPersonasAlertaApp,
    required String documento,
    required String nombres,
    required String nacionalidad,
    required double latitud,
    required double longitud,
  });
}

class PersonalHotelApiProviderImpl implements PersonalHotelApiProvider {
  final MiUpcApiClient _client;

  PersonalHotelApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<RespuestaRegistroPersonalHotel> registrarPersonalHotel({
    required int idDgoPersonasAlertaApp,
    required String documento,
    required String nombres,
    required String nacionalidad,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-registra-huesped-hotel',
        parametros: {
          'idDgoPersonasAlertaApp': idDgoPersonasAlertaApp,
          'documento': documento.trim(),
          'nombres': nombres.trim(),
          'nacionalidad': nacionalidad.trim(),
          'latitud': latitud.toString(),
          'longitud': longitud.toString(),
        },
      );
      return RespuestaRegistroPersonalHotel.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
