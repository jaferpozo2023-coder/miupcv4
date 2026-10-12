import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:pne/app/presentation/gps/gps_impl_helper.dart';
import 'package:pne/app/presentation/modules/controllers.dart';

import 'core/utils/feactures/di_feactures.dart';
import 'data/providers/providers_impl.dart';
import 'data/repository/data_repositories.dart';
import 'domain/repositories/domain_repositories.dart';
import 'domain/use_cases/evento_use_case.dart';

class DependencyInjection extends Bindings {
  static ini() {
    Get.lazyPut<AlertasAtendidasPoliciaApiProvider>(
      () => AlertasAtendidasPoliciaApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<AlertasAtendidasPoliciaRepository>(
      () => AlertasAtendidasPoliciaApiImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<AlertasPoliciaApiProvider>(
      () => AlertasPoliciaApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<AlertasPoliciaRepository>(
      () => AlertasPoliciaApiImpl(Get.find()),
      fenix: true,
    );
    // Repository
    Get.lazyPut<ItemsRepository>(
      () => ItemsApiImpl(itemsApiProviderImpl: Get.find()),
      fenix: true,
    );
    Get.lazyPut<ModulosRepository>(
      () => ModulosApiImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<ServiciosRepository>(
      () => ServiciosApiImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<MapaUpcRepository>(
      () => MapaUpcApiImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<RegistroUsuarioRepository>(
      () => RegistroUsuarioApiImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<AlertaViolenciaRepository>(
      () => AlertaViolenciaApiImpl(
        alertaViolenciaApiProviderImpl: AlertaViolenciaApiProviderImpl(),
      ),
      fenix: true,
    );
    Get.lazyPut<ValidacionCiudadanoAlertaRepository>(
      () => ValidacionCiudadanoAlertaApiImpl(
        Get.find<ValidacionCiudadanoAlertaApiProvider>(),
      ),
      fenix: true,
    );
    Get.lazyPut<VinculacionDispositivoPolicialRepository>(
      () => VinculacionDispositivoPolicialApiImpl(
        Get.find<VinculacionDispositivoPolicialApiProvider>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CrearAlertaCiudadanaRepository>(
      () => CrearAlertaCiudadanaApiImpl(
        Get.find<CrearAlertaCiudadanaApiProvider>(),
      ),
      fenix: true,
    );
    Get.lazyPut<AtenderAlertaCiudadanaRepository>(
      () => AtenderAlertaCiudadanaApiImpl(
        Get.find<AtenderAlertaCiudadanaApiProvider>(),
      ),
      fenix: true,
    );
    Get.lazyPut<PermisosMiUpcRepository>(
      () => PermisosMiUpcApiImpl(Get.find<PermisosMiUpcApiProvider>()),
      fenix: true,
    );

    /// PROVIDER ALERTAS DELITOS
    Get.lazyPut<AlertasDelitosApiProviderImpl>(
      () => AlertasDelitosApiProviderImpl(),
      fenix: true,
    );

    /// REPOSITORY ALERTAS DELITOS
    Get.lazyPut<AlertasDelitosRepository>(
      () => AlertasDelitosApiImpl(
        alertasDelitosApiProviderImpl:
            Get.find<AlertasDelitosApiProviderImpl>(),
      ),
      fenix: true,
    );

    /// USE CASE ALERTAS DELITOS
    Get.lazyPut<CrearEventoUseCase>(
      () => CrearEventoUseCase(Get.find<AlertasDelitosRepository>()),
      fenix: true,
    );

    // Data sources
    Get.lazyPut<ItemsApiProvider>(() => ItemsApiProviderImpl(), fenix: true);
    Get.lazyPut<ModulosApiProvider>(
      () => ModulosApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<ServiciosApiProvider>(
      () => ServiciosApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<MapaUpcApiProvider>(
      () => MapaUpcApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<RegistroUsuarioApiProvider>(
      () => RegistroUsuarioApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<ValidacionCiudadanoAlertaApiProvider>(
      () => ValidacionCiudadanoAlertaApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<VinculacionDispositivoPolicialApiProvider>(
      () => VinculacionDispositivoPolicialApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<CrearAlertaCiudadanaApiProvider>(
      () => CrearAlertaCiudadanaApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<AtenderAlertaCiudadanaApiProvider>(
      () => AtenderAlertaCiudadanaApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<PermisosMiUpcApiProvider>(
      () => PermisosMiUpcApiProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<RegistroAlertaVehiculosApiProvider>(
      () => RegistroAlertaVehiculosApiProviderImpl(),
      fenix: true,
    );

    Get.lazyPut<LocalStorageRepository>(
      () => LocalStoreProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<LocalStoreProviderImpl>(
      () => LocalStoreProviderImpl(),
      fenix: true,
    );
    Get.lazyPut<LocalStoreImpl>(() => LocalStoreImpl(), fenix: true);

    Get.put(GpsController(), permanent: true);

    DependencyInjectionFeactures.init();
  }

  @override
  void dependencies() {
    ini();
  }
}
