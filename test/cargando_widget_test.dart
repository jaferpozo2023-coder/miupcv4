import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pne/app/presentation/widgets/custom_widgets.dart';

void main() {
  testWidgets('CargandoWidget reutiliza el loading del splash y desenfoca', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [SizedBox.expand(), CargandoWidget(mostrar: true)],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('CARGANDO'), findsOneWidget);
    expect(find.byType(Loading), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byKey(const ValueKey('mi-upc-loading-image')), findsNothing);
    expect(
      find.byKey(const ValueKey('institutional-loading-card')),
      findsNothing,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ModalBarrier && widget.color == Colors.transparent,
      ),
      findsOneWidget,
    );
  });

  testWidgets('CargandoWidget no ocupa la pantalla cuando está inactivo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [SizedBox.expand(), CargandoWidget(mostrar: false)],
          ),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ModalBarrier && widget.color == Colors.transparent,
      ),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('institutional-loading-icon')),
      findsNothing,
    );
  });

  testWidgets('CargandoWidget se adapta a una altura reducida', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              height: 154,
              child: Stack(
                children: [SizedBox.expand(), CargandoWidget(mostrar: true)],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('CARGANDO'), findsOneWidget);
    expect(find.byType(Loading), findsOneWidget);
  });

  testWidgets('CargandoWidget queda centrado dentro del area que lo contiene', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 800,
            child: Stack(
              children: [SizedBox.expand(), CargandoWidget(mostrar: true)],
            ),
          ),
        ),
      ),
    );

    final iconRect = tester.getRect(
      find.byKey(const ValueKey('institutional-loading-icon')),
    );
    final barrierRect = tester.getRect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ModalBarrier && widget.color == Colors.transparent,
      ),
    );
    expect(iconRect.center.dx, closeTo(barrierRect.center.dx, 1));
    expect(iconRect.center.dy, closeTo(barrierRect.center.dy, 1));
    expect(tester.takeException(), isNull);
  });
}
