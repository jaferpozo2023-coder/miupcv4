import '../../../models/personal_hotel_model.dart';
import '../../../providers/remote/personal_hotel_api_provider.dart';
import '../../../../domain/repositories/remote/apis/personal_hotel_repository.dart';

class PersonalHotelApiImpl implements PersonalHotelRepository {
  final PersonalHotelApiProvider _provider;

  PersonalHotelApiImpl(this._provider);

  @override
  Future<RespuestaRegistroPersonalHotel> registrarPersonalHotel({
    required int idDgoPersonasAlertaApp,
    required String documento,
    required String nombres,
    required String nacionalidad,
    required double latitud,
    required double longitud,
  }) => _provider.registrarPersonalHotel(
    idDgoPersonasAlertaApp: idDgoPersonasAlertaApp,
    documento: documento,
    nombres: nombres,
    nacionalidad: nacionalidad,
    latitud: latitud,
    longitud: longitud,
  );
}
