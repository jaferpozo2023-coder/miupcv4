import '../../../models/vinculacion_dispositivo_policial_model.dart';
import '../../../providers/remote/vinculacion_dispositivo_policial_api_provider.dart';
import '../../../../domain/repositories/remote/apis/vinculacion_dispositivo_policial_repository.dart';

class VinculacionDispositivoPolicialApiImpl
    implements VinculacionDispositivoPolicialRepository {
  final VinculacionDispositivoPolicialApiProvider _provider;

  VinculacionDispositivoPolicialApiImpl(this._provider);

  @override
  Future<VinculacionDispositivoPolicial> vincularDispositivoPolicial({
    required String documento,
    required String instalacion,
    required String dispositivo,
    required String plataforma,
    required String tokenNotificacion,
  }) => _provider.vincularDispositivoPolicial(
    documento: documento,
    instalacion: instalacion,
    dispositivo: dispositivo,
    plataforma: plataforma,
    tokenNotificacion: tokenNotificacion,
  );
}
