part of '../pages.dart';

class AcuerdoPage extends GetView<AcuerdoController> {
  const AcuerdoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: Image.asset(AppImages.imgarea, fit: BoxFit.cover)),
        Positioned.fill(child: Container(color: const Color(0x2204192C))),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.97),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0x3324B6D9)),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _cabeceraAcuerdo(),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _parrafo('Esta aplicación ha sido desarrollada para brindar información relacionada con la localización de UPC, generar alertas y otros servicios importantes para la seguridad ciudadana, con la finalidad de mejorar el servicio a la ciudadanía. Para su uso, el usuario debe aceptar los siguientes términos y condiciones:'),
                                      _parrafo('La información solicitada e ingresada en la aplicación es de carácter confidencial y reservado, y será utilizada con el propósito de mejorar el servicio a la ciudadanía a través de una herramienta con información real y segura.'),
                                      _parrafo('La Policía Nacional del Ecuador no se responsabiliza de los costos relacionados con la conectividad de datos o acceso a internet utilizados por la aplicación para su funcionamiento.'),
                                      _parrafo('La funcionalidad óptima de la aplicación dependerá de las características técnicas mínimas del teléfono celular, disponibilidad de señal de internet, empresa proveedora y ancho de banda al momento de utilizar la aplicación.'),
                                      _parrafo('Esta aplicación ha sido desarrollada por la Policía Nacional del Ecuador. Queda prohibida su reproducción o modificación parcial o total.'),
                                      _parrafo('La violación de cualquiera de estos términos y condiciones, así como el mal uso del aplicativo, podrá ocasionar el bloqueo de la aplicación y las acciones correspondientes de acuerdo con la normativa legal vigente, siendo responsable el usuario que utilice la aplicación.'),
                                      Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F7FA),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFFBEDCE5)),
                                        ),
                                        child: const Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.gavel_rounded, size: 20, color: Color(0xFF0C5372)),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'El artículo 396, numeral 3 del COIP dispone la sanción a la persona que, de manera indebida, utilice el número único de atención de emergencias para dar un aviso falso de emergencia que implique desplazamiento, movilización o activación innecesaria de recursos de las instituciones de emergencia.',
                                                textAlign: TextAlign.justify,
                                                style: TextStyle(fontSize: 12.5, height: 1.45, fontWeight: FontWeight.w700, color: Color(0xFF153245)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7FAFC),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFFD7E3EA)),
                                        ),
                                        child: Obx(
                                          () => CheckboxListTile(
                                            value: controller.chk.value,
                                            onChanged: controller.guardando.value ? null : (value) => controller.chk.value = value ?? false,
                                            controlAffinity: ListTileControlAffinity.leading,
                                            dense: true,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            activeColor: const Color(0xFF0C6580),
                                            title: const Text(
                                              'Acepto los términos y condiciones',
                                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF123246)),
                                            ),
                                            subtitle: const Text(
                                              'Declaro haber leído y comprendido el acuerdo de confidencialidad.',
                                              style: TextStyle(fontSize: 10.5, height: 1.25, color: Color(0xFF5C7180)),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      _btnContinuar(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cabeceraAcuerdo() => Container(
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 15),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF061D33), Color(0xFF0A4968), Color(0xFF0B7186)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: const Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0x22FFFFFF), borderRadius: BorderRadius.all(Radius.circular(13))),
            child: Icon(Icons.verified_user_outlined, color: Colors.white, size: 25),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACUERDO DE CONFIDENCIALIDAD', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: .35)),
              SizedBox(height: 3),
              Text('MI UPC · USO RESPONSABLE DE LA INFORMACIÓN', style: TextStyle(color: Color(0xFF9EDBE6), fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: .55)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _parrafo(String texto) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(texto, textAlign: TextAlign.justify, style: const TextStyle(fontSize: 12.5, height: 1.48, color: Color(0xFF263D4C))),
  );

  Widget _btnContinuar() => Obx(
    () => SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: controller.chk.value && !controller.guardando.value ? controller.aceptarAcuerdo : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A5775),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFD6E0E5),
          disabledForegroundColor: const Color(0xFF82919A),
          elevation: controller.chk.value ? 5 : 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        icon: controller.guardando.value
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white))
            : const Icon(Icons.arrow_forward_rounded),
        label: Text(controller.guardando.value ? 'GUARDANDO...' : 'CONTINUAR', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: .8)),
      ),
    ),
  );
}
