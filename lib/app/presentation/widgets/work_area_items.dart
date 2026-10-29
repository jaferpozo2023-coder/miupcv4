part of 'custom_widgets.dart';

class WorkAreaItemsPageWidget extends StatefulWidget {
  final RxBool peticionServer;
  final String title;
  final String titleAppBar;
  final String name;
  final Widget contenido;
  final bool btnAtras;
  final VoidCallback? pantallaIrAtras;
  final Widget? widgetBtnFinal;
  final EdgeInsetsGeometry? paddin;
  final FloatingActionButtonLocation ubicacionBtnFinal;
  final String? imgFondo;
  final double sizeTittle;
  final bool mostrarVersion;
  final String? foto64;

  const WorkAreaItemsPageWidget({
    required this.peticionServer,
    this.title = '',
    this.titleAppBar = '',
    required this.contenido,
    this.btnAtras = false,
    this.widgetBtnFinal,
    this.paddin,
    this.ubicacionBtnFinal = FloatingActionButtonLocation.centerFloat,
    this.imgFondo,
    this.sizeTittle = 0,
    this.mostrarVersion = false,
    this.pantallaIrAtras,
    this.name = '',
    this.foto64,
  });

  @override
  _WorkAreaItemsPageWidgetState createState() =>
      _WorkAreaItemsPageWidgetState();
}

class _WorkAreaItemsPageWidgetState extends State<WorkAreaItemsPageWidget> {
  String ver = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  _loadVersion() async {
    String _version = await UtilidadesUtil.getVersionCodeNameApp();
    if (!mounted) return;
    setState(() {
      ver = _version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtil();

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: _buildBackground(responsive)),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: getAppBar(widget.titleAppBar),
          bottomNavigationBar: bannerInferior(responsive),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                /// Contenido protegido por SafeArea
                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: widget.paddin ?? const EdgeInsets.all(6.0),
                      child: widget.contenido,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        /// El overlay ocupa la ruta completa y centra la carga en la pantalla.
        Obx(() => CargandoWidget(mostrar: widget.peticionServer.value)),
      ],
    );
  }

  Widget _buildBackground(ResponsiveUtil responsive) {
    return SizedBox(
      height: responsive.alto,
      width: responsive.ancho,
      child: Image.asset(
        widget.imgFondo ?? AppImages.imgarea,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget imgBanner({
    required GestureTapCallback onTap,
    required String ruta,
    required ResponsiveUtil responsive,
  }) {
    double size = responsive.isVertical()
        ? responsive.altoP(8)
        : responsive.anchoP(8);
    return SizedBox(
      height: size,
      width: size,
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(ruta),
        ),
      ),
    );
  }

  AppBar getAppBar(String titleAppBar) => institutionalAppBar(
    context,
    title: titleAppBar,
    showBackButton: widget.btnAtras,
    onBack: widget.pantallaIrAtras,
    image: widget.foto64 == null || widget.foto64!.isEmpty
        ? null
        : CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: MemoryImage(base64Decode(widget.foto64!)),
          ),
  );

  Widget bannerInferior(ResponsiveUtil responsive) =>
      const InstitutionalSocialFooter();
}
