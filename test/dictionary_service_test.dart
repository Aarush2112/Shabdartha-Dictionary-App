import 'package:flutter_test/flutter_test.dart';
import 'package:garuda_lexicon/data/curated_words.dart';
import 'package:garuda_lexicon/services/dictionary_service.dart';

void main() {
  group('DictionaryService Tests', () {
    late DictionaryService service;

    setUp(() {
      service = DictionaryService();
    });

    test('Word of the Day is deterministic and never returns null or empty', () {
      final wotd1 = service.getWordOfTheDay();
      final wotd2 = service.getWordOfTheDay();

      // Same calendar day must produce the exact same word
      expect(wotd1.word, wotd2.word);
      expect(wotd1.word.isNotEmpty, isTrue);
      expect(wotd1.primaryDefinition.isNotEmpty, isTrue);
    });

    test('Curated word lookup retrieves rich verified entries immediately without network delay', () async {
      final avatar = await service.lookupWord('avatar');
      expect(avatar.word, 'avatar');
      expect(avatar.isCurated, isTrue);
      expect(avatar.indianConnections.isNotEmpty, isTrue);
      expect(avatar.indianConnections.first.nativeScript, 'अवतार');
    });

    test('Case-insensitivity and whitespace stripping are handled gracefully', () async {
      final wordUpper = await service.lookupWord('  JUGGERNAUT  ');
      expect(wordUpper.word, 'juggernaut');

      final wordLower = await service.lookupWord('guru');
      expect(wordLower.word, 'guru');
    });

    test('Curated suggestions return relevant matches', () async {
      final matches = searchCuratedWords('ju');
      final words = matches.map((e) => e.word).toList();
      expect(words, contains('juggernaut'));
      expect(words, contains('jungle'));
    });
  });
}
