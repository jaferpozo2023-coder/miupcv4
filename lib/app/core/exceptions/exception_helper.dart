import 'exceptions.dart';
import 'network_exception.dart';

class ExceptionHelper {
  static Never captureError(Object e) {
    if (e is ServerException) {
      throw e;
    }
    throw NetworkException.desde(e) ?? ServerException.msj(e.toString());
  }

  static String getError(Object e) {
    return captureError(e);
  }
}
