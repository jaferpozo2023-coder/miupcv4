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

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.destacado
        ? const Color(0xFFD94B4B)
        : const Color(0xFF195BA6);

    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 140),
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
              color: widget.destacado
                  ? const Color(0xFFD94B4B).withOpacity(0.5)
                  : const Color(0xFFDCE6F0),
              width: widget.destacado ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(_pressed ? 0.08 : 0.12),
                blurRadius: _pressed ? 8 : 16,
                offset: Offset(0, _pressed ? 3 : 7),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool horizontal =
                    constraints.maxWidth > constraints.maxHeight * 1.35;
                final double imageSize = horizontal
                    ? 72
                    : (constraints.maxHeight * 0.34).clamp(54.0, 78.0);

                return Stack(
                  children: [
                    Positioned(
                      right: -24,
                      bottom: -34,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withOpacity(0.045),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(horizontal ? 18 : 12),
                      child: horizontal
                          ? _buildHorizontal(imageSize, accentColor)
                          : _buildVertical(constraints, imageSize, accentColor),
                    ),
                    if (widget.destacado) _buildFeaturedBadge(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontal(double imageSize, Color accentColor) {
    return Row(
      children: [
        _buildAvatar(imageSize, accentColor),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextContent(
            accentColor,
            crossAxisAlignment: CrossAxisAlignment.start,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _buildVertical(
    BoxConstraints constraints,
    double imageSize,
    Color accentColor,
  ) {
    final bool compact = constraints.maxHeight < 195;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAvatar(imageSize, accentColor),
        SizedBox(height: compact ? 7 : 12),
        Expanded(
          child: _buildTextContent(
            accentColor,
            crossAxisAlignment: CrossAxisAlignment.center,
            textAlign: TextAlign.center,
            compact: compact,
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent(
    Color accentColor, {
    required CrossAxisAlignment crossAxisAlignment,
    required TextAlign textAlign,
    bool compact = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          widget.title.trim().isEmpty ? 'MÓDULO' : widget.title.toUpperCase(),
          textAlign: textAlign,
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF06245B),
            letterSpacing: 0.25,
            height: 1.2,
          ),
        ),
        SizedBox(height: compact ? 4 : 7),
        Text(
          'Acceder al módulo',
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: compact ? 10.5 : 11.5,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey.shade500,
          ),
        ),
        SizedBox(height: compact ? 7 : 10),
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [accentColor, const Color(0xFF6C7B8B)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(double size, Color accentColor) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [accentColor, const Color(0xFF6C7B8B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: _buildImageContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    final image = widget.base64Img;
    if (image == null || image.trim().isEmpty) {
      return _buildFallbackIcon();
    }

    try {
      return Image.memory(
        base64Decode(image),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    } on FormatException {
      return _buildFallbackIcon();
    }
  }

  Widget _buildFallbackIcon() {
    final titulo = widget.title.toUpperCase();
    final icono = titulo.contains('DENUNCIAS') || titulo.contains('ALERTAS')
        ? Icons.campaign_rounded
        : titulo.contains('UPC')
        ? Icons.location_city_rounded
        : titulo.contains('VIOLENCIA')
        ? Icons.health_and_safety_rounded
        : titulo.contains('SERVICIOS')
        ? Icons.local_police_rounded
        : titulo.contains('AUTOPROTECC')
        ? Icons.shield_rounded
        : Icons.grid_view_rounded;
    return Center(child: Icon(icono, size: 30, color: const Color(0xFF195BA6)));
  }

  Widget _buildFeaturedBadge() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFD94B4B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'DESTACADO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
