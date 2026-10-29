import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pne/app/core/services/push_notification_service.dart';
import 'package:pne/app/presentation/widgets/push_alert_card.dart';
import 'package:pne/app/presentation/widgets/push_notification_host.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(320, 568)]) {
    testWidgets('la alerta es legible y permite cerrar a ${size.width}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final service = PushNotificationService();
      addTearDown(service.dispose);
      const previews = bool.fromEnvironment('CAPTURE_PREVIEWS');
      if (previews) {
        debugDisableShadows = false;
        addTearDown(() => debugDisableShadows = true);
        await tester.runAsync(() async {
          final font = FontLoader('PushPreviewArial');
          for (final filename in ['Arial.ttf', 'Arial Bold.ttf']) {
            font.addFont(
              Future.value(
                ByteData.sublistView(
                  await File('/System/Library/Fonts/Supplemental/$filename')
                      .readAsBytes(),
                ),
              ),
            );
          }
          await font.load();
          final icons = FontLoader('MaterialIcons')
            ..addFont(
              Future.value(
                ByteData.sublistView(
                  await File(
                    '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/MaterialIcons-Regular.otf',
                  ).readAsBytes(),
                ),
              ),
            );
          await icons.load();
        });
      }
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: previews ? 'PushPreviewArial' : null),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 24),
              textScaler: TextScaler.linear(size.width == 320 ? 1.6 : 1),
            ),
            child: RepaintBoundary(
              key: const ValueKey('push-preview'),
              child: PushNotificationHost(service: service, child: child!),
            ),
          ),
          home: const Scaffold(
            body: Center(child: Text('Formulario de la app')),
          ),
        ),
      );
      await service.receiveForeground(
        const RemoteMessage(
          messageId: 'widget-alert',
          notification: RemoteNotification(
            title: 'Nueva alerta ciudadana en su sector',
            body: 'Se ha reportado un evento cerca de su UPC. Revise el detalle de la alerta para conocer la ubicación y atender la solicitud.',
          ),
          data: {'idDgoAlertasMovilCiu': '51'},
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PushAlertCard), findsOneWidget);
      expect(find.text('ALERTA CIUDADANA'), findsOneWidget);
      expect(find.text('Ver alerta').hitTestable(), findsOneWidget);
      expect(
        tester.getRect(find.byType(PushAlertCard)).top,
        greaterThanOrEqualTo(24),
      );
      expect(tester.takeException(), isNull);
      if (previews && size.width == 390) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('push-preview')),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await Directory('build/previews').create(recursive: true);
          await File('build/previews/notificacion-push.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.tap(find.byTooltip('Cerrar notificación'));
      await tester.pumpAndSettle();
      expect(find.byType(PushAlertCard), findsNothing);
      expect(find.text('Formulario de la app'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      if (previews) debugDisableShadows = true;
    });
  }

  testWidgets('Ver mensaje abre el contenido completo y retira la tarjeta', (
    tester,
  ) async {
    final service = PushNotificationService()..markNavigationReady();
    addTearDown(service.dispose);
    addTearDown(Get.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        builder: (context, child) =>
            PushNotificationHost(service: service, child: child!),
        home: const Scaffold(body: Text('Pantalla actual')),
      ),
    );
    await service.receiveForeground(
      const RemoteMessage(
        messageId: 'general-message',
        notification: RemoteNotification(
          title: 'Seguimiento',
          body: 'Su solicitud ha sido actualizada.',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver mensaje'));
    await tester.pumpAndSettle();
    expect(find.byType(PushAlertCard), findsNothing);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Su solicitud ha sido actualizada.'), findsOneWidget);
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Pantalla actual'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
