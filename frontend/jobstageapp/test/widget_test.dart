// Tests pour l'application JobStage
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:jobstageapp/main.dart';
import 'package:jobstageapp/theme/theme_provider.dart';

void main() {
  group('JobStage App Tests', () {
    testWidgets('App démarre avec SplashScreen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const JobstageApp());

      // Vérifier que l'app se lance sans erreur
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('ThemeProvider est initialisé', (WidgetTester tester) async {
      await tester.pumpWidget(const JobstageApp());

      // Vérifier que le ChangeNotifierProvider est présent
      expect(
        find.byType(ChangeNotifierProvider<ThemeProvider>),
        findsOneWidget,
      );
    });

    testWidgets('MaterialApp a le bon titre', (WidgetTester tester) async {
      await tester.pumpWidget(const JobstageApp());

      // Vérifier le titre de l'application
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, 'JOBSTAGE - Plateforme de Recrutement');
    });
  });
}
