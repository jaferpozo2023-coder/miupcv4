part of '../pages.dart';

class MenuPrincipalPage extends GetView<MenuPrincipalController> {
  const MenuPrincipalPage({super.key});

  @override
  Widget build(BuildContext context) => WorkAreaMenuPageWidget(
    peticionServer: controller.peticionServerState,
    contenido: RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        await Future.wait([
          controller.cargarDatosLista(forzar: true),
          controller.actualizarPermisosAlertas(),
        ]);
      },
      color: const Color(0xFF0B6581),
      backgroundColor: Colors.white,
      displacement: 42,
      child: SingleChildScrollView(
        key: const ValueKey('menu-scroll'),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConnectionStatusBanner(status: controller.status),
                _cabecera(),
                const SizedBox(height: 16),
                _modulos(),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _cabecera() => Obx(() {
    final metodo = controller.getMetodoAuthUI(controller.metodoRegistro.value);
    final nombre = controller.userPref.value.isEmpty ? 'Usuario' : controller.userPref.value;
    final foto = controller.fotoPerfilBytes.value;
    final correo = controller.correoUsuario.value;
    final telefono = controller.telefonoUsuario.value;
    final documento = controller.documentoUsuario.value;
    return Container(
      key: const ValueKey('menu-user-card'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF041827), Color(0xFF073A57), Color(0xFF0A6277)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, .58, 1],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x4D66D9E8), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x33031A2A), blurRadius: 22, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x1A35C3D7), blurRadius: 16, spreadRadius: -4),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(right: -38, top: -46, child: Container(width: 145, height: 145, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x1668E7F3), width: 18)))),
            Positioned(right: 28, bottom: -52, child: Transform.rotate(angle: -.35, child: Container(width: 145, height: 78, decoration: BoxDecoration(border: Border.all(color: const Color(0x1269E0EA)), borderRadius: BorderRadius.circular(18))))),
            Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 3, decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF5FE4E9), Color(0xFF0E7DA0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 11, 13, 11),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final avatarSize = constraints.maxWidth < 360 ? 58.0 : 66.0;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFF71F0EE), Color(0xFF2B8EB3)]),
                              boxShadow: const [BoxShadow(color: Color(0x5539CED9), blurRadius: 14)],
                            ),
                            child: InstitutionalAvatar(key: const ValueKey('menu-profile-avatar'), bytes: foto, size: avatarSize, destacado: false),
                          ),
                          Positioned(
                            right: -1,
                            bottom: 1,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(color: const Color(0xFF19C892), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF063149), width: 2)),
                              child: const Icon(Icons.check_rounded, size: 11, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${controller.obtenerSaludo().toUpperCase()} · PERFIL CIUDADANO',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF8FE6EA), fontSize: 8.5, fontWeight: FontWeight.w800, letterSpacing: .75),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _estadoAuth(metodo),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nombre,
                              key: const ValueKey('menu-user-name'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w900, height: 1.05, letterSpacing: .1),
                            ),
                            if (documento.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text('ID · $documento', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFB9D7E1), fontSize: 9.5, fontWeight: FontWeight.w600, letterSpacing: .35)),
                            ],
                            if (correo.isNotEmpty || telefono.isNotEmpty) ...[
                              const SizedBox(height: 7),
                              Wrap(
                                spacing: 6,
                                runSpacing: 5,
                                children: [
                                  if (telefono.isNotEmpty) _datoChip(Icons.phone_iphone_rounded, telefono),
                                  if (correo.isNotEmpty) _datoChip(Icons.alternate_email_rounded, correo),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  });

  Widget _estadoAuth(Map<String, dynamic> metodo) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(.12))),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(metodo['icono'] as IconData, size: 11, color: metodo['color'] as Color),
        const SizedBox(width: 3),
        Text(metodo['titulo'] as String, style: const TextStyle(color: Color(0xFFD9EEF2), fontSize: 8.3, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _datoChip(IconData icon, String value) => Container(
    constraints: const BoxConstraints(maxWidth: 230),
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(color: const Color(0x1400E5FF), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0x226CE7EF))),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: const Color(0xFF75DCE8)),
        const SizedBox(width: 4),
        Flexible(child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFD7EAF0), fontSize: 9.2, fontWeight: FontWeight.w600))),
      ],
    ),
  );

  Widget _modulos() => Obx(() {
    final todos = controller.listaModulo.toList();
    final tieneModuloAlertas = todos.any(controller.esModuloAlertas);
    final esperandoPermisosAlertas = tieneModuloAlertas &&
        (!controller.permisoAlertasInicializado.value ||
            !controller.permisoNotificacionesInicializado.value);
    final modulos = todos.asMap().entries.where((entry) {
      if (!controller.esModuloAlertas(entry.value)) return true;
      return controller.puedeMostrarModuloAlertas || esperandoPermisosAlertas;
    }).toList();
    if (todos.isEmpty) {
      final error = controller.errorCargaModulos.value;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            if (error.isEmpty) ...[
              const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0A6380))),
              const SizedBox(height: 12),
            ],
            Text(error.isEmpty ? 'Cargando servicios...' : error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF405867))),
            if (error.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(onPressed: () => controller.cargarDatosLista(forzar: true), icon: const Icon(Icons.refresh_rounded), label: const Text('Reintentar')),
            ],
          ],
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = constraints.maxWidth >= 700 ? 20.0 : 12.0;
        final availableWidth = constraints.maxWidth - 8;
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        final minimumWidth = (150 * textScale).clamp(150.0, 260.0);
        final columns = ((availableWidth + spacing) / (minimumWidth + spacing)).floor().clamp(1, 4);
        final cardWidth = (availableWidth - spacing * (columns - 1)) / columns;
        final cardHeight = (ModuleCard.heightForWidth(cardWidth, MediaQuery.textScalerOf(context)) - 30).clamp(130.0, 300.0).toDouble();
        return Padding(
          padding: const EdgeInsets.all(4),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing + 4,
            children: [
              for (final entry in modulos)
                SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: controller.esModuloAlertas(entry.value) &&
                          esperandoPermisosAlertas
                      ? _cargandoModuloAlertas()
                      : ModuleCard(
                          title: entry.value.tituloModulo,
                          base64Img: entry.value.imgBase64.isEmpty
                              ? null
                              : entry.value.imgBase64,
                          destacado: controller.esModuloAlertas(entry.value),
                          onTap: () => muestraPantalla(entry.key),
                        ),
                ),
            ],
          ),
        );
      },
    );
  });

  Widget _cargandoModuloAlertas() => Semantics(
    liveRegion: true,
    label: 'Verificando permisos del módulo de alertas',
    child: Container(
      key: const ValueKey('alert-module-loading'),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD8E5ED)),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF0A6380),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Cargando alertas...',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF405867),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> muestraPantalla(int index) async {
    if (index < 0 || index >= controller.listaModulo.length) return;
    final modulo = controller.listaModulo[index];
    final titulo = controller.normalizarTituloModulo(modulo.tituloModulo);
    final enLinea = controller.status.value == ConnectionStatus.online;
    if (controller.esModuloAlertas(modulo)) {
      if (!controller.mostrarModuloAlertas.value) return;
      if (!await controller.actualizarPermisoNotificaciones()) {
        DialogosAwesome.getInformation(
          descripcion:
              'Active las notificaciones en los ajustes del dispositivo para acceder al módulo de alertas.',
        );
        return;
      }
      await Get.toNamed(AppRoutes.alertasCiudadanas);
      await controller.actualizarPermisosAlertas();
      return;
    }
    if (titulo.contains('UPC') && (titulo.contains('ENCUENTRA') || titulo.contains('CERCANA'))) {
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
      Get.toNamed(AppRoutes.SERVICIOS, parameters: {'id': servicio, 'imagen': modulo.imgBase64, 'nombreModulo': modulo.tituloModulo});
      return;
    }
    DialogosAwesome.getInformation(descripcion: 'No hay una pantalla configurada para la opción "${modulo.tituloModulo}".');
  }
}