part of 'custom_widgets.dart';

class InstitutionalSocialFooter extends StatelessWidget {
  const InstitutionalSocialFooter({super.key});

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('institutional-social-footer'),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF195BA6), Color(0xFF06245B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      border: Border(
        top: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x26051B3A),
          blurRadius: 18,
          offset: Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _InstitutionalSocialButton(
              asset: AppImages.imgFacebook,
              name: 'Facebook',
              url: 'https://www.facebook.com/policia.ecuador',
            ),
            _InstitutionalSocialButton(
              asset: AppImages.imgTwitter,
              name: 'X',
              url: 'https://twitter.com/PoliciaEcuador',
            ),
            _InstitutionalSocialButton(
              asset: AppImages.imgInstagran,
              name: 'Instagram',
              url: 'https://www.instagram.com/policiaecuadoroficial',
            ),
            _InstitutionalSocialButton(
              asset: AppImages.imgYoutube,
              name: 'YouTube',
              url: 'https://www.youtube.com/user/policiaecuador2',
            ),
          ],
        ),
      ),
    ),
  );
}

class _InstitutionalSocialButton extends StatefulWidget {
  final String asset;
  final String name;
  final String url;

  const _InstitutionalSocialButton({
    required this.asset,
    required this.name,
    required this.url,
  });

  @override
  State<_InstitutionalSocialButton> createState() =>
      _InstitutionalSocialButtonState();
}

class _InstitutionalSocialButtonState
    extends State<_InstitutionalSocialButton> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: widget.name,
    child: AnimatedScale(
      scale: _presionado ? 0.92 : 1,
      duration: const Duration(milliseconds: 140),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.18),
                Colors.white.withValues(alpha: 0.07),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x20031C43),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTapDown: (_) => setState(() => _presionado = true),
            onTapCancel: () => setState(() => _presionado = false),
            onTapUp: (_) => setState(() => _presionado = false),
            onTap: () => launchUrl(
              Uri.parse(widget.url),
              mode: LaunchMode.inAppBrowserView,
            ),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Image.asset(widget.asset, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    ),
  );
}
