import 'package:flutter_test/flutter_test.dart';
import 'package:pne/app/data/models/models.dart';

void main() {
  group('Mi UPC alert models', () {
    test('parses citizen validation for existing and missing records', () {
      final existing = ValidacionCiudadanoAlerta.fromJson({
        'ciudadanoAlerta': {
          'codeError': 0,
          'msj': 'existe',
          'datos': [
            {
              'idDgoPersonasAlertaApp': 2,
              'idGenPersona': 146270,
              'documento': '0401477963',
              'apenom': 'POZO CANACUAN JAIRO FERNANDO',
              'codigoInstitucion': 'EST-8540D09067D6',
              'institucion': 'Institución',
              'tipoUsuario': 'PROPIETARIO',
              'direccion': 'Dirección',
              'telefono': '2133333332',
              'mail': 'jairo@example.com',
              'latitud': '-0.1968895',
              'longitud': '-78.5115770',
              'idGenEstado': 1,
            },
          ],
        },
      });
      final missing = ValidacionCiudadanoAlerta.fromJson({
        'ciudadanoAlerta': {'codeError': 0, 'msj': 'noExiste', 'datos': []},
      });

      expect(existing.datos.single.idDgoPersonasAlertaApp, 2);
      expect(existing.datos.single.documento, '0401477963');
      expect(missing.msj, 'noExiste');
      expect(missing.datos, isEmpty);
    });

    test('parses device binding booleans and permission response', () {
      final binding = VinculacionDispositivoPolicial.fromJson({
        'dispositivoPolicial': {
          'codeError': 0,
          'msj': 'true',
          'datos': {
            'idDgoDispositivosAlerta': 1,
            'idGenUsuario': 55948,
            'idGenPersona': 724115,
            'documento': '1206762401',
            'unidad': 'ASDASDSA',
            'instalacion': '3f2cc728-3e95-4ed2-aaf8-872bb8417220',
            'dispositivo': 'iPhone 17 Pro Max',
            'plataforma': 'IOS',
            'tokenRegistrado': true,
            'dispositivoVinculado': true,
          },
        },
      });
      final permissions = ConsultaPermisosMiUpc.fromJson({
        'permisosMiUpc': {
          'codeError': 0,
          'msj': 'existe',
          'datos': [
            {
              'documento': '1206762401',
              'idGenPersona': 724115,
              'apenom': 'CALDERON PAZMIÑO FREDDY NICANOR',
              'tienePermiso': true,
              'permisoCiudadano': false,
              'permisoPolicial': true,
              'tiposPermiso': ['SERVIDOR_POLICIAL'],
              'ciudadano': null,
              'servidorPolicial': {
                'idGenUsuario': 55948,
                'idDgoDispositivosAlerta': 1,
                'unidad': 'ASDASDSA',
                'instalacion': 'installation-id',
                'dispositivo': 'iPhone',
                'plataforma': 'iOS',
                'dispositivoVinculado': true,
                'tokenRegistrado': true,
                'activo': true,
              },
            },
          ],
        },
      });

      expect(binding.datos?.dispositivoVinculado, isTrue);
      expect(binding.datos?.tokenRegistrado, isTrue);
      expect(permissions.datos.single.permisoPolicial, isTrue);
      expect(permissions.datos.single.servidorPolicial?.idGenUsuario, 55948);
    });

    test('parses create and attend citizen alert responses', () {
      final created = RespuestaAlertaCiudadana.fromJson({
        'alertaCiudadana': {
          'codeError': 0,
          'msj': 'true',
          'datos': {
            'idDgoAlertasMovilCiu': 3,
            'estadoAlerta': 'GENERADA',
            'fechaAlerta': '2026-10-11 19:39:58',
            'institucion': 'Institución',
            'notificacionesEnviadas': 1,
          },
        },
      });
      final attended = RespuestaAtencionAlertaCiudadana.fromJson({
        'atencionAlertaCiudadana': {
          'codeError': 0,
          'msj': 'true',
          'datos': {
            'idDgoAlertasMovilCiu': 3,
            'idGenUsuarioAtiende': 55948,
            'estadoAlerta': 'ATENDIDA',
            'estadoVerificacion': 'VERIFICADA',
            'fechaAtencion': '2026-10-11 19:40:57',
          },
        },
      });

      expect(created.datos?.idDgoAlertasMovilCiu, 3);
      expect(created.datos?.notificacionesEnviadas, 1);
      expect(attended.datos?.idGenUsuarioAtiende, 55948);
      expect(attended.datos?.estadoVerificacion, 'VERIFICADA');
    });
  });
}
