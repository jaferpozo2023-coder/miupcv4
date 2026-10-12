part of 'custom_widgets.dart';

class InstitutionalPanel extends StatelessWidget {
  final Widget child;
  final BorderRadius radius;
  final List<Color> colors;

  const InstitutionalPanel({
    super.key,
    required this.child,
    this.radius = const BorderRadius.all(Radius.circular(24)),
    this.colors = const [
      Color(0xFF0B2E59),
      Color(0xFF195BA6),
      Color(0xFF6C7B8B),
    ],
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: radius,
      boxShadow: const [
        BoxShadow(
          color: Color(0x26195BA6),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _InstitutionalCircuitPainter()),
              ),
            ),
            child,
          ],
        ),
      ),
    ),
  );
}

class InstitutionalAvatar extends StatelessWidget {
  final Uint8List? bytes;
  final double size;
  final bool destacado;

  const InstitutionalAvatar({
    super.key,
    this.bytes,
    this.size = 64,
    this.destacado = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    padding: EdgeInsets.all(destacado ? 5 : 3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: destacado
            ? const [Colors.white, Color(0xFF92D8FF), Color(0xFFB0CADD)]
            : const [Colors.white, Color(0xFFB0CADD)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: destacado
          ? Border.all(color: Colors.white.withValues(alpha: 0.65))
          : null,
      boxShadow: [
        if (destacado)
          const BoxShadow(
            color: Color(0x4563BFFF),
            blurRadius: 22,
            spreadRadius: 2,
          ),
        const BoxShadow(
          color: Color(0x50062148),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF195BA6),
          width: destacado ? 2 : 0,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(destacado ? 2 : 0),
        child: CircleAvatar(
          backgroundColor: const Color(0xFFF0F5FA),
          backgroundImage: bytes == null ? null : MemoryImage(bytes!),
          child: bytes == null
              ? Icon(
                  Icons.person_rounded,
                  color: const Color(0xFF6C7B8B),
                  size: size * 0.52,
                )
              : null,
        ),
      ),
    ),
  );
}

class _InstitutionalCircuitPainter extends CustomPainter {
  const _InstitutionalCircuitPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x12D0ECFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = drawing.Path()
      ..moveTo(size.width * 0.68, 0)
      ..lineTo(size.width * 0.68, size.height * 0.20)
      ..lineTo(size.width * 0.88, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.45)
      ..moveTo(size.width * 0.82, 0)
      ..lineTo(size.width * 0.82, size.height * 0.13)
      ..lineTo(size.width * 0.96, size.height * 0.30)
      ..lineTo(size.width, size.height * 0.30)
      ..moveTo(size.width, size.height * 0.78)
      ..lineTo(size.width * 0.86, size.height * 0.78)
      ..lineTo(size.width * 0.75, size.height);
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.45), 3, paint);
    canvas.drawCircle(Offset(size.width * 0.86, size.height * 0.78), 3, paint);
  }

  @override
  bool shouldRepaint(covariant _InstitutionalCircuitPainter oldDelegate) =>
      false;
}
