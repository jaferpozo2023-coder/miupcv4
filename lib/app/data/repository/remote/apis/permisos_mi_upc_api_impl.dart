import '../../../models/permisos_mi_upc_model.dart';
import '../../../providers/remote/permisos_mi_upc_api_provider.dart';
import '../../../../domain/repositories/remote/apis/permisos_mi_upc_repository.dart';

class PermisosMiUpcApiImpl implements PermisosMiUpcRepository {
  final PermisosMiUpcApiProvider _provider;

  PermisosMiUpcApiImpl(this._provider);

  @override
  Future<ConsultaPermisosMiUpc> consultarPermisosMiUpc({
    required String documento,
  }) => _provider.consultarPermisosMiUpc(documento: documento);
}
