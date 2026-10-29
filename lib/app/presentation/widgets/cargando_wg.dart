part of 'custom_widgets.dart';

class CargandoWidget extends StatelessWidget {
  final bool mostrar;

  const CargandoWidget({super.key, required this.mostrar});

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
                  constraints.maxWidth * 0.82,
                  constraints.maxHeight * 0.5,
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
                      child: Column(
                        key: const ValueKey('institutional-loading-icon'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: size,
                            height: size,
                            child: Loading(
                              radius: size * 0.18,
                              dotRadius: size * 0.08,
                            ),
                          ),
                        ],
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
