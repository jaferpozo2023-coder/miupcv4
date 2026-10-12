import 'package:get/get.dart';

import 'alertas_ciudadanas_controller.dart';

class AlertasCiudadanasBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => AlertasCiudadanasController());
}
