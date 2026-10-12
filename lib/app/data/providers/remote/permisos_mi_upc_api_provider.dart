import '../../models/permisos_mi_upc_model.dart';
import 'host/mi_upc_api_client.dart';
import '../../../core/exceptions/exception_helper.dart';

abstract class PermisosMiUpcApiProvider {
  Future<ConsultaPermisosMiUpc> consultarPermisosMiUpc({
    required String documento,
  });
}

class PermisosMiUpcApiProviderImpl implements PermisosMiUpcApiProvider {
  final MiUpcApiClient _client;
  final _consultasEnCurso = <String, Future<ConsultaPermisosMiUpc>>{};

  PermisosMiUpcApiProviderImpl({MiUpcApiClient? client})
    : _client = client ?? MiUpcApiClient();

  @override
  Future<ConsultaPermisosMiUpc> consultarPermisosMiUpc({
    required String documento,
  }) {
    final cedula = documento.trim();
    // Se comparte únicamente la consulta en curso; cada consulta posterior
    // vuelve al servidor para detectar cambios o revocaciones del permiso.
    return _consultasEnCurso.putIfAbsent(
      cedula,
      () => _consultar(cedula).whenComplete(() {
        _consultasEnCurso.remove(cedula);
      }),
    );
  }

  Future<ConsultaPermisosMiUpc> _consultar(String documento) async {
    try {
      final json = await _client.post(
        opc: 'v1-post-permisos-miupc',
        parametros: {'documento': documento},
      );
      return ConsultaPermisosMiUpc.fromJson(json);
    } catch (e) {
      throw ExceptionHelper.captureError(e);
    }
  }
}
