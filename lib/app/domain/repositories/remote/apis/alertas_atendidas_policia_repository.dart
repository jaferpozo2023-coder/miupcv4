import '../../../../data/models/alertas_atendidas_policia_model.dart';

abstract class AlertasAtendidasPoliciaRepository {
  Future<AlertasAtendidasPolicia> consultarAlertasAtendidas({
    required String documento,
  });
}
