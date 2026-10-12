import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pne/app/data/models/modulos.dart';
import 'package:pne/app/data/models/permisos_mi_upc_model.dart';
import 'package:pne/app/core/utils/check_internet_conexion.dart';
import 'package:pne/app/data/providers/providers_impl.dart';
import 'package:pne/app/data/repository/data_repositories.dart';
import 'package:pne/app/domain/repositories/domain_repositories.dart';
import 'package:pne/app/presentation/gps/gps_impl_helper.dart';
import 'package:pne/app/presentation/modules/controllers.dart';
import 'package:pne/app/presentation/modules/pages.dart';
import 'package:pne/app/presentation/widgets/custom_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _ModulosStub implements ModulosRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _PermisosStub implements PermisosMiUpcRepository {
  ConsultaPermisosMiUpc respuesta = const ConsultaPermisosMiUpc(
    codeError: 0,
    msj: '',
    datos: [],
  );
  Object? fallo;
  Completer<ConsultaPermisosMiUpc>? pendiente;
  int llamadas = 0;

  @override
  Future<ConsultaPermisosMiUpc> consultarPermisosMiUpc({
    required String documento,
  }) async {
    llamadas++;
    if (pendiente != null) return pendiente!.future;
    if (fallo != null) throw fallo!;
    return respuesta;
  }
}

class _ConexionStub implements CheckInternetConnection {
  @override
  Future<void> close() async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MenuPrueba extends MenuPrincipalController {
  _MenuPrueba() : super(internetChecker: _ConexionStub());
  // Los datos de la pantalla se cargan sin iniciar los servicios del menú.
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  void onReady() {}
}

void main() {
  late _PermisosStub permisos;
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'MI UPC',
      packageName: 'com.miupc',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    Get.put(LocalStoreProviderImpl());
    Get.put(LocalStoreImpl());
    Get.put(GpsController());
    Get.put<ModulosRepository>(_ModulosStub());
    permisos = _PermisosStub();
    Get.put<PermisosMiUpcRepository>(permisos);
  });
  tearDown(() async => Get.reset());

  for (final caso in [
    (
      nombre: 'sin registro',
      documento: '',
      general: false,
      ciudadano: false,
      policial: false,
      visible: false,
    ),
    (
      nombre: 'registrado sin permisos',
      documento: 'cuenta',
      general: false,
      ciudadano: false,
      policial: false,
      visible: false,
    ),
    (
      nombre: 'permiso ciudadano',
      documento: 'cuenta',
      general: true,
      ciudadano: true,
      policial: false,
      visible: true,
    ),
    (
      nombre: 'permiso policial sin detalle del servidor',
      documento: 'cuenta',
      general: true,
      ciudadano: false,
      policial: true,
      visible: true,
    ),
    (
      nombre: 'ambos permisos',
      documento: 'cuenta',
      general: true,
      ciudadano: true,
      policial: true,
      visible: true,
    ),
    (
      nombre: 'permiso general sin rol',
      documento: 'cuenta',
      general: true,
      ciudadano: false,
      policial: false,
      visible: false,
    ),
    (
      nombre: 'permiso general revocado',
      documento: 'cuenta',
      general: false,
      ciudadano: true,
      policial: true,
      visible: false,
    ),
  ]) {
    test('visibilidad de alertas: ${caso.nombre}', () async {
      SharedPreferences.setMockInitialValues({'USER_CEDULA': caso.documento});
      permisos.respuesta = ConsultaPermisosMiUpc(
        codeError: 0,
        msj: '',
        datos: [
          PermisoMiUpc.fromJson({
            'documento': 'cuenta',
            'tienePermiso': caso.general,
            'permisoCiudadano': caso.ciudadano,
            'permisoPolicial': caso.policial,
          }),
        ],
      );
      final menu = Get.put<MenuPrincipalController>(_MenuPrueba());
      await menu.cargarDatosUsuario();
      expect(menu.mostrarModuloAlertas.value, caso.visible);
      expect(permisos.llamadas, caso.documento.isEmpty ? 0 : 1);
    });
  }

  test(
    'oculta alertas si falta el permiso de la cuenta o falla su consulta',
    () async {
      final menu = Get.put<MenuPrincipalController>(_MenuPrueba());
      menu.documentoUsuario.value = 'cuenta';
      permisos.respuesta = ConsultaPermisosMiUpc(
        codeError: 0,
        msj: '',
        datos: [
          PermisoMiUpc.fromJson({
            'documento': 'otra',
            'tienePermiso': true,
            'permisoCiudadano': true,
          }),
        ],
      );
      await menu.actualizarPermisosAlertas();
      expect(menu.mostrarModuloAlertas.value, isFalse);
      permisos.respuesta = const ConsultaPermisosMiUpc(
        codeError: 1,
        msj: 'Error',
        datos: [],
      );
      menu.mostrarModuloAlertas.value = true;
      await menu.actualizarPermisosAlertas();
      expect(menu.mostrarModuloAlertas.value, isFalse);
      permisos.fallo = const SocketException('Sin conexión');
      menu.mostrarModuloAlertas.value = true;
      await menu.actualizarPermisosAlertas();
      expect(menu.mostrarModuloAlertas.value, isFalse);
    },
  );

  test(
    'una consulta anterior no devuelve el acceso después de cambiar la cuenta',
    () async {
      final menu = Get.put<MenuPrincipalController>(_MenuPrueba());
      menu.documentoUsuario.value = 'cuenta';
      final pendiente = Completer<ConsultaPermisosMiUpc>();
      permisos.pendiente = pendiente;
      final consulta = menu.actualizarPermisosAlertas();
      menu.documentoUsuario.value = '';
      await menu.actualizarPermisosAlertas();
      pendiente.complete(
        ConsultaPermisosMiUpc(
          codeError: 0,
          msj: '',
          datos: [
            PermisoMiUpc.fromJson({
              'documento': 'cuenta',
              'tienePermiso': true,
              'permisoCiudadano': true,
            }),
          ],
        ),
      );
      await consulta;
      expect(menu.mostrarModuloAlertas.value, isFalse);
    },
  );

  testWidgets('alertas aparece y desaparece sin ocultar los módulos públicos', (
    tester,
  ) async {
    final menu = Get.put<MenuPrincipalController>(_MenuPrueba());
    menu.listaModulo.assignAll([
      for (final titulo in [
        'DENUNCIAS CIUDADANAS',
        'MEDIDAS DE AUTOPROTECCIÓN',
      ])
        Modulo(
          descripcionModulo: '',
          imgBase64: '',
          idGenEstado: 1,
          idUpcModulosMovil: 1,
          imagenModulo: '',
          ordenModulo: 1,
          tituloModulo: titulo,
        ),
    ]);
    await tester.pumpWidget(const GetMaterialApp(home: MenuPrincipalPage()));
    await tester.pumpAndSettle();
    expect(find.text('DENUNCIAS CIUDADANAS'), findsNothing);
    expect(find.text('MEDIDAS DE AUTOPROTECCIÓN'), findsOneWidget);
    menu.documentoUsuario.value = 'cuenta';
    permisos.respuesta = ConsultaPermisosMiUpc(
      codeError: 0,
      msj: '',
      datos: [
        PermisoMiUpc.fromJson({
          'documento': 'cuenta',
          'tienePermiso': true,
          'permisoCiudadano': true,
        }),
      ],
    );
    await menu.actualizarPermisosAlertas();
    await tester.pumpAndSettle();
    expect(find.text('DENUNCIAS CIUDADANAS'), findsOneWidget);
    permisos.respuesta = const ConsultaPermisosMiUpc(
      codeError: 0,
      msj: '',
      datos: [],
    );
    await menu.actualizarPermisosAlertas();
    await tester.pumpAndSettle();
    expect(find.text('DENUNCIAS CIUDADANAS'), findsNothing);
    expect(find.text('MEDIDAS DE AUTOPROTECCIÓN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(360, 640),
    const Size(640, 360),
    const Size(390, 844),
  ]) {
    testWidgets(
      'menú muestra el usuario y permite llegar al último módulo en $size',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final menu = Get.put<MenuPrincipalController>(_MenuPrueba());
        menu.userPref.value = 'Nombre Apellido del usuario';
        menu.correoUsuario.value = 'usuario@example.com';
        menu.telefonoUsuario.value = '0999999999';
        menu.documentoUsuario.value = '0000000000';
        menu.listaModulo.assignAll([
          for (final title in [
            'DENUNCIAS CIUDADANAS',
            'ENCUENTRA LA UPC MÁS CERCANA',
            'VIOLENCIA DE GÉNERO',
            'SERVICIOS DE POLICÍA COMUNITARIA',
            'MEDIDAS DE AUTOPROTECCIÓN',
          ])
            Modulo(
              descripcionModulo: '',
              imgBase64: '',
              idGenEstado: 1,
              idUpcModulosMovil: 1,
              imagenModulo: '',
              ordenModulo: 1,
              tituloModulo: title,
            ),
        ]);
        const previews = bool.fromEnvironment('CAPTURE_PREVIEWS');
        if (previews) {
          await tester.runAsync(() async {
            final loader = FontLoader('PreviewArial')
              ..addFont(
                Future.value(
                  ByteData.sublistView(
                    await File('/System/Library/Fonts/Supplemental/Arial.ttf')
                        .readAsBytes(),
                  ),
                ),
              )
              ..addFont(
                Future.value(
                  ByteData.sublistView(
                    await File(
                      '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
                    ).readAsBytes(),
                  ),
                ),
              );
            await loader.load();
            final icons = FontLoader('MaterialIcons')
              ..addFont(
                Future.value(
                  ByteData.sublistView(
                    await File(
                      '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/MaterialIcons-Regular.otf',
                    ).readAsBytes(),
                  ),
                ),
              );
            await icons.load();
          });
        }
        await tester.pumpWidget(
          GetMaterialApp(
            theme: ThemeData(fontFamily: previews ? 'PreviewArial' : null),
            home: const RepaintBoundary(
              key: ValueKey('menu-preview'),
              child: MenuPrincipalPage(),
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(size.width == 390 ? 1 : 1.4),
                padding: const EdgeInsets.only(top: 24, bottom: 24),
              ),
              child: child!,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final barra = tester.getRect(find.byType(AppBar));
        final nombre = tester.getRect(
          find.byKey(const ValueKey('menu-user-name')),
        );
        expect(nombre.top, greaterThanOrEqualTo(barra.bottom));
        if (size.width == 390) {
          // La altura visual se comprueba con las fuentes reales de la vista previa.
          if (previews) {
            expect(
              tester
                  .getSize(find.byKey(const ValueKey('menu-user-card')))
                  .height,
              lessThan(185),
            );
          }
          expect(find.text('Cédula: 0000000000'), findsOneWidget);
        }
        if (previews && size.width == 390) {
          await _guardarPreview(tester, 'menu-principal');
        }
        await tester.drag(
          find.byKey(const ValueKey('menu-scroll')),
          const Offset(0, -1800),
        );
        await tester.pumpAndSettle();
        expect(
          find.text('MEDIDAS DE AUTOPROTECCIÓN').hitTestable(),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.byTooltip('Abrir menú'));
        await tester.pumpAndSettle();
        if (previews && size.width == 390) {
          await _guardarPreview(tester, 'menu-lateral');
        }
        final drawer = find.byType(Drawer);
        final botones = find.byKey(const ValueKey('drawer-bottom-actions'));
        final footer = find.descendant(
          of: drawer,
          matching: find.byKey(const ValueKey('institutional-social-footer')),
        );
        final posicionBotones = tester.getRect(botones);
        final posicionFooter = tester.getRect(footer);
        expect(posicionBotones.bottom, closeTo(posicionFooter.top, 0.1));
        expect(posicionFooter.bottom, closeTo(size.height - 24, 0.1));
        await tester.drag(
          find.byKey(const ValueKey('drawer-profile-scroll')),
          const Offset(0, -250),
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(botones), posicionBotones);
        expect(tester.getRect(footer), posicionFooter);
        await tester.ensureVisible(find.text('usuario@example.com').last);
        await tester.pumpAndSettle();
        expect(find.text('usuario@example.com').hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.text('0999999999').last);
        await tester.pumpAndSettle();
        expect(find.text('0999999999').hitTestable(), findsOneWidget);
        await tester.ensureVisible(find.text('Registrar / Editar datos'));
        await tester.pumpAndSettle();
        expect(
          find.text('Registrar / Editar datos').hitTestable(),
          findsOneWidget,
        );
        expect(tester.getRect(footer), posicionFooter);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'área de trabajo mantiene el inicio y final fuera de las barras',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        GetMaterialApp(
          home: WorkAreaItemsPageWidget(
            titleAppBar: 'Formulario',
            peticionServer: false.obs,
            contenido: const Column(
              children: [
                Text('Inicio del contenido'),
                SizedBox(height: 900),
                Text('Fin del contenido'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.text('Inicio del contenido')).top,
        greaterThanOrEqualTo(tester.getRect(find.byType(AppBar)).bottom),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();
      final finalRect = tester.getRect(find.text('Fin del contenido'));
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      final social = tester.getRect(
        find.byWidget(scaffold.bottomNavigationBar!),
      );
      expect(finalRect.bottom, lessThanOrEqualTo(social.top));
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _guardarPreview(WidgetTester tester, String nombre) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('menu-preview')),
  );
  await tester.runAsync(() async {
    final imagen = await boundary.toImage(pixelRatio: 2);
    final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/previews');
    await directory.create(recursive: true);
    await File('${directory.path}/$nombre.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    imagen.dispose();
  });
}
