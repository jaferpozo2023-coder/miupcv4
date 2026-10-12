import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'exceptions.dart';

enum TipoErrorRed { dns, tiempoEspera, conexion }

class NetworkException extends ServerException {
  final TipoErrorRed tipo;
  final Object original;

  NetworkException._({
    required this.tipo,
    required this.original,
    required super.cause,
  });

  static NetworkException? desde(Object error) {
    if (error is TimeoutException) {
      return NetworkException._(
        tipo: TipoErrorRed.tiempoEspera,
        original: error,
        cause:
            'El servidor no respondió a tiempo. Vuelva a intentar la consulta.',
      );
    }
    if (error is SocketException || error is http.ClientException) {
      final esDns = error.toString().toLowerCase().contains(
        'failed host lookup',
      );
      return NetworkException._(
        tipo: esDns ? TipoErrorRed.dns : TipoErrorRed.conexion,
        original: error,
        cause: esDns
            ? 'No se pudo resolver la dirección del servidor. Revise la conexión a Internet o el DNS del teléfono y vuelva a intentar.'
            : 'No se pudo conectar con el servidor. Revise su conexión a Internet y vuelva a intentar.',
      );
    }
    return null;
  }
}
