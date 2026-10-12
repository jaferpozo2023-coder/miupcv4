import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:pne/app/presentation/widgets/custom_widgets.dart';

void main() {
  testWidgets('ComboBusqueda provides Material for its ink controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      GetMaterialApp(
        localizationsDelegates: const [
          mui.GlobalMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Center(
            child: ComboBusqueda<String>(
              title: 'Tipo de evento',
              datos: const ['EXTORSIÓN'],
              displayField: (item) => item,
              searchHint: 'Buscar evento',
              textSeleccioneUndato: 'Seleccione un evento',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(DropdownSearch<String>));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('EXTORSIÓN'), findsOneWidget);
  });
}
