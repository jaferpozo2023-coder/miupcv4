import '../../../models/alertas_generadas_ciudadano_model.dart';
import '../../../providers/remote/alertas_generadas_ciudadano_api_provider.dart';
import '../../../../domain/repositories/remote/apis/alertas_generadas_ciudadano_repository.dart';

class AlertasGeneradasCiudadanoApiImpl
    implements AlertasGeneradasCiudadanoRepository {
  final AlertasGeneradasCiudadanoApiProvider _provider;

  AlertasGeneradasCiudadanoApiImpl(this._provider);

  @override
  Future<ConsultaAlertasGeneradasCiudadano> consultarAlertasGeneradas({
    required String documento,
  }) => _provider.consultarAlertasGeneradas(documento: documento);
}
