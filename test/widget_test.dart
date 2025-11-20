import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Asegúrate de que la ruta de importación sea la correcta para tu proyecto
import 'package:trato_hecho_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // CAMBIO AQUÍ: Añadimos el parámetro que falta (startWithWelcome)
    // Le pasamos 'false' o 'true' para que la prueba pueda correr.
    await tester.pumpWidget(const MyApp(startWithWelcome: false));

    // ... el resto del código de la prueba ...
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}