import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pne/app/core/exceptions/exceptions.dart';
import 'package:pne/app/core/exceptions/network_exception.dart';
import 'package:pne/app/data/providers/providers_impl.dart';
import 'package:pne/app/data/providers/remote/host/mi_upc_api_client.dart';
import 'package:pne/app/data/repository/data_repositories.dart';

void main() {
  test(
    'el repositorio ciudadano envía el contrato exacto y parsea su respuesta',
    () async {
      final repository = AlertasGeneradasCiudadanoApiImpl(
        AlertasGeneradasCiudadanoApiProviderImpl(
          client: MiUpcApiClient(
            post: ({required segmento, required body}) async {
              expect(segmento, 'polco/index.php');
              expect(body, {
                'documento': 'documento-prueba',
                'modulo': 'ddced13c854fb2c03d6e01ce5bfd7e08',
                'opc': 'v1-post-alertas-generadas-ciudadano',
              });
              return File('test/fixtures/alertas_generadas_ciudadano.json')
                  .readAsString();
            },
          ),
        ),
      );
      final respuesta = await repository.consultarAlertasGeneradas(
        documento: ' documento-prueba ',
      );
      expect(respuesta.codeError, 0);
      expect(respuesta.datos.single.todas, hasLength(5));
    },
  );

  test(
    'el historial ciudadano conserva errores del servidor para mostrarlos',
    () async {
      final repository = AlertasGeneradasCiudadanoApiImpl(
        AlertasGeneradasCiudadanoApiProviderImpl(
          client: MiUpcApiClient(
            post: ({required segmento, required body}) async => jsonEncode({
              'alertasCiudadano': {
                'codeError': 1,
                'msj': 'Servicio no disponible',
              },
            }),
          ),
        ),
      );
      final respuesta = await repository.consultarAlertasGeneradas(
        documento: 'documento-prueba',
      );
      expect(respuesta.codeError, 1);
      expect(respuesta.msj, 'Servicio no disponible');
    },
  );

  test(
    'el historial ciudadano convierte errores de red y respuestas inválidas',
    () async {
      final repository = AlertasGeneradasCiudadanoApiImpl(
        AlertasGeneradasCiudadanoApiProviderImpl(
          client: MiUpcApiClient(
            post: ({required segmento, required body}) async =>
                throw const SocketException('Sin conexión'),
          ),
        ),
      );
      await expectLater(
        repository.consultarAlertasGeneradas(documento: 'documento-prueba'),
        throwsA(isA<NetworkException>()),
      );
      final invalido = AlertasGeneradasCiudadanoApiImpl(
        AlertasGeneradasCiudadanoApiProviderImpl(
          client: MiUpcApiClient(
            post: ({required segmento, required body}) async => '{}',
          ),
        ),
      );
      await expectLater(
        invalido.consultarAlertasGeneradas(documento: 'documento-prueba'),
        throwsA(isA<ServerException>()),
      );
    },
  );
}
