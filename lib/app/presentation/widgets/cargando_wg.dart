part of 'custom_widgets.dart';

class CargandoWidget extends StatelessWidget {
  final bool mostrar;

  const CargandoWidget({
    super.key,
    required this.mostrar,
  });

  @override
  Widget build(BuildContext context) {
    if (!mostrar) return const SizedBox.shrink();

    return Positioned.fill(
      child: Semantics(
        liveRegion: true,
        label: 'Cargando',
        child: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final size = [
                  144.0,
                  constraints.maxWidth * 0.42,
                  constraints.maxHeight * 0.3,
                ].reduce((a, b) => a < b ? a : b).clamp(76.0, 144.0);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(color: const Color(0x42051B3A)),
                    ),
                    const ModalBarrier(
                      dismissible: false,
                      color: Colors.transparent,
                    ),
                    Center(
                      child: SizedBox(
                        key: const ValueKey('institutional-loading-icon'),
                        width: size,
                        height: size,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const SizedBox.expand(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE7B83D),
                                ),
                                backgroundColor: Color(0x667A8CA3),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(size * 0.19),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(size * 0.12),
                                child: Image.asset(
                                  AppImages.iconMiUpc,
                                  key: const ValueKey('mi-upc-loading-image'),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.apartment_rounded,
                                        color: Colors.white,
                                        size: size * 0.55,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
