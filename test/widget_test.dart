import 'package:flutter_test/flutter_test.dart';
import 'package:garuda_lexicon/app.dart';
import 'package:garuda_lexicon/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Garuda Lexicon app boots and displays editorial masthead and navigation',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.initialize();

    await tester.pumpWidget(GarudaLexiconApp(
      storageService: storageService,
    ));
    await tester.pumpAndSettle();

    // Verify Brand title & masthead
    expect(find.text('GARUDA LEXICON'), findsOneWidget);
    expect(find.text('The Dictionary & AI Language Companion'), findsOneWidget);

    // Verify Navigation Bar items
    expect(find.text('Lexicon'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Ask Garuda'), findsOneWidget);

    // Verify Word of the Day card is present
    expect(find.text('WORD OF THE DAY'), findsOneWidget);

    // Verify Search trigger field
    expect(find.text('Search English, Sanskrit roots, or Hindi...'), findsOneWidget);
  });
}
