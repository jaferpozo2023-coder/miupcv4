import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'alertas_ciudadanas_controller.dart';

const _hotelNavy = Color(0xFF061A2B);
const _hotelBlue = Color(0xFF0E3A68);
const _hotelCyan = Color(0xFF42D9E8);
const _hotelInk = Color(0xFF203746);
const _hotelMuted = Color(0xFF64778B);
const _hotelLine = Color(0xFFDCE6EF);
const _hotelGreen = Color(0xFF147D72);
const _hotelRed = Color(0xFFB42318);

class PersonalHotelDialog extends StatefulWidget {
  final AlertasCiudadanasController controller;

  const PersonalHotelDialog({super.key, required this.controller});

  @override
  State<PersonalHotelDialog> createState() => _PersonalHotelDialogState();
}

class _PersonalHotelDialogState extends State<PersonalHotelDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nacionalidadKey = GlobalKey<FormFieldState<String>>();
  final _documento = TextEditingController();
  final _nombres = TextEditingController();
  String? _nacionalidad;

  static const _nacionalidades = <({String bandera, String nombre})>[
    (bandera: '🇦🇫', nombre: 'AFGANA'),
    (bandera: '🇩🇪', nombre: 'ALEMANA'),
    (bandera: '🇦🇩', nombre: 'ANDORRANA'),
    (bandera: '🇦🇴', nombre: 'ANGOLEÑA'),
    (bandera: '🇦🇬', nombre: 'ANTIGUANA'),
    (bandera: '🇸🇦', nombre: 'SAUDÍ'),
    (bandera: '🇩🇿', nombre: 'ARGELINA'),
    (bandera: '🇦🇷', nombre: 'ARGENTINA'),
    (bandera: '🇦🇲', nombre: 'ARMENIA'),
    (bandera: '🇦🇺', nombre: 'AUSTRALIANA'),
    (bandera: '🇦🇹', nombre: 'AUSTRÍACA'),
    (bandera: '🇦🇿', nombre: 'AZERBAIYANA'),
    (bandera: '🇧🇸', nombre: 'BAHAMEÑA'),
    (bandera: '🇧🇩', nombre: 'BANGLADESÍ'),
    (bandera: '🇧🇧', nombre: 'BARBADENSE'),
    (bandera: '🇧🇪', nombre: 'BELGA'),
    (bandera: '🇧🇿', nombre: 'BELICEÑA'),
    (bandera: '🇧🇴', nombre: 'BOLIVIANA'),
    (bandera: '🇧🇦', nombre: 'BOSNIA'),
    (bandera: '🇧🇼', nombre: 'BOTSUANA'),
    (bandera: '🇧🇷', nombre: 'BRASILEÑA'),
    (bandera: '🇧🇬', nombre: 'BÚLGARA'),
    (bandera: '🇨🇲', nombre: 'CAMERUNESA'),
    (bandera: '🇨🇦', nombre: 'CANADIENSE'),
    (bandera: '🇶🇦', nombre: 'CATARÍ'),
    (bandera: '🇨🇱', nombre: 'CHILENA'),
    (bandera: '🇨🇳', nombre: 'CHINA'),
    (bandera: '🇨🇾', nombre: 'CHIPRIOTA'),
    (bandera: '🇨🇴', nombre: 'COLOMBIANA'),
    (bandera: '🇰🇷', nombre: 'SURCOREANA'),
    (bandera: '🇰🇵', nombre: 'NORCOREANA'),
    (bandera: '🇨🇷', nombre: 'COSTARRICENSE'),
    (bandera: '🇭🇷', nombre: 'CROATA'),
    (bandera: '🇨🇺', nombre: 'CUBANA'),
    (bandera: '🇩🇰', nombre: 'DANESA'),
    (bandera: '🇩🇴', nombre: 'DOMINICANA'),
    (bandera: '🇪🇨', nombre: 'ECUATORIANA'),
    (bandera: '🇪🇬', nombre: 'EGIPCIA'),
    (bandera: '🇸🇻', nombre: 'SALVADOREÑA'),
    (bandera: '🇸🇰', nombre: 'ESLOVACA'),
    (bandera: '🇸🇮', nombre: 'ESLOVENA'),
    (bandera: '🇪🇸', nombre: 'ESPAÑOLA'),
    (bandera: '🇺🇸', nombre: 'ESTADOUNIDENSE'),
    (bandera: '🇪🇪', nombre: 'ESTONIA'),
    (bandera: '🇵🇭', nombre: 'FILIPINA'),
    (bandera: '🇫🇮', nombre: 'FINLANDESA'),
    (bandera: '🇫🇷', nombre: 'FRANCESA'),
    (bandera: '🇬🇪', nombre: 'GEORGIANA'),
    (bandera: '🇬🇭', nombre: 'GHANESA'),
    (bandera: '🇬🇷', nombre: 'GRIEGA'),
    (bandera: '🇬🇹', nombre: 'GUATEMALTECA'),
    (bandera: '🇬🇾', nombre: 'GUYANESA'),
    (bandera: '🇭🇹', nombre: 'HAITIANA'),
    (bandera: '🇭🇳', nombre: 'HONDUREÑA'),
    (bandera: '🇭🇺', nombre: 'HÚNGARA'),
    (bandera: '🇮🇳', nombre: 'INDIA'),
    (bandera: '🇮🇩', nombre: 'INDONESIA'),
    (bandera: '🇮🇶', nombre: 'IRAQUÍ'),
    (bandera: '🇮🇷', nombre: 'IRANÍ'),
    (bandera: '🇮🇪', nombre: 'IRLANDESA'),
    (bandera: '🇮🇸', nombre: 'ISLANDESA'),
    (bandera: '🇮🇱', nombre: 'ISRAELÍ'),
    (bandera: '🇮🇹', nombre: 'ITALIANA'),
    (bandera: '🇯🇲', nombre: 'JAMAIQUINA'),
    (bandera: '🇯🇵', nombre: 'JAPONESA'),
    (bandera: '🇯🇴', nombre: 'JORDANA'),
    (bandera: '🇰🇪', nombre: 'KENIANA'),
    (bandera: '🇱🇻', nombre: 'LETONA'),
    (bandera: '🇱🇧', nombre: 'LIBANESA'),
    (bandera: '🇱🇹', nombre: 'LITUANA'),
    (bandera: '🇱🇺', nombre: 'LUXEMBURGUESA'),
    (bandera: '🇲🇾', nombre: 'MALASIA'),
    (bandera: '🇲🇦', nombre: 'MARROQUÍ'),
    (bandera: '🇲🇽', nombre: 'MEXICANA'),
    (bandera: '🇳🇱', nombre: 'NEERLANDESA'),
    (bandera: '🇳🇮', nombre: 'NICARAGÜENSE'),
    (bandera: '🇳🇬', nombre: 'NIGERIANA'),
    (bandera: '🇳🇴', nombre: 'NORUEGA'),
    (bandera: '🇳🇿', nombre: 'NEOZELANDESA'),
    (bandera: '🇵🇰', nombre: 'PAKISTANÍ'),
    (bandera: '🇵🇦', nombre: 'PANAMEÑA'),
    (bandera: '🇵🇾', nombre: 'PARAGUAYA'),
    (bandera: '🇵🇪', nombre: 'PERUANA'),
    (bandera: '🇵🇱', nombre: 'POLACA'),
    (bandera: '🇵🇹', nombre: 'PORTUGUESA'),
    (bandera: '🇵🇷', nombre: 'PUERTORRIQUEÑA'),
    (bandera: '🇬🇧', nombre: 'BRITÁNICA'),
    (bandera: '🇨🇿', nombre: 'CHECA'),
    (bandera: '🇷🇴', nombre: 'RUMANA'),
    (bandera: '🇷🇺', nombre: 'RUSA'),
    (bandera: '🇸🇬', nombre: 'SINGAPURENSE'),
    (bandera: '🇿🇦', nombre: 'SUDAFRICANA'),
    (bandera: '🇸🇪', nombre: 'SUECA'),
    (bandera: '🇨🇭', nombre: 'SUIZA'),
    (bandera: '🇹🇭', nombre: 'TAILANDESA'),
    (bandera: '🇹🇷', nombre: 'TURCA'),
    (bandera: '🇺🇦', nombre: 'UCRANIANA'),
    (bandera: '🇺🇾', nombre: 'URUGUAYA'),
    (bandera: '🇻🇪', nombre: 'VENEZOLANA'),
    (bandera: '🇻🇳', nombre: 'VIETNAMITA'),
    (bandera: '🌐', nombre: 'OTRA'),
  ];

  @override
  void dispose() {
    _documento.dispose();
    _nombres.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final registrado = await widget.controller.registrarPersonalHotel(
      documento: _documento.text.trim(),
      nombres: _nombres.text.trim(),
      nacionalidad: _nacionalidad!,
    );
    if (!mounted || !registrado) return;
    _documento.clear();
    _nombres.clear();
    _nacionalidadKey.currentState?.reset();
    setState(() => _nacionalidad = null);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _hotelGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Personal registrado correctamente.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
  }


  Future<String?> _seleccionarNacionalidad() async {
    if (!mounted) return null;

    return showSearch<String?>(
      context: context,
      delegate: _NacionalidadSearchDelegate(
        items: _nacionalidades,
        seleccionada: _nacionalidad,
      ),
    );
  }

  String _bandera(String nacionalidad) {
    for (final item in _nacionalidades) {
      if (item.nombre == nacionalidad) return item.bandera;
    }
    return '🌐';
  }

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 640,
            maxHeight: MediaQuery.sizeOf(context).height * .90,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFBFD7E3)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x4A061A2B),
                  blurRadius: 34,
                  offset: Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _header(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _locationInfo(),
                        const SizedBox(height: 12),
                        _formulario(),
                        const SizedBox(height: 16),
                        _listaRegistrados(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 15, 10, 15),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_hotelNavy, _hotelBlue, Color(0xFF12617B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -18,
              top: -30,
              child: Icon(
                Icons.apartment_rounded,
                size: 120,
                color: Colors.white.withValues(alpha: .035),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _hotelCyan.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _hotelCyan.withValues(alpha: .45),
                    ),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    color: _hotelCyan,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MI UPC / REGISTRO HOTELERO',
                        style: TextStyle(
                          color: _hotelCyan,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.05,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Personal del hotel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Registro georreferenciado de personas',
                        style: TextStyle(
                          color: Color(0xFFBDDCE8),
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Obx(() {
                  final total =
                      widget.controller.personalHotelRegistrado.length;
                  return Container(
                    margin: const EdgeInsets.only(right: 2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: .14),
                      ),
                    ),
                    child: Text(
                      '$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                }),
                Obx(() {
                  final busy =
                      widget.controller.registrandoPersonalHotel.value;
                  return IconButton(
                    tooltip: 'Cerrar',
                    onPressed: busy ? null : () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: busy ? Colors.white38 : Colors.white,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      );

  Widget _locationInfo() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF8FA),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFBFE6EB)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.my_location_rounded,
              color: _hotelBlue,
              size: 20,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Al registrar, MI UPC validará la ubicación actual del dispositivo y asociará las coordenadas al registro.',
                style: TextStyle(
                  color: _hotelInk,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.verified_user_outlined,
              color: _hotelGreen,
              size: 18,
            ),
          ],
        ),
      );

  Widget _formulario() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _hotelLine),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D102E4E),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    color: _hotelBlue,
                    size: 21,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'NUEVO REGISTRO',
                      style: TextStyle(
                        color: _hotelInk,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .65,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              LayoutBuilder(
                builder: (context, constraints) {
                  final horizontal = constraints.maxWidth >= 500;
                  final documento = TextFormField(
                    controller: _documento,
                    maxLength: 40,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration(
                      label: 'Documento / pasaporte',
                      hint: 'Ingrese el identificador',
                      icon: Icons.credit_card_outlined,
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Ingrese el número de documento.'
                        : null,
                  );
                  final nacionalidad = _campoNacionalidad();
                  if (!horizontal) {
                    return Column(
                      children: [
                        documento,
                        const SizedBox(height: 11),
                        nacionalidad,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: documento),
                      const SizedBox(width: 11),
                      Expanded(child: nacionalidad),
                    ],
                  );
                },
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: _nombres,
                maxLength: 180,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _registrar(),
                decoration: _decoration(
                  label: 'Nombres y apellidos',
                  hint: 'Ingrese los nombres completos',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Ingrese los nombres y apellidos.'
                    : null,
              ),
              const SizedBox(height: 13),
              Obx(() {
                final busy =
                    widget.controller.registrandoPersonalHotel.value;
                return SizedBox(
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: busy
                            ? const [Color(0xFF8395A4), Color(0xFF6B7F8E)]
                            : const [_hotelBlue, Color(0xFF12617B)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: busy
                          ? const []
                          : const [
                              BoxShadow(
                                color: Color(0x2B0E3A68),
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ],
                    ),
                    child: FilledButton.icon(
                      onPressed: busy ? null : _registrar,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person_add_alt_1_rounded),
                      label: Text(
                        busy ? 'REGISTRANDO…' : 'REGISTRAR PERSONAL',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .65,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                final error = widget.controller.errorPersonalHotel.value;
                if (error.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.only(top: 11),
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFC9C5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: _hotelRed,
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                            color: _hotelRed,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );

  Widget _campoNacionalidad() => FormField<String>(
        key: _nacionalidadKey,
        initialValue: _nacionalidad,
        validator: (value) =>
            value == null || value.isEmpty ? 'Seleccione una nacionalidad.' : null,
        builder: (field) => InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final seleccion = await _seleccionarNacionalidad();
            if (!mounted || seleccion == null) return;
            setState(() => _nacionalidad = seleccion);
            field.didChange(seleccion);
          },
          child: InputDecorator(
            isEmpty: _nacionalidad == null,
            decoration: _decoration(
              label: 'Nacionalidad',
              hint: 'Seleccione',
              icon: Icons.public_rounded,
            ).copyWith(errorText: field.errorText),
            child: Row(
              children: [
                if (_nacionalidad != null) ...[
                  Text(
                    _bandera(_nacionalidad!),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    _nacionalidad ?? 'Seleccione',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _nacionalidad == null
                          ? _hotelMuted
                          : _hotelInk,
                      fontSize: 12,
                      fontWeight: _nacionalidad == null
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _hotelBlue,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _listaRegistrados() => Obx(() {
        final items = widget.controller.personalHotelRegistrado;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _hotelLine),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.groups_2_outlined,
                      color: _hotelBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REGISTRADOS EN ESTA SESIÓN',
                          style: TextStyle(
                            color: _hotelInk,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .55,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Últimos registros realizados desde este dispositivo',
                          style: TextStyle(
                            color: _hotelMuted,
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _hotelBlue.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${items.length}',
                      style: const TextStyle(
                        color: _hotelBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F9FC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _hotelLine),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.person_search_outlined,
                        color: _hotelMuted,
                        size: 30,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Aún no se registró personal en esta sesión.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _hotelMuted,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(
                  items.length,
                  (index) {
                    final item = items[index];
                    return Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(
                        bottom: index == items.length - 1 ? 0 : 8,
                      ),
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        border: Border.all(color: _hotelLine),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 39,
                            height: 39,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [_hotelNavy, _hotelBlue],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _bandera(item.nacionalidad),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.nombres,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: _hotelInk,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _miniDato(
                                      Icons.badge_outlined,
                                      item.documento,
                                    ),
                                    _miniDato(
                                      Icons.public_rounded,
                                      item.nacionalidad,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: _hotelGreen,
                            size: 18,
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      });

  Widget _miniDato(IconData icon, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _hotelLine),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: _hotelBlue),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: _hotelMuted,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: _hotelBlue, size: 20),
        counterText: '',
        filled: true,
        fillColor: const Color(0xFFF9FBFD),
        labelStyle: const TextStyle(
          color: _hotelBlue,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF94A3AF),
          fontSize: 11,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _hotelLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _hotelLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _hotelBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _hotelRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: _hotelRed,
            width: 1.5,
          ),
        ),
      );
}

class _NacionalidadSearchDelegate extends SearchDelegate<String?> {
  final List<({String bandera, String nombre})> items;
  final String? seleccionada;

  _NacionalidadSearchDelegate({
    required this.items,
    required this.seleccionada,
  }) : super(
          searchFieldLabel: 'Buscar nacionalidad',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
        );

  @override
  ThemeData appBarTheme(BuildContext context) {
    final base = Theme.of(context);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F9FC),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: _hotelNavy,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Color(0xFFB7DCEB),
          fontSize: 13,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        titleLarge: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    if (query.isEmpty) return null;

    return [
      IconButton(
        tooltip: 'Limpiar búsqueda',
        onPressed: () => query = '',
        icon: const Icon(Icons.close_rounded),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        tooltip: 'Volver',
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back_rounded),
      );

  @override
  Widget buildResults(BuildContext context) => _contenido(context);

  @override
  Widget buildSuggestions(BuildContext context) => _contenido(context);

  Widget _contenido(BuildContext context) {
    final filtro = query.trim().toUpperCase();

    final visibles = filtro.isEmpty
        ? items
        : items
            .where(
              (item) =>
                  item.nombre.contains(filtro) ||
                  item.bandera.contains(query.trim()),
            )
            .toList();

    if (visibles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 46,
                color: _hotelMuted,
              ),
              SizedBox(height: 12),
              Text(
                'No se encontraron coincidencias',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hotelInk,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Pruebe con otro nombre de nacionalidad.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _hotelMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: visibles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 7),
      itemBuilder: (context, index) {
        final item = visibles[index];
        final seleccionado = item.nombre == seleccionada;

        return Material(
          color: seleccionado
              ? const Color(0xFFE9F7FA)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => close(context, item.nombre),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: seleccionado
                      ? const Color(0xFF8EDBE2)
                      : _hotelLine,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F7FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.bandera,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _hotelInk,
                        fontSize: 12.5,
                        fontWeight: seleccionado
                            ? FontWeight.w900
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    seleccionado
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: seleccionado
                        ? _hotelGreen
                        : _hotelMuted,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

