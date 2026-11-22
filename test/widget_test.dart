import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garuda_lexicon/app.dart';
import 'package:garuda_lexicon/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Garuda Lexicon app boots and displays aesthetic editorial masthead and floating dock',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.initialize();

    await tester.pumpWidget(GarudaLexiconApp(
      storageService: storageService,
    ));
    await tester.pumpAndSettle();

    // Verify Brand title & masthead
    expect(find.text('GARUDA PRAKASHAN × RISHIHOOD'), findsOneWidget);
    expect(find.text('Garuda Lexicon • Edition I'), findsOneWidget);
    expect(find.text('Curating the World\nof Words...'), findsOneWidget);

    // Verify Circular Category Nodes
    expect(find.text('Indic Roots'), findsOneWidget);
    expect(find.text('PIE Cognates'), findsOneWidget);
    expect(find.text('Emotions'), findsOneWidget);

    // Verify Masterpiece of the Day card is present
    expect(find.text('MASTERPIECE OF THE DAY'), findsOneWidget);

    // Verify Capsule Search trigger field
    expect(find.text('Search word, root, or phrase...'), findsOneWidget);

    // Verify Curated Folios section
    expect(find.text('CURATED FOLIOS'), findsOneWidget);

    // Verify Floating Capsule Dock Icons
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);
    expect(find.byIcon(Icons.explore_outlined), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsNWidgets(2));
    expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
  });
}
