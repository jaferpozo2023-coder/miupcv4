import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';

/// Estado de conexión posible
enum ConnectionStatus { online, offline }

/// Servicio central de monitoreo de conexión real (no solo WiFi)
class CheckInternetConnection {
  final Connectivity _connectivity = Connectivity();
  final _controller = BehaviorSubject<ConnectionStatus>();
  final Future<bool> Function() _verifyInternet;
  StreamSubscription? _connectionSubscription;
  Future<void>? _closeFuture;
  bool _closed = false;

  CheckInternetConnection({Future<bool> Function()? verifyInternet})
    : _verifyInternet = verifyInternet ?? _hasInternetAccess {
    // Ejecuta verificación inicial
    _init();
  }

  /// Stream reactivo de estado de conexión
  Stream<ConnectionStatus> internetStatus() {
    return _controller.stream.distinct();
  }

  /// Inicializa el monitoreo
  Future<void> _init() async {
    // Verificación inicial
    await _checkInternetConnection();
    if (_closed) return;

    // Escucha cambios en la red
    _connectionSubscription =
        _connectivity.onConnectivityChanged.listen((_) async {
          await _checkInternetConnection();
        });
  }

  /// Verifica si realmente hay acceso a Internet
  Future<void> _checkInternetConnection() async {
    try {
      final hasConnection = await _verifyInternet();
      _emit(
          hasConnection ? ConnectionStatus.online : ConnectionStatus.offline);
    } on SocketException {
      _emit(ConnectionStatus.offline);
    } catch (_) {
      _emit(ConnectionStatus.offline);
    }
  }

  static Future<bool> _hasInternetAccess() async {
    // Espera breve por estabilidad de red (útil en WiFi)
    await Future.delayed(const Duration(milliseconds: 800));

    const hosts = ['google.com', 'cloudflare.com', '1.1.1.1'];
    for (final host in hosts) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 2));
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        // ignora host fallido y sigue
      }
    }
    return false;
  }

  void _emit(ConnectionStatus status) {
    if (!_closed) _controller.add(status);
  }

  Future<void> close() {
    if (_closeFuture != null) return _closeFuture!;
    _closed = true;
    return _closeFuture = _close();
  }

  Future<void> _close() async {
    await _connectionSubscription?.cancel();
    await _controller.close();
  }
}
