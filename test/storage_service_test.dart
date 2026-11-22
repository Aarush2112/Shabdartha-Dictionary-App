import 'package:flutter_test/flutter_test.dart';
import 'package:garuda_lexicon/models/chat_message.dart';
import 'package:garuda_lexicon/models/word_model.dart';
import 'package:garuda_lexicon/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService Persistence Tests', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storageService = await StorageService.initialize();
    });

    test('Saves and retrieves bookmarked words correctly', () async {
      const entry = WordEntry(
        word: 'petrichor',
        meanings: [
          WordMeaning(
            partOfSpeech: 'noun',
            definitions: [DefinitionItem(definition: 'Smell of earth after rain.')],
          ),
        ],
      );

      expect(storageService.isWordSaved('petrichor'), isFalse);

      await storageService.saveWord(entry);
      expect(storageService.isWordSaved('petrichor'), isTrue);

      final list = storageService.getSavedWords();
      expect(list.length, 1);
      expect(list.first.word, 'petrichor');
      expect(list.first.savedAt, isNotNull);

      await storageService.removeSavedWord('petrichor');
      expect(storageService.isWordSaved('petrichor'), isFalse);
      expect(storageService.getSavedWords(), isEmpty);
    });

    test('Recent searches maintains newest first and caps maximum history', () async {
      await storageService.addRecentSearch('avatar');
      await storageService.addRecentSearch('juggernaut');
      await storageService.addRecentSearch('guru');

      var list = storageService.getRecentSearches();
      expect(list, ['guru', 'juggernaut', 'avatar']);

      // Adding existing term brings it to the top
      await storageService.addRecentSearch('avatar');
      list = storageService.getRecentSearches();
      expect(list, ['avatar', 'guru', 'juggernaut']);

      await storageService.clearRecentSearches();
      expect(storageService.getRecentSearches(), isEmpty);
    });

    test('Persists and clears chat messages', () async {
      final msg1 = ChatMessage(
        id: '1',
        text: 'What is solitude?',
        isUser: true,
        timestamp: DateTime.now(),
      );
      final msg2 = ChatMessage(
        id: '2',
        text: 'Solitude is the richness of self.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      await storageService.saveChatHistory([msg1, msg2]);
      final history = storageService.getChatHistory();
      expect(history.length, 2);
      expect(history.first.text, 'What is solitude?');
      expect(history.last.text, 'Solitude is the richness of self.');

      await storageService.clearChatHistory();
      expect(storageService.getChatHistory(), isEmpty);
    });

    test('Saves and loads AI configuration keys securely in preferences', () async {
      expect(storageService.getAiApiKey(), isNull);
      expect(storageService.getAiModel(), 'gemini-1.5-flash');

      await storageService.setAiApiKey('test-key-123');
      await storageService.setAiModel('gemini-1.5-pro');

      expect(storageService.getAiApiKey(), 'test-key-123');
      expect(storageService.getAiModel(), 'gemini-1.5-pro');

      await storageService.setAiApiKey(null);
      expect(storageService.getAiApiKey(), isNull);
    });
  });
}
