import '../../../../data/models/vinculacion_dispositivo_policial_model.dart';

abstract class VinculacionDispositivoPolicialRepository {
  Future<VinculacionDispositivoPolicial> vincularDispositivoPolicial({
    required String documento,
    required String instalacion,
    required String dispositivo,
    required String plataforma,
    required String tokenNotificacion,
  });
}
