import 'package:flutter_test/flutter_test.dart';
import 'package:garuda_lexicon/models/word_model.dart';

void main() {
  group('WordModel & IndianLanguageConnection Tests', () {
    test('Serializes and deserializes WordEntry to and from JSON correctly', () {
      const entry = WordEntry(
        word: 'juggernaut',
        phonetic: '/ˈdʒʌɡ.ə.nɔːt/',
        meanings: [
          WordMeaning(
            partOfSpeech: 'noun',
            definitions: [
              DefinitionItem(
                definition: 'An overwhelming force.',
                example: 'The industrial juggernaut was unstoppable.',
                synonyms: ['colossus', 'powerhouse'],
                antonyms: ['weakling'],
              ),
            ],
          ),
        ],
        origin: 'From Odia/Sanskrit Jagannatha',
        etymology: 'Tied to the sacred chariot festival in Puri.',
        indianConnections: [
          IndianLanguageConnection(
            language: 'Sanskrit',
            nativeScript: 'जगन्नाथ',
            transliteration: 'jagannātha',
            meaning: 'Lord of the Universe',
            relationType: IndianRelationType.loanword,
            academicNote: 'Historical borrowing dating to 17th-century European travelers.',
            isVerified: true,
          ),
        ],
        source: 'Curated Garuda Lexicon',
        isCurated: true,
      );

      final json = entry.toJson();
      final parsed = WordEntry.fromJson(json);

      expect(parsed.word, 'juggernaut');
      expect(parsed.phonetic, '/ˈdʒʌɡ.ə.nɔːt/');
      expect(parsed.meanings.length, 1);
      expect(parsed.primaryPartOfSpeech, 'noun');
      expect(parsed.primaryDefinition, 'An overwhelming force.');
      expect(parsed.allSynonyms, contains('colossus'));
      expect(parsed.allAntonyms, contains('weakling'));
      expect(parsed.indianConnections.length, 1);
      expect(parsed.indianConnections.first.relationType, IndianRelationType.loanword);
      expect(parsed.indianConnections.first.nativeScript, 'जगन्नाथ');
      expect(parsed.isCurated, isTrue);
    });

    test('Parses standard Free Dictionary API JSON response correctly', () {
      final mockApiResponse = {
        'word': 'eloquence',
        'phonetic': '/ˈɛl.ə.kwəns/',
        'phonetics': [
          {'text': '/ˈɛl.ə.kwəns/', 'audio': 'https://api.dictionaryapi.dev/media/pronunciations/en/eloquence-us.mp3'}
        ],
        'meanings': [
          {
            'partOfSpeech': 'noun',
            'definitions': [
              {
                'definition': 'Fluent or persuasive speaking or writing.',
                'example': 'A speech of immense eloquence.',
                'synonyms': ['fluency', 'oratory'],
                'antonyms': ['inarticulacy'],
              }
            ],
          }
        ],
      };

      final parsed = WordEntry.fromFreeDictionaryJson(mockApiResponse);

      expect(parsed.word, 'eloquence');
      expect(parsed.phonetic, '/ˈɛl.ə.kwəns/');
      expect(parsed.audioUrl, contains('eloquence-us.mp3'));
      expect(parsed.primaryPartOfSpeech, 'noun');
      expect(parsed.primaryDefinition, 'Fluent or persuasive speaking or writing.');
      expect(parsed.allSynonyms, contains('oratory'));
      expect(parsed.allAntonyms, contains('inarticulacy'));
    });

    test('Distinguishes PIE Cognates from Direct Loanwords academically', () {
      expect(IndianRelationType.loanword.label, 'Direct Loanword');
      expect(IndianRelationType.cognate.label, 'PIE Cognate (Shared Ancestor)');
      expect(IndianRelationType.conceptualParallel.label, 'Conceptual Parallel');
    });
  });
}
