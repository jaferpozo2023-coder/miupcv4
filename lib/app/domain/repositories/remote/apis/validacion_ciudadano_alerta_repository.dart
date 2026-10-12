import '../../../../data/models/validacion_ciudadano_alerta_model.dart';

abstract class ValidacionCiudadanoAlertaRepository {
  Future<ValidacionCiudadanoAlerta> validarCiudadanoAlerta({
    required String documento,
  });
}
