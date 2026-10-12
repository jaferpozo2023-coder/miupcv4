import '../../../models/alertas_policia_model.dart';
import '../../../providers/remote/alertas_policia_api_provider.dart';
import '../../../../domain/repositories/remote/apis/alertas_policia_repository.dart';

class AlertasPoliciaApiImpl implements AlertasPoliciaRepository {
  final AlertasPoliciaApiProvider _provider;

  AlertasPoliciaApiImpl(this._provider);

  @override
  Future<ConsultaAlertasPolicia> consultarAlertasPolicia({
    required String documento,
  }) => _provider.consultarAlertasPolicia(documento: documento);
}
