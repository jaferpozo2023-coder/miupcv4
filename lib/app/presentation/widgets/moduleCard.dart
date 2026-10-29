part of 'custom_widgets.dart';

class ModuleCard extends StatefulWidget {
  final String title;
  final String? base64Img;
  final VoidCallback onTap;
  final bool destacado;

  const ModuleCard({
    super.key,
    required this.title,
    this.base64Img,
    this.destacado = false,
    required this.onTap,
  });

  static ({double padding, double fontSize, double imageSize}) _metrics(
    double width,
  ) {
    final compact = width < 185;
    return (
      padding: compact ? 14.0 : 18.0,
      fontSize: compact ? 12.5 : 14.0,
      imageSize: (width * 0.40).clamp(68.0, 84.0),
    );
  }

  static double heightForWidth(double width, TextScaler textScaler) {
    final metrics = _metrics(width);
    final titleHeight = (textScaler.scale(metrics.fontSize) * 1.3 * 3).ceilToDouble() + 2;
    return metrics.padding * 2 + metrics.imageSize +
        26 +
        12 +
        titleHeight +
        10 +
        18;
  }

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _pressed = false;
  bool _hovered = false;
  bool _focused = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _decodeImage();
  }

  @override
  void didUpdateWidget(covariant ModuleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64Img != widget.base64Img) _decodeImage();
  }

  void _decodeImage() {
    final image = widget.base64Img?.trim();
    try {
      _imageBytes = image == null || image.isEmpty ? null : base64Decode(image);
    } on FormatException {
      _imageBytes = null;
    }
  }

  Color get _accent {
    if (widget.destacado) return const Color(0xFFE05D68);
    final title = widget.title.toUpperCase();
    if (title.contains('VIOLENCIA')) return const Color(0xFF6876B0);
    if (title.contains('AUTOPROTECC')) return const Color(0xFF25888C);
    if (title.contains('SERVICIOS')) return const Color(0xFF397BB1);
    return const Color(0xFF247890);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final active = _hovered || _focused;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final radius = BorderRadius.circular(22);
    final backgroundColors = widget.destacado
        ? const [Color(0xFFFFFEFE), Color(0xFFFFF5F4), Color(0xFFFFECEB)]
        : const [Color(0xFFFFFFFF), Color(0xFFF8FBFF), Color(0xFFEAF4FC)];
    final title = widget.title.trim().isEmpty
        ? 'MÓDULO'
        : widget.title.toUpperCase();

    return Semantics(
      button: true,
      label: title,
      onTap: widget.onTap,
      child: ExcludeSemantics(
        child: AnimatedScale(
          scale: _pressed && !reduceMotion ? 0.985 : 1,
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: backgroundColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: radius,
              border: Border.all(
                color: accent.withValues(
                  alpha: active
                      ? 0.56
                      : widget.destacado
                      ? 0.30
                      : 0.20,
                ),
                width: widget.destacado ? 1.3 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF173B64).withValues(alpha: 0.07),
                  blurRadius: 14,
                  offset: Offset(0, _pressed ? 2 : 5),
                ),
                if (widget.destacado)
                  BoxShadow(
                    color: accent.withValues(alpha: active ? 0.14 : 0.08),
                    blurRadius: active ? 20 : 14,
                    offset: const Offset(0, 4),
                  ),
                if (active)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.10),
                    blurRadius: 16,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: radius,
                  onTap: widget.onTap,
                  onHover: (value) => setState(() => _hovered = value),
                  onFocusChange: (value) => setState(() => _focused = value),
                  onTapDown: (_) => setState(() => _pressed = true),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTapCancel: () => setState(() => _pressed = false),
                  splashColor: accent.withValues(alpha: 0.08),
                  highlightColor: accent.withValues(alpha: 0.025),
                  hoverColor: accent.withValues(alpha: 0.025),
                  focusColor: accent.withValues(alpha: 0.06),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final metrics = ModuleCard._metrics(constraints.maxWidth);
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _ModuleCircuitPainter(
                                  accent: accent,
                                  destacado: widget.destacado,
                                ),
                              ),
                            ),
                          ),
                          if (widget.destacado)
                            Positioned(
                              top: 9,
                              right: 10,
                              child: _alertaBadge(accent),
                            ),
                          Padding(
                            padding: EdgeInsets.all(metrics.padding),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildImageArea(metrics.imageSize, accent),
                                const SizedBox(height: 2),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: metrics.fontSize,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF163A5D),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea(double size, Color accent) => SizedBox(
    height: size + 26,
    child: Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 30,
            height: size + 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: widget.destacado ? 0.18 : 0.13),
                  accent.withValues(alpha: 0.035),
                  accent.withValues(alpha: 0),
                ],
                stops: const [0, 0.62, 1],
              ),
            ),
          ),
          Container(
            width: size + 15,
            height: size + 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: widget.destacado ? 0.30 : 0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.10),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Container(
            width: size + 3,
            height: size + 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.destacado
                    ? const [Color(0xFFFFF7F6), Color(0xFFFFE8E6)]
                    : const [Colors.white, Color(0xFFEAF4FC)],
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF173B64).withValues(alpha: 0.13),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          SizedBox(
            width: size,
            height: size,
            child: _imageBytes == null
                ? _buildFallbackIcon(accent, size)
                : Image.memory(
                    _imageBytes!,
                    fit: BoxFit.contain,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => _buildFallbackIcon(accent, size),
                  ),
          ),
        ],
      ),
    ),
  );

  Widget _buildFallbackIcon(Color accent, double size) {
    final title = widget.title.toUpperCase();
    final icon = title.contains('DENUNCIAS') || title.contains('ALERTAS')
        ? Icons.campaign_rounded
        : title.contains('UPC')
        ? Icons.location_city_rounded
        : title.contains('VIOLENCIA')
        ? Icons.health_and_safety_rounded
        : title.contains('SERVICIOS')
        ? Icons.local_police_rounded
        : title.contains('AUTOPROTECC')
        ? Icons.shield_rounded
        : Icons.grid_view_rounded;
    return Center(
      child: Icon(icon, size: size * 0.62, color: accent),
    );
  }

  Widget _alertaBadge(Color accent) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE2E1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: accent.withValues(alpha: 0.22)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.notifications_active_rounded, size: 10, color: accent),
        const SizedBox(width: 4),
        Text(
          'ALERTAS',
          style: TextStyle(
            color: accent,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
      ],
    ),
  );
}

class _ModuleCircuitPainter extends CustomPainter {
  const _ModuleCircuitPainter({required this.accent, required this.destacado});

  final Color accent;
  final bool destacado;

  @override
  void paint(Canvas canvas, Size size) {
    final trace = Paint()
      ..color = accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final grid = Paint()
      ..color = accent.withValues(alpha: destacado ? 0.075 : 0.055)
      ..style = PaintingStyle.fill;
    for (var row = 0; row < 4; row++) {
      for (var column = 0; column < 5; column++) {
        canvas.drawCircle(
          Offset(
            size.width * 0.08 + column * 13,
            size.height * 0.66 + row * 13,
          ),
          0.8,
          grid,
        );
      }
    }

    final upper = drawing.Path()
      ..moveTo(size.width * 0.68, 0)
      ..lineTo(size.width * 0.68, 12)
      ..lineTo(size.width - 26, 12)
      ..lineTo(size.width - 12, 26)
      ..lineTo(size.width - 12, 52);
    canvas.drawPath(upper, trace);
    canvas.drawCircle(Offset(size.width - 12, 55), 2.5, trace);

    final lower = drawing.Path()
      ..moveTo(0, size.height * 0.87)
      ..lineTo(14, size.height * 0.87)
      ..lineTo(24, size.height * 0.82)
      ..lineTo(39, size.height * 0.82);
    canvas.drawPath(lower, trace);
    canvas.drawCircle(Offset(42, size.height * 0.82), 2, trace);
  }

  @override
  bool shouldRepaint(covariant _ModuleCircuitPainter oldDelegate) =>
      oldDelegate.accent != accent || oldDelegate.destacado != destacado;
}
