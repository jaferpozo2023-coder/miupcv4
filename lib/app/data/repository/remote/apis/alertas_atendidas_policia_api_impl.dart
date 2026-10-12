import '../../../models/alertas_atendidas_policia_model.dart';
import '../../../providers/remote/alertas_atendidas_policia_api_provider.dart';
import '../../../../domain/repositories/remote/apis/alertas_atendidas_policia_repository.dart';

class AlertasAtendidasPoliciaApiImpl
    implements AlertasAtendidasPoliciaRepository {
  final AlertasAtendidasPoliciaApiProvider _provider;

  AlertasAtendidasPoliciaApiImpl(this._provider);

  @override
  Future<AlertasAtendidasPolicia> consultarAlertasAtendidas({
    required String documento,
  }) => _provider.consultarAlertasAtendidas(documento: documento);
}
