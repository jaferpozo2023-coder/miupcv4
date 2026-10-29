import 'package:flutter/material.dart';

import '../../core/services/push_alert.dart';

/// Aviso institucional que permite seguir trabajando y abrir la alerta a demanda.
class PushAlertCard extends StatelessWidget {
  const PushAlertCard({
    super.key,
    required this.alert,
    required this.onOpen,
    required this.onDismiss,
    this.waitingCount = 0,
  });

  final PushAlert alert;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;
  final int waitingCount;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF0B2E59);
    final accent = alert.isUrgent
        ? const Color(0xFFBD303D)
        : alert.isFollowUp
        ? const Color(0xFF95610B)
        : const Color(0xFF195BA6);
    final label = alert.isUrgent
        ? 'ALERTA PRIORITARIA'
        : alert.isFollowUp
        ? 'SEGUIMIENTO'
        : alert.alertId != null
        ? 'ALERTA CIUDADANA'
        : 'NUEVA NOTIFICACIÓN';

    return Semantics(
      container: true,
      liveRegion: true,
      child: Material(
        color: Colors.white,
        elevation: 14,
        shadowColor: navy.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: accent, width: 4)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        alert.isFollowUp
                            ? Icons.notifications_active_outlined
                            : Icons.shield_outlined,
                        color: accent,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MI UPC',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: navy,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar notificación',
                      onPressed: onDismiss,
                      color: const Color(0xFF6C7B8B),
                      icon: const Icon(Icons.close_rounded, size: 21),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            alert.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                              color: navy,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            alert.body,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Color(0xFF465668),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE7EDF3)),
                const SizedBox(height: 8),
                if (waitingCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '$waitingCount ${waitingCount == 1 ? 'aviso pendiente' : 'avisos pendientes'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C7B8B),
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: navy),
                        onPressed: onDismiss,
                        child: const Text('Cerrar'),
                      ),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: onOpen,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 17),
                        iconAlignment: IconAlignment.end,
                        label: Text(
                          alert.alertId != null ? 'Ver alerta' : 'Ver mensaje',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
