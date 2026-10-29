part of 'custom_widgets.dart';

class InstitutionalSocialFooter extends StatefulWidget {
  final bool showAppInfo;

  const InstitutionalSocialFooter({super.key, this.showAppInfo = false});

  @override
  State<InstitutionalSocialFooter> createState() =>
      _InstitutionalSocialFooterState();
}

class _InstitutionalSocialFooterState extends State<InstitutionalSocialFooter> {
  late final Future<String> _versionApp;

  @override
  void initState() {
    super.initState();
    _versionApp = widget.showAppInfo
        ? UtilidadesUtil.getVersionCodeNameApp()
        : Future.value('');
  }

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
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: widget.showAppInfo ? 4 : 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _InstitutionalSocialButton(
                  asset: AppImages.imgFacebook,
                  name: 'Facebook',
                  url: 'https://www.facebook.com/policia.ecuador',
                  compact: widget.showAppInfo,
                ),
                _InstitutionalSocialButton(
                  asset: AppImages.imgTwitter,
                  name: 'X',
                  url: 'https://twitter.com/PoliciaEcuador',
                  compact: widget.showAppInfo,
                ),
                _InstitutionalSocialButton(
                  asset: AppImages.imgInstagran,
                  name: 'Instagram',
                  url: 'https://www.instagram.com/policiaecuadoroficial',
                  compact: widget.showAppInfo,
                ),
                _InstitutionalSocialButton(
                  asset: AppImages.imgYoutube,
                  name: 'YouTube',
                  url: 'https://www.youtube.com/user/policiaecuador2',
                  compact: widget.showAppInfo,
                ),
              ],
            ),
            if (widget.showAppInfo) ...[
              const SizedBox(height: 3),
              FutureBuilder<String>(
                future: _versionApp,
                builder: (context, snapshot) {
                  final ambiente = switch (AppConfig.AmbienteUrl) {
                    Ambiente.desarrollo => 'Desarrollo',
                    Ambiente.prueba => 'Prueba',
                    Ambiente.produccion => 'Producción',
                  };
                  final version = snapshot.data;
                  return Text(
                    'Versión ${version ?? '…'}  ·  Ambiente: $ambiente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  );
                },
              ),
            ],
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
  final bool compact;

  const _InstitutionalSocialButton({
    required this.asset,
    required this.name,
    required this.url,
    this.compact = false,
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
          width: widget.compact ? 42 : 48,
          height: widget.compact ? 42 : 48,
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
              padding: EdgeInsets.all(widget.compact ? 9 : 11),
              child: Image.asset(widget.asset, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    ),
  );
}
