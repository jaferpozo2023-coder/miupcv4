part of '../controllers.dart';

class SplashController extends GetxController {
  bool _navegando = false;

  @override
  void onInit() {
    super.onInit();
    unawaited(_inicializarFirebase());
    unawaited(_resolverRutaInicial());
  }

  Future<void> _resolverRutaInicial() async {
    if (_navegando || isClosed) return;
    debugPrint('======================================');
    debugPrint('SPLASH -> CONTROLADOR INICIALIZADO');
    debugPrint('======================================');
    try {
      await Future.delayed(const Duration(milliseconds: 1300));
      if (_navegando || isClosed) return;

      bool acuerdoAceptado = false;
      try {
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(seconds: 2),
        );
        acuerdoAceptado =
            prefs.getBool(AcuerdoController.prefAcuerdo) ?? false;
      } catch (e) {
        debugPrint('SPLASH -> Error leyendo preferencias: $e');
        acuerdoAceptado = false;
      }

      if (_navegando || isClosed) return;

      final ruta = acuerdoAceptado
          ? AppRoutes.MENU
          : AppRoutes.ACUERDO;

      debugPrint('SPLASH -> Acuerdo aceptado: $acuerdoAceptado');
      debugPrint('SPLASH -> Navegando a: $ruta');

      _navegando = true;
      Get.offAllNamed(ruta);
    } catch (e, stackTrace) {
      debugPrint('SPLASH -> Error general: $e');
      debugPrint('$stackTrace');

      if (!_navegando && !isClosed) {
        _navegando = true;
        Get.offAllNamed(AppRoutes.ACUERDO);
      }
    }
  }

  Future<void> _inicializarFirebase() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        debugPrint('SPLASH -> Firebase ya inicializado');
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 8));

      debugPrint('SPLASH -> Firebase inicializado');
    } on TimeoutException {
      debugPrint('SPLASH -> Firebase timeout');
    } catch (e, stackTrace) {
      debugPrint('SPLASH -> Error Firebase: $e');
      debugPrint('$stackTrace');
    }
  }
}