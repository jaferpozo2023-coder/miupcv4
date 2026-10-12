part of '../pages.dart';

class ServiciosPage extends GetView<ServiciosController> {
  const ServiciosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return WorkAreaItemsPageWidget(
      titleAppBar: controller.nombreModulo,
      btnAtras: true,
      peticionServer: controller.peticionServerState,
      contenido: getContenido(),
      foto64: controller.imagenModulo,
    );
  }

  /// 📦 Contenido general con scroll y grid
  Widget getContenido() {
    final responsive = ResponsiveUtil();
    return Padding(
      padding: EdgeInsets.only(top: responsive.altoP(1.5)),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // 🔹 Estado de conexión
                ConnectionStatusBanner(status: controller.status),

                // 🔹 Grid de servicios
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: SizedBox(
                      width: double.infinity,
                      child: getGridServicios(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🧩 GRID PRINCIPAL DE SERVICIOS
  Widget getGridServicios() {
    final responsive = ResponsiveUtil();
    return Obx(() {
      final servicios = controller.listaServicios.toList();
      final serviceCount = controller.listaServicios.length;
      final error = controller.errorCargaServicios.value;

      return Column(
        children: [
          // 📋 GRID
          if (serviceCount == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Column(
                children: [
                  Icon(
                    error.isEmpty
                        ? Icons.hourglass_empty_rounded
                        : Icons.info_outline_rounded,
                    size: 34,
                    color: Colors.blueGrey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    error.isEmpty ? 'Cargando opciones...' : error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (error.isNotEmpty)
                    TextButton.icon(
                      onPressed: controller.cargarDatosLista,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 900
                    ? 4
                    : width >= 560
                    ? 3
                    : 2;
                final spacing = width < 560 ? 12.0 : 20.0;
                final cardWidth =
                    (width - responsive.anchoP(4) - spacing * (columns - 1)) /
                    columns;
                final cardHeight = (cardWidth * 1.05).clamp(185.0, 245.0);

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.anchoP(2),
                    vertical: responsive.altoP(1),
                  ),
                  itemCount: servicios.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: width < 560 ? 14 : 20,
                    mainAxisExtent: cardHeight,
                  ),
                  itemBuilder: (context, ind) {
                    final servicio = servicios[ind];
                    return Obx(() {
                      final isSelected = controller.selectedIndex.value == ind;
                      return AnimatedScale(
                        scale: isSelected ? 0.97 : 1,
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: const LinearGradient(
                                colors: [Colors.white, Color(0xFFF4F8FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF195BA6)
                                    : const Color(0xFFDCE6F0),
                                width: isSelected ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF195BA6)
                                      .withOpacity(isSelected ? 0.14 : 0.08),
                                  blurRadius: isSelected ? 14 : 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTapDown: (_) =>
                                  controller.selectedIndex.value = ind,
                              onTapCancel: () =>
                                  controller.selectedIndex.value = -1,
                              onTap: () async {
                                await Future.delayed(
                                  const Duration(milliseconds: 80),
                                );
                                controller.selectedIndex.value = -1;
                                await getDatosServicio(ind);
                              },
                              child: LayoutBuilder(
                                builder: (context, tileConstraints) {
                                  final imageSize =
                                      (tileConstraints.maxHeight * 0.35).clamp(
                                        56.0,
                                        82.0,
                                      );
                                  return Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: imageSize + 16,
                                          height: imageSize + 16,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEAF2FA),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: servicio.imgBase64.isEmpty
                                              ? Image.asset(
                                                  AppImages.vineta,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.memory(
                                                  base64Decode(
                                                    servicio.imgBase64,
                                                  ),
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) =>
                                                      Image.asset(
                                                        AppImages.vineta,
                                                        fit: BoxFit.contain,
                                                      ),
                                                ),
                                        ),
                                        const SizedBox(height: 12),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              servicio.descripcion
                                                  .toUpperCase(),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF06245B),
                                                height: 1.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Color(0xFF195BA6),
                                          size: 19,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              },
            ),
        ],
      );
    });
  }

  /// 🔍 Acción al tocar un servicio
  Future<void> getDatosServicio(int ind) async {
    String resumen = controller.listaServicios[ind].resumen.toString();
    String img = controller.listaServicios[ind].imgBase64;
    int id = controller.listaServicios[ind].idUpcServicio;
    String servicio = controller.listaServicios[ind].descripcion;

    if (controller.status.value == ConnectionStatus.online) {
      await controller.cargarDatosDetalleLista(id);
    } else {
      controller.cargarDatosDetalleListaOffLine(id);
    }

    if (servicio.toUpperCase().trim() == 'CUENTALE A PAQUITO') {
      if (controller.idGenPersona == 0) {
        DialogosAwesome.getError(
          descripcion: "Para usar esta opción debe registrarse como usuario luego intente nuevamente.",
          btnOkOnPress: () {
            Get.back();
          },
        );
        return;
      }
      Map<String, String> data = {
        "id": "1",
        "imagen": img,
        "nombreModulo": 'Registro Evento',
      };
      Get.toNamed(AppRoutes.REGISTRAR_EVENTO, parameters: data);
    } else {
      DialogosAwesome.getAlertDetalleServicios(
        title: servicio.toUpperCase(),
        body: bodyDetlleListaServicios(resumen, servicio),
        imagen: img,
      );
    }
  }

  /// 📜 Detalle del servicio seleccionado
  Widget bodyDetlleListaServicios(String resumen, String servicio) {
    final responsive = ResponsiveUtil();
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(responsive.anchoP(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: responsive.altoP(1)),
            Text(
              resumen,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: responsive.diagonalP(1.3),
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
            SizedBox(height: responsive.altoP(1)),
            Text(
              controller.detalle.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.diagonalP(1.3),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF06245B),
              ),
            ),
            getListaItemsServicios(),
          ],
        ),
      ),
    );
  }

  Widget getListaItemsServicios() {
    final responsive = ResponsiveUtil();
    return Column(
      children: [
        Obx(
          () => ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.listaItemsServicios.length,
            itemBuilder: (context, ind) {
              final item = controller.listaItemsServicios[ind];
              return Padding(
                padding: EdgeInsets.only(bottom: responsive.altoP(1)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle,
                      size: responsive.diagonalP(0.8),
                      color: Colors.blueGrey[400],
                    ),
                    SizedBox(width: responsive.anchoP(2)),
                    Expanded(
                      child: Text(
                        item.descripcion,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: responsive.diagonalP(1.2),
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
