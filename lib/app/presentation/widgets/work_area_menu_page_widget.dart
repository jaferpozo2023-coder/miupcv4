part of 'custom_widgets.dart';

class WorkAreaMenuPageWidget extends StatefulWidget {
  final RxBool peticionServer;
  final Widget contenido;
  final EdgeInsetsGeometry? paddin;
  final String? imgFondo;

  const WorkAreaMenuPageWidget({
    super.key,
    required this.peticionServer,
    required this.contenido,
    this.paddin,
    this.imgFondo,
  });

  @override
  State<WorkAreaMenuPageWidget> createState() => _WorkAreaMenuPageWidgetState();
}

class _WorkAreaMenuPageWidgetState extends State<WorkAreaMenuPageWidget> {
  final MenuPrincipalController menuController = Get.find();

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      Positioned.fill(
        child: Image.asset(
          widget.imgFondo ?? AppImages.imgarea,
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _appBar(),
        drawer: _drawer(context),
        bottomNavigationBar: const InstitutionalSocialFooter(),
        body: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: widget.paddin ?? EdgeInsets.zero,
            child: widget.contenido,
          ),
        ),
      ),
      Obx(() => CargandoWidget(mostrar: widget.peticionServer.value)),
    ],
  );

  AppBar _appBar() => AppBar(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    toolbarHeight: 72,
    systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: const Color(0xFF06245B),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
    centerTitle: true,
    flexibleSpace: const InstitutionalPanel(
      radius: BorderRadius.vertical(bottom: Radius.circular(24)),
      colors: [Color(0xFF06245B), Color(0xFF195BA6)],
      child: SizedBox.expand(),
    ),
    leadingWidth: 66,
    leading: Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Abrir menú',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
    ),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(AppImages.imgEdificio, height: 40),
        const SizedBox(width: 10),
        const Flexible(
          child: Text(
            'MI UPC',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _drawer(BuildContext context) => Drawer(
    width: min(MediaQuery.sizeOf(context).width * 0.90, 380.0),
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
    ),
    child: InstitutionalPanel(
      radius: const BorderRadius.horizontal(right: Radius.circular(28)),
      colors: const [Color(0xFF07172D), Color(0xFF0D2D4F), Color(0xFF10476B)],
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hub_outlined,
                      color: Color(0xFF42D9E8),
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MI UPC',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'MENÚ PERSONAL',
                            style: TextStyle(
                              color: Color(0xFF93B2C9),
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar menú',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  key: const ValueKey('drawer-profile-scroll'),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  children: [_perfilLateral()],
                ),
              ),
              ConstrainedBox(
                key: const ValueKey('drawer-bottom-actions'),
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * 0.44,
                ),
                child: SingleChildScrollView(
                  key: const ValueKey('drawer-action-scroll'),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(4, 8, 4, 10),
                        child: Text(
                          'ACCESOS',
                          style: TextStyle(
                            color: Color(0xFF93B2C9),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      _item(
                        context,
                        Icons.home_rounded,
                        'Inicio',
                        'Menú principal',
                        () {},
                        selected: true,
                      ),
                      const SizedBox(height: 8),
                      _item(
                        context,
                        Icons.manage_accounts_outlined,
                        'Registrar / Editar datos',
                        'Mi información personal',
                        () async {
                          await Get.toNamed(AppRoutes.REGISTROUSUARIO);
                          await menuController.cargarDatosUsuario();
                          await menuController.cargarFotoPerfil();
                        },
                      ),
                      const SizedBox(height: 8),
                      _item(
                        context,
                        Icons.share_outlined,
                        'Compartir App',
                        'Enviar enlace de descarga',
                        () {
                          SharePlus.instance.share(
                            ShareParams(
                              text: 'https://play.google.com/store/apps/details?id=com.miupc',
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const InstitutionalSocialFooter(),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _perfilLateral() => Obx(() {
    final metodo = menuController.getMetodoAuthUI(
      menuController.metodoRegistro.value,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: InstitutionalAvatar(
            key: const ValueKey('drawer-profile-avatar'),
            bytes: menuController.fotoPerfilBytes.value,
            size: 124,
            destacado: true,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          menuController.userPref.value.isEmpty
              ? 'Usuario'
              : menuController.userPref.value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              metodo['icono'] as IconData,
              color: const Color(0xFF42D9E8),
              size: 16,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                menuController.documentoUsuario.value.isEmpty
                    ? 'Perfil sin registro'
                    : metodo['titulo'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFA9C5DA),
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF42D9E8).withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _datoPerfil(
                Icons.email_outlined,
                'CORREO',
                menuController.correoUsuario.value.isEmpty
                    ? 'Sin correo registrado'
                    : menuController.correoUsuario.value,
              ),
              _separadorPerfil(),
              _datoPerfil(
                Icons.phone_iphone_rounded,
                'TELÉFONO',
                menuController.telefonoUsuario.value.isEmpty
                    ? 'Sin teléfono registrado'
                    : menuController.telefonoUsuario.value,
              ),
              if (menuController.documentoUsuario.value.isNotEmpty) ...[
                _separadorPerfil(),
                _datoPerfil(
                  Icons.badge_outlined,
                  'CÉDULA',
                  menuController.documentoUsuario.value,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  });

  Widget _separadorPerfil() => Divider(
    height: 22,
    thickness: 0.6,
    color: Colors.white.withValues(alpha: 0.10),
  );

  Widget _datoPerfil(IconData icon, String label, String texto) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Icon(icon, color: const Color(0xFF42D9E8), size: 18),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF93B2C9),
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              texto,
              style: const TextStyle(
                color: Color(0xFFE1EBF4),
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool selected = false,
  }) => Material(
    color: Colors.transparent,
    child: Ink(
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF42D9E8).withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? const Color(0xFF42D9E8).withValues(alpha: 0.40)
              : Colors.white.withValues(alpha: 0.09),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: selected ? 0.10 : 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: selected ? const Color(0xFF42D9E8) : Colors.white70,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF93B2C9),
                        fontSize: 10.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: selected ? const Color(0xFF42D9E8) : Colors.white38,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
