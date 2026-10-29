part of 'custom_widgets.dart';

AppBar institutionalAppBar(
  BuildContext context, {
  required String title,
  bool showBackButton = false,
  VoidCallback? onBack,
  Widget? leading,
  Widget? image,
  FontStyle fontStyle = FontStyle.normal,
}) {
  final hasLeading = leading != null || showBackButton;
  const titleSpacing = 12.0;
  const imageWidth = 36.0;
  final style = Theme.of(context).textTheme.titleLarge!.copyWith(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontStyle: fontStyle,
    letterSpacing: .15,
    height: 1.2,
  );
  final availableWidth = max(
    48.0,
    MediaQuery.sizeOf(context).width -
        MediaQuery.paddingOf(context).horizontal -
        (hasLeading ? kToolbarHeight : 0) -
        titleSpacing * 2 -
        (image == null ? 0 : imageWidth + 8),
  );
  final painter = TextPainter(
    text: TextSpan(text: title, style: style),
    textDirection: Directionality.of(context),
    textScaler: MediaQuery.textScalerOf(context),
    locale: Localizations.maybeLocaleOf(context),
  )..layout(maxWidth: availableWidth);
  final toolbarHeight = max(kToolbarHeight, painter.height.ceilToDouble() + 20);
  painter.dispose();

  return AppBar(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    automaticallyImplyLeading: false,
    centerTitle: true,
    titleSpacing: titleSpacing,
    toolbarHeight: toolbarHeight,
    leadingWidth: hasLeading ? kToolbarHeight : 0,
    systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xFF06245B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    flexibleSpace: const InstitutionalPanel(
      radius: BorderRadius.vertical(bottom: Radius.circular(18)),
      colors: [Color(0xFF06245B), Color(0xFF195BA6)],
      child: SizedBox.expand(),
    ),
    leading:
        leading ??
        (showBackButton
            ? IconButton(
                tooltip: 'Atrás',
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                onPressed: onBack ?? () => Get.back(),
              )
            : null),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (image != null) ...[
          SizedBox(width: imageWidth, height: imageWidth, child: image),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            overflow: TextOverflow.visible,
            style: style,
          ),
        ),
      ],
    ),
  );
}
