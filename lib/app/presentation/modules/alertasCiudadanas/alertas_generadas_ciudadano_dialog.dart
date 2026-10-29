import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/alertas_generadas_ciudadano_model.dart';
import 'alertas_ciudadanas_controller.dart';

class AlertasGeneradasCiudadanoDialog extends StatelessWidget {
  final AlertasCiudadanasController controller;

  const AlertasGeneradasCiudadanoDialog({super.key, required this.controller});

  static const _navy = Color(0xFF07172D);
  static const _blue = Color(0xFF0E3A68);
  static const _ink = Color(0xFF12263D);
  static const _muted = Color(0xFF64778B);
  static const _green = Color(0xFF147D72);
  static const _amber = Color(0xFFB56512);

  @override
  Widget build(BuildContext context) => Dialog(
    key: const ValueKey('dialogo-alertas-generadas-ciudadano'),
    backgroundColor: const Color(0xFFF4F7FB),
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    clipBehavior: Clip.antiAlias,
    child: SizedBox(
      width: 600,
      height: MediaQuery.sizeOf(context).height * .82,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 10, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [_navy, _blue]),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: Color(0xFF42D9E8),
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mis alertas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Estado de sus alertas generadas',
                        style: TextStyle(
                          color: Color(0xFFB7DCEB),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back<void>(),
                  tooltip: 'Cerrar mis alertas',
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(child: Obx(_contenido)),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OverflowBar(
              alignment: MainAxisAlignment.spaceBetween,
              overflowAlignment: OverflowBarAlignment.end,
              spacing: 8,
              children: [
                Obx(
                  () => TextButton.icon(
                    onPressed: controller.cargandoAlertasGeneradas.value
                        ? null
                        : controller.cargarAlertasGeneradas,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Actualizar'),
                    style: TextButton.styleFrom(foregroundColor: _blue),
                  ),
                ),
                TextButton(
                  onPressed: () => Get.back<void>(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _contenido() {
    if (controller.cargandoAlertasGeneradas.value) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _blue),
            SizedBox(height: 14),
            Text('Consultando sus alertas…', style: TextStyle(color: _muted)),
          ],
        ),
      );
    }
    if (!controller.esCiudadano) {
      return _estadoVacio(
        Icons.lock_outline_rounded,
        'Acceso no disponible',
        'Actualice sus datos para consultar el acceso a sus alertas.',
      );
    }
    final error = controller.errorAlertasGeneradas.value;
    if (error.isNotEmpty) {
      return _estadoVacio(
        Icons.cloud_off_rounded,
        'No se pudieron cargar sus alertas',
        error,
        reintentar: true,
      );
    }
    final alertas = controller.alertasGeneradas;
    if (alertas.isEmpty) {
      return _estadoVacio(
        Icons.notifications_none_rounded,
        'Todavía no tiene alertas generadas',
        'Sus alertas aparecerán aquí después de enviarlas.',
      );
    }
    return ListView.builder(
      key: const ValueKey('lista-alertas-generadas-ciudadano'),
      padding: const EdgeInsets.all(16),
      itemCount: alertas.length + 1,
      itemBuilder: (context, index) =>
          index == 0 ? _resumen() : _alerta(alertas[index - 1]),
    );
  }

  Widget _estadoVacio(
    IconData icon,
    String titulo,
    String descripcion, {
    bool reintentar = false,
  }) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: _muted),
          const SizedBox(height: 14),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 12, height: 1.4),
          ),
          if (reintentar) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: controller.cargarAlertasGeneradas,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(backgroundColor: _blue),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _resumen() => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _contador('Total', controller.totalAlertasGeneradas, _blue),
            _contador(
              'Pendientes',
              controller.totalGeneradasPendientes,
              _amber,
            ),
            _contador(
              'En atención',
              controller.totalGeneradasEnAtencion,
              _blue,
            ),
            _contador('Atendidas', controller.totalGeneradasAtendidas, _green),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Toque una alerta para ver sus detalles y la atención registrada.',
          style: TextStyle(color: _muted, fontSize: 11, height: 1.4),
        ),
      ],
    ),
  );

  Widget _contador(String label, int cantidad, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: .2)),
    ),
    child: Text(
      '$label: $cantidad',
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );

  Widget _alerta(AlertaGeneradaCiudadano alerta) {
    final estado = alerta.estadoActual;
    final color = switch (estado) {
      'ATENDIDA' => _green,
      'EN_ATENCION' || 'EN ATENCION' || 'EN ATENCIÓN' => _blue,
      _ => _amber,
    };
    return Card(
      key: ValueKey('alerta-generada-${alerta.idDgoAlertasMovilCiu}'),
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDCE6EF)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Alerta N.º ${alerta.idDgoAlertasMovilCiu}',
              style: const TextStyle(
                color: _ink,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                estado.isEmpty ? 'GENERADA' : estado.replaceAll('_', ' '),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alerta.fechaAlerta.isEmpty
                    ? 'Fecha no informada'
                    : alerta.fechaAlerta,
                style: const TextStyle(color: _muted, fontSize: 11),
              ),
              const SizedBox(height: 5),
              Text(
                alerta.observacion.isEmpty
                    ? 'Sin observación'
                    : alerta.observacion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _ink, fontSize: 12, height: 1.35),
              ),
            ],
          ),
        ),
        children: [_detalle(alerta)],
      ),
    );
  }

  Widget _detalle(AlertaGeneradaCiudadano alerta) {
    final establecimiento = alerta.establecimiento;
    final ubicacion = alerta.ubicacionAlerta;
    final atencion = alerta.atencion;
    final ubicacionEstablecimiento = UbicacionAlertaGenerada(
      latitud: establecimiento?.latitud,
      longitud: establecimiento?.longitud,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 20),
        _dato('Observación', alerta.observacion),
        if (establecimiento != null) ...[
          _dato('Institución', establecimiento.institucion),
          _dato('Tipo de usuario', establecimiento.tipoUsuario),
          _dato('Dirección', establecimiento.direccion),
          _dato('Teléfono', establecimiento.telefono),
          _dato('Correo', establecimiento.mail),
        ],
        if (ubicacion?.esValida == true)
          _dato('Ubicación de la alerta', _coordenadas(ubicacion!)),
        if (ubicacionEstablecimiento.esValida)
          _dato(
            'Ubicación del establecimiento',
            _coordenadas(ubicacionEstablecimiento),
          ),
        const Divider(height: 20),
        const Text(
          'Atención policial',
          style: TextStyle(
            color: _blue,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _dato('Servidor policial', atencion?.servidorPolicial),
        _dato(
          'Fecha de atención',
          alerta.fechaAtencion ?? atencion?.fechaAtencion,
        ),
        _dato(
          'Verificación',
          alerta.estadoVerificacion ?? atencion?.estadoVerificacion,
        ),
        _dato('Procedimiento', alerta.procedimiento ?? atencion?.procedimiento),
      ],
    );
  }

  String _coordenadas(UbicacionAlertaGenerada ubicacion) =>
      '${ubicacion.latitud!.toStringAsFixed(6)}, ${ubicacion.longitud!.toStringAsFixed(6)}';

  Widget _dato(String label, String? value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value == null || value.trim().isEmpty ? 'No informado' : value,
          style: const TextStyle(color: _ink, fontSize: 12, height: 1.35),
        ),
      ],
    ),
  );
}
