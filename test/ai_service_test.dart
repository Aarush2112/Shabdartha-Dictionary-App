import 'package:flutter_test/flutter_test.dart';
import 'package:garuda_lexicon/services/ai_service.dart';

void main() {
  group('AI Companion (Ask Garuda) Tests', () {
    late GarudaDemoAiService demoService;

    setUp(() {
      demoService = GarudaDemoAiService();
    });

    test('Demo service identifies as demo mode transparently', () {
      expect(demoService.isDemoMode, isTrue);
      expect(demoService.providerName, contains('Demo Mode'));
    });

    test('Provides scholarly comparative analysis for near-synonyms', () async {
      final response = await demoService.sendMessage(
        prompt: 'What is the difference between melancholy, sadness, and grief?',
        conversationHistory: [],
      );

      expect(response.isUser, isFalse);
      expect(response.isDemo, isTrue);
      expect(response.text, contains('Sadness'));
      expect(response.text, contains('Grief'));
      expect(response.text, contains('Melancholy'));
      expect(response.quickFollowUps.isNotEmpty, isTrue);
    });

    test('Explores authentic Indian linguistic history without hallucination', () async {
      final response = await demoService.sendMessage(
        prompt: 'Tell me about the Indian origin of juggernaut',
        conversationHistory: [],
      );

      expect(response.isUser, isFalse);
      expect(response.text, contains('Jagannātha'));
      expect(response.text, contains('Puri'));
      expect(response.text, contains('Ratha Yatra'));
    });

    test('Provides actionable guidance for sentence improvement', () async {
      final response = await demoService.sendMessage(
        prompt: 'How can I improve and polish this sentence?',
        conversationHistory: [],
      );

      expect(response.isUser, isFalse);
      expect(response.text, contains('Sentence Refinement'));
      expect(response.text, contains('Tone'));
    });
  });
}
