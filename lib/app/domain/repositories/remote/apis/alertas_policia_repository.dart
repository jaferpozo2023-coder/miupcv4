import '../../../../data/models/alertas_policia_model.dart';

abstract class AlertasPoliciaRepository {
  Future<ConsultaAlertasPolicia> consultarAlertasPolicia({
    required String documento,
  });
}
