// Copyright 2024 Juan Suarez - Pragma. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// Tests básicos para la aplicación de ejemplo.
//
// Estos tests verifican que la aplicación de ejemplo se construye
// correctamente y que la navegación funciona.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:countdown_example/main.dart';

void main() {
  testWidgets('La aplicación de ejemplo se construye correctamente',
      (WidgetTester tester) async {
    // Construir la aplicación
    await tester.pumpWidget(const CountdownExampleApp());

    // Verificar que el título de la app bar está presente
    expect(find.text('Demo Básico'), findsOneWidget);

    // Verificar que la barra de navegación está presente
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('La navegación entre pestañas funciona',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CountdownExampleApp());

    // Inicialmente estamos en "Demo Básico"
    expect(find.text('Demo Básico'), findsWidgets);

    // Navegar a "Multi Countdown"
    await tester.tap(find.text('Multi Countdown'));
    await tester.pumpAndSettle();

    // Verificar que cambiamos de página
    expect(find.text('Demo Multi-Countdown'), findsOneWidget);
  });
}
