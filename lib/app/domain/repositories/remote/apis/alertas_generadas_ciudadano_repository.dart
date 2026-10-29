import '../../../../data/models/alertas_generadas_ciudadano_model.dart';

abstract class AlertasGeneradasCiudadanoRepository {
  Future<ConsultaAlertasGeneradasCiudadano> consultarAlertasGeneradas({
    required String documento,
  });
}
