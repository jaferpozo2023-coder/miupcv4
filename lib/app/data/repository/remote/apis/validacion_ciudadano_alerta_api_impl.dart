import '../../../models/validacion_ciudadano_alerta_model.dart';
import '../../../providers/remote/validacion_ciudadano_alerta_api_provider.dart';
import '../../../../domain/repositories/remote/apis/validacion_ciudadano_alerta_repository.dart';

class ValidacionCiudadanoAlertaApiImpl
    implements ValidacionCiudadanoAlertaRepository {
  final ValidacionCiudadanoAlertaApiProvider _provider;

  ValidacionCiudadanoAlertaApiImpl(this._provider);

  @override
  Future<ValidacionCiudadanoAlerta> validarCiudadanoAlerta({
    required String documento,
  }) => _provider.validarCiudadanoAlerta(documento: documento);
}
