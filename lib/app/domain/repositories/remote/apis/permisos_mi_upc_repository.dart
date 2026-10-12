import '../../../../data/models/permisos_mi_upc_model.dart';

abstract class PermisosMiUpcRepository {
  Future<ConsultaPermisosMiUpc> consultarPermisosMiUpc({
    required String documento,
  });
}
