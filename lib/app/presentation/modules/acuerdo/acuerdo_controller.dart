part of '../controllers.dart';

class AcuerdoController extends GetxController {
  static const String prefAcuerdo = 'mi_upc_acuerdo_confidencialidad_v1';
  final RxBool chk = false.obs;
  final RxBool guardando = false.obs;
  Future<void> aceptarAcuerdo() async {
    if (guardando.value) return;
    if (!chk.value) {
      DialogosAwesome.getError(
        descripcion: 'PARA CONTINUAR DEBE ACEPTAR LOS TÉRMINOS Y CONDICIONES DE USO DEL APLICATIVO.',
        title: 'Mi UPC',
        btnOkOnPress: () {},
      );
      return;
    }
    guardando.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final guardado = await prefs.setBool(prefAcuerdo, true);
      if (!guardado) {
        throw Exception('No fue posible guardar la aceptación del acuerdo.');
      }
      debugPrint('==========================================');
      debugPrint('ACUERDO -> GUARDADO CORRECTAMENTE');
      debugPrint('CLAVE: $prefAcuerdo');
      debugPrint('VALOR: true');
      debugPrint('==========================================');
      if (!isClosed) {
        Get.offAllNamed(AppRoutes.MENU);
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR GUARDANDO ACUERDO: $e');
      debugPrint('$stackTrace');
      DialogosAwesome.getError(
        descripcion: 'No fue posible guardar la aceptación del acuerdo. Intente nuevamente.',
        title: 'Mi UPC',
        btnOkOnPress: () {},
      );
    } finally {
      if (!isClosed) guardando.value = false;
    }
  }
}