import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pne/app/core/exceptions/exception_helper.dart';
import 'package:pne/app/core/exceptions/exceptions.dart';
import 'package:pne/app/core/exceptions/network_exception.dart';
import 'package:pne/app/data/providers/providers_impl.dart';

class _ClientPrueba extends MockClient {
  bool cerrado = false;
  _ClientPrueba(super.fn);

  @override
  void close() {
    cerrado = true;
    super.close();
  }
}

void main() {
  test('DNS, tiempo de espera y otros errores de conexión se distinguen', () {
    expect(
      () => ExceptionHelper.captureError(
        const SocketException("Failed host lookup: 'servidor-prueba'"),
      ),
      throwsA(
        isA<NetworkException>().having((e) => e.tipo, 'tipo', TipoErrorRed.dns),
      ),
    );
    expect(
      () => ExceptionHelper.captureError(
        http.ClientException(
          "SocketException: Failed host lookup: 'servidor-prueba'",
        ),
      ),
      throwsA(
        isA<NetworkException>().having((e) => e.tipo, 'tipo', TipoErrorRed.dns),
      ),
    );
    expect(
      () => ExceptionHelper.captureError(TimeoutException('Sin respuesta')),
      throwsA(
        isA<NetworkException>().having(
          (e) => e.tipo,
          'tipo',
          TipoErrorRed.tiempoEspera,
        ),
      ),
    );
    expect(
      () => ExceptionHelper.captureError(
        const SocketException('Connection refused'),
      ),
      throwsA(
        isA<NetworkException>().having(
          (e) => e.tipo,
          'tipo',
          TipoErrorRed.conexion,
        ),
      ),
    );
  });

  test('las capas conservan el tipo y el mensaje del error original', () {
    final dns = NetworkException.desde(
      const SocketException("Failed host lookup: 'servidor-prueba'"),
    )!;
    expect(() => ExceptionHelper.captureError(dns), throwsA(same(dns)));
    final servidor = ServerException(cause: 'Respuesta del servidor');
    expect(
      () => ExceptionHelper.captureError(servidor),
      throwsA(same(servidor)),
    );
  });

  for (final post in [true, false]) {
    final metodo = post ? 'POST' : 'GET';
    for (final falla in [true, false]) {
      test(
        '$metodo libera el cliente al ${falla ? 'fallar' : 'recibir respuesta'}',
        () async {
          final client = _ClientPrueba((request) async {
            expect(request.method, metodo);
            if (falla) {
              throw const SocketException(
                "Failed host lookup: 'servidor-prueba'",
              );
            }
            return http.Response('{}', 200);
          });
          final consulta = http.runWithClient(
            () => post
                ? UrlApiProvider.post(
                    segmento: 'polco/index.php',
                    body: {'opc': 'consulta-prueba'},
                  )
                : UrlApiProvider.get(segmento: 'polco/index.php'),
            () => client,
          );
          if (falla) {
            await expectLater(consulta, throwsA(isA<NetworkException>()));
          } else {
            expect(await consulta, '{}');
          }
          expect(client.cerrado, isTrue);
        },
      );
    }
  }
}
