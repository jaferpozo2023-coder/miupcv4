import '../../../../data/models/personal_hotel_model.dart';

abstract class PersonalHotelRepository {
  Future<RespuestaRegistroPersonalHotel> registrarPersonalHotel({
    required int idDgoPersonasAlertaApp,
    required String documento,
    required String nombres,
    required String nacionalidad,
    required double latitud,
    required double longitud,
  });
}
