import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:pne/app/data/providers/providers_impl.dart';
import 'package:pne/app/data/providers/remote/host/mi_upc_api_client.dart';
import 'package:pne/app/data/repository/data_repositories.dart';

void main() {
  test('registra personal con el contrato del endpoint de hotel', () async {
    final repository = PersonalHotelApiImpl(
      PersonalHotelApiProviderImpl(
        client: MiUpcApiClient(
          post: ({required segmento, required body}) async {
            expect(segmento, 'polco/index.php');
            expect(body, {
              'idDgoPersonasAlertaApp': 9,
              'documento': 'AB123456',
              'nombres': 'JUAN CARLOS PEREZ',
              'nacionalidad': 'COLOMBIANA',
              'modulo': 'ddced13c854fb2c03d6e01ce5bfd7e08',
              'opc': 'v1-post-registra-huesped-hotel',
            });
            return jsonEncode({
              'huespedHotel': {
                'codeError': 0,
                'msj': 'true',
                'datos': {
                  'idDgoHuespedesApp': 1,
                  'idDgoPersonasAlertaApp': 9,
                  'idDgoHotelesApp': 3,
                  'codigoInstitucion': 'HOT-EB284AAC443C13A5809B2628',
                  'institucion': 'HOTEL UNICORNIO',
                  'documento': 'AB123456',
                  'nombres': 'JUAN CARLOS PEREZ',
                  'nacionalidad': 'COLOMBIANA',
                  'fechaRegistro': '2026-10-14 20:17:20',
                },
              },
            });
          },
        ),
      ),
    );

    final respuesta = await repository.registrarPersonalHotel(
      idDgoPersonasAlertaApp: 9,
      documento: ' AB123456 ',
      nombres: ' JUAN CARLOS PEREZ ',
      nacionalidad: ' COLOMBIANA ',
        latitud:-0.1806532,
        longitud:-78.4678382
    );

    expect(respuesta.codeError, 0);
    expect(respuesta.datos?.idDgoHuespedesApp, 1);
    expect(respuesta.datos?.institucion, 'HOTEL UNICORNIO');
  });
}
