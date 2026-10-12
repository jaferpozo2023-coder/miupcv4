part of '../pages.dart';

class MenuPrincipalPage extends GetView<MenuPrincipalController> {
  const MenuPrincipalPage({super.key});

  @override
  Widget build(BuildContext context) => WorkAreaMenuPageWidget(
    peticionServer: controller.peticionServerState,
    contenido: SingleChildScrollView(
      key: const ValueKey('menu-scroll'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConnectionStatusBanner(status: controller.status),
              _cabecera(),
              const SizedBox(height: 20),
              _modulos(),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _cabecera() => Obx(() {
    final metodo = controller.getMetodoAuthUI(controller.metodoRegistro.value);
    return InstitutionalPanel(
      key: const ValueKey('menu-user-card'),
      radius: BorderRadius.circular(20),
      colors: const [Color(0xFF0A2542), Color(0xFF10476B)],
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                InstitutionalAvatar(
                  key: const ValueKey('menu-profile-avatar'),
                  bytes: controller.fotoPerfilBytes.value,
                  size: 62,
                  destacado: true,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            controller.obtenerSaludo(),
                            style: const TextStyle(
                              color: Color(0xFF92D8E4),
                              fontSize: 10.5,
                            ),
                          ),
                          Text(
                            _fechaPerfil(),
                            style: const TextStyle(
                              color: Color(0xFF93B2C9),
                              fontSize: 9.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.userPref.value.isEmpty
                            ? 'Usuario'
                            : controller.userPref.value,
                        key: const ValueKey('menu-user-name'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      _contactoCompacto(
                        metodo['icono'] as IconData,
                        controller.documentoUsuario.value.isEmpty
                            ? 'Perfil sin registro'
                            : metodo['titulo'] as String,
                        muted: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (controller.correoUsuario.value.isNotEmpty ||
                controller.telefonoUsuario.value.isNotEmpty ||
                controller.documentoUsuario.value.isNotEmpty) ...[
              Divider(
                height: 20,
                thickness: 0.6,
                color: Colors.white.withValues(alpha: 0.14),
              ),
              if (controller.correoUsuario.value.isNotEmpty)
                _contactoCompacto(
                  Icons.email_outlined,
                  controller.correoUsuario.value,
                ),
              if (controller.correoUsuario.value.isNotEmpty &&
                  (controller.telefonoUsuario.value.isNotEmpty ||
                      controller.documentoUsuario.value.isNotEmpty))
                const SizedBox(height: 6),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  if (controller.telefonoUsuario.value.isNotEmpty)
                    _contactoCompacto(
                      Icons.phone_iphone_rounded,
                      controller.telefonoUsuario.value,
                    ),
                  if (controller.documentoUsuario.value.isNotEmpty)
                    _contactoCompacto(
                      Icons.badge_outlined,
                      'Cédula: ${controller.documentoUsuario.value}',
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  });

  String _fechaPerfil() {
    final fecha = DateTime.now();
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  Widget _contactoCompacto(IconData icon, String value, {bool muted = false}) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: muted ? 12 : 13, color: const Color(0xFF71C8DF)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: muted
                    ? const Color(0xFF93B2C9)
                    : const Color(0xFFDCE9F3),
                fontSize: muted ? 9.5 : 10.5,
                height: 1.25,
              ),
            ),
          ),
        ],
      );

  Widget _modulos() => Obx(() {
    final todos = controller.listaModulo.toList();

    final modulos = todos
        .asMap()
        .entries
        .where(
          (entry) =>
              !controller.esModuloAlertas(entry.value) ||
              controller.mostrarModuloAlertas.value,
        )
        .toList();

    if (todos.isEmpty) {
      final error = controller.errorCargaModulos.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Text(
              error.isEmpty ? 'Cargando módulos...' : error,
              textAlign: TextAlign.center,
            ),
            if (error.isNotEmpty)
              TextButton.icon(
                onPressed: controller.cargarDatosLista,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 3
            : constraints.maxWidth < 310
            ? 1
            : 2;

        final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final cardWidth =
            (constraints.maxWidth - 8 - 12 * (columns - 1)) / columns;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            mainAxisExtent:
                (scale > 1.15
                    ? 220.0
                    : (cardWidth * 0.98).clamp(175.0, 245.0)) +
                (scale - 1).clamp(0, 2) * 90,
          ),
          itemCount: modulos.length,
          itemBuilder: (context, index) {
            final entry = modulos[index];
            final originalIndex = entry.key;
            final modulo = entry.value;

            return ModuleCard(
              title: modulo.tituloModulo,
              base64Img: modulo.imgBase64.isEmpty ? null : modulo.imgBase64,
              destacado: controller.esModuloAlertas(modulo),
              onTap: () => muestraPantalla(originalIndex),
            );
          },
        );
      },
    );
  });
  Future<void> muestraPantalla(int index) async {
    if (index < 0 || index >= controller.listaModulo.length) return;
    final modulo = controller.listaModulo[index];
    final titulo = controller.normalizarTituloModulo(modulo.tituloModulo);
    final enLinea = controller.status.value == ConnectionStatus.online;
    if (controller.esModuloAlertas(modulo)) {
      if (!controller.mostrarModuloAlertas.value) return;
      await Get.toNamed(AppRoutes.alertasCiudadanas);
      await controller.actualizarPermisosAlertas();
      return;
    }
    if (titulo.contains('UPC') &&
        (titulo.contains('ENCUENTRA') || titulo.contains('CERCANA'))) {
      if (!enLinea) {
        DialogosAwesome.getError(descripcion: 'No tiene conexión a Internet');
        return;
      }
      await controller.verificarGps(modulo: modulo);
      return;
    }
    final servicio = titulo.contains('VIOLENCIA')
        ? '3'
        : titulo.contains('SERVICIOS')
        ? '1'
        : titulo.contains('AUTOPROTECCION')
        ? '2'
        : null;
    if (servicio != null) {
      Get.toNamed(
        AppRoutes.SERVICIOS,
        parameters: {
          'id': servicio,
          'imagen': modulo.imgBase64,
          'nombreModulo': modulo.tituloModulo,
        },
      );
      return;
    }
    DialogosAwesome.getInformation(
      descripcion:
          'No hay una pantalla configurada para la opción "${modulo.tituloModulo}".',
    );
  }
}
