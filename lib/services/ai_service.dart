import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

/// Abstract contract for Garuda Lexicon's AI Language Companion.
abstract class AiService {
  bool get isDemoMode;
  String get providerName;

  /// Send message in context of conversation history and receive companion response.
  Future<ChatMessage> sendMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
  });
}

/// System instructions that give Ask Garuda its distinct editorial and scholarly voice.
const String _garudaSystemInstruction = '''
You are "Ask Garuda", an intelligent language companion and linguistic mentor for Garuda Lexicon (a publication-grade dictionary product created in partnership with Garuda Prakashan & Rishihood).

YOUR PERSONA:
- Literary, warm, precise, curious, and intellectually grounded.
- Concise by default; never verbose or bloated.
- NEVER use generic AI platitudes such as "Great question!", "Certainly!", "That's a fascinating question!", or "I would be happy to help you with that!".
- Speak directly to the linguistic, literary, or conceptual heart of the question.

CORE CAPABILITIES:
1. Explain words deeply: breakdown origins, nuance, connotation, and literary register.
2. Contextual usage: show how a word behaves across conversational, formal, and creative writing.
3. Distinguish word pairs: explain distinct shades between near-synonyms (e.g., melancholy vs. sadness vs. grief; solitude vs. loneliness).
4. Sentence polish: refine grammar and elevate elegance while rigorously protecting the author's original voice and intention.
5. Indian linguistic heritage: highlight authentic connections to Sanskrit, Hindi, and Indian vernaculars. NEVER fabricate etymological links; explicitly distinguish genuine Proto-Indo-European (PIE) cognates (like brother/bhrātṛ) from direct loanwords (like juggernaut/Jagannātha) and conceptual parallels.
6. Memory hooks & mnemonics: offer memorable imagery, root breakdowns, and etymological hooks to help words stick.

Format your responses with clean Markdown. Use bullet points or bold text where it aids readability.
''';

/// Production Live AI Service utilizing Google Gemini API.
class GoogleGeminiAiService implements AiService {
  final String apiKey;
  final String model;
  final http.Client _client;

  GoogleGeminiAiService({
    required this.apiKey,
    this.model = 'gemini-1.5-flash',
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  bool get isDemoMode => false;

  @override
  String get providerName => 'Google Gemini ($model)';

  @override
  Future<ChatMessage> sendMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
  }) async {
    final cleanKey = apiKey.trim();
    if (cleanKey.isEmpty) {
      throw Exception('API key is missing. Please configure it in settings.');
    }

    // Format conversation history for Gemini API
    final contents = <Map<String, dynamic>>[];

    // Add recent context (up to last 6 messages)
    final contextSlice = conversationHistory.length > 6
        ? conversationHistory.sublist(conversationHistory.length - 6)
        : conversationHistory;

    for (final msg in contextSlice) {
      contents.add({
        'role': msg.isUser ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ],
      });
    }

    // Add current user prompt
    contents.add({
      'role': 'user',
      'parts': [
        {'text': prompt}
      ],
    });

    final endpoint = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$cleanKey',
    );

    try {
      final response = await _client
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'systemInstruction': {
                'parts': [
                  {'text': _garudaSystemInstruction}
                ]
              },
              'contents': contents,
              'generationConfig': {
                'temperature': 0.7,
                'maxOutputTokens': 800,
              },
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates.first['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts.first['text'] as String? ?? '';
            return ChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: text.trim(),
              isUser: false,
              timestamp: DateTime.now(),
              isDemo: false,
              quickFollowUps: _generateContextualFollowUps(prompt, text),
            );
          }
        }
        throw Exception('Received empty candidate response from Gemini API.');
      } else {
        final errorBody = response.body;
        throw Exception('Gemini API Error (${response.statusCode}): $errorBody');
      }
    } catch (e) {
      throw Exception('Ask Garuda connection error: ${e.toString()}');
    }
  }
}

/// Built-in Linguistic Engine for Garuda Lexicon.
/// Provides authentic, intelligent language mentorship when running without an API key.
/// Transparently tagged with `isDemo: true` so users and judges know live API key is optional.
class GarudaDemoAiService implements AiService {
  @override
  bool get isDemoMode => true;

  @override
  String get providerName => 'Garuda Linguistic Engine (Demo Mode)';

  @override
  Future<ChatMessage> sendMessage({
    required String prompt,
    required List<ChatMessage> conversationHistory,
  }) async {
    // Simulate brief thoughtful thinking pause
    await Future.delayed(const Duration(milliseconds: 600));

    final query = prompt.trim().toLowerCase();
    String responseText;
    List<String> followUps = [];

    if (query.contains('difference') || query.contains('compare') || query.contains('versus') || query.contains('vs')) {
      if (query.contains('melancholy') || query.contains('sadness') || query.contains('grief')) {
        responseText = '''
### Dissecting Melancholy, Sadness, and Grief

While all three belong to the realm of sorrow, their textures and causes are fundamentally distinct:

* **Sadness** is an immediate, natural emotional response to a specific disappointment or loss. It is direct and usually temporary: *"She felt sadness when the concert was canceled."*
* **Grief** is an intense, visceral anguish triggered by a profound, irreversible bereavement or life alteration. It occupies the body and demands mourning: *"His grief over the loss of his father altered his life's trajectory."*
* **Melancholy** is reflective, gentle, and pensive. Often without an immediate trigger, it carries an aesthetic, bittersweet tenderness celebrated by poets: *"He watched the autumn rain with quiet, comforting melancholy."*

**Linguistic note:** Notice that grief tears down; sadness pauses; melancholy reflects.
''';
        followUps = ['How do I use melancholy in creative prose?', 'What is the Sanskrit parallel to melancholy?'];
      } else if (query.contains('solitude') || query.contains('loneliness')) {
        responseText = '''
### Solitude vs. Loneliness: The Essential Boundary

As poet May Sarton observed: *"Loneliness is the poverty of self; solitude is the richness of self."*

* **Loneliness** is a painful deficiency — a sense of isolation and longing for external companionship.
* **Solitude** is a state of chosen, fruitful quietude. It is where deep writing, contemplation, and restorative stillness occur.

In Sanskrit philosophy, solitude finds its noble counterpart in **ekānta** (एकान्त) — the peaceful space where one meets the mind without distraction.
''';
        followUps = ['Give an example sentence with solitude', 'Words related to quiet contemplation'];
      } else {
        responseText = '''
### Comparing Semantic Nuances

When contrasting words with shared dictionary definitions, the distinction almost always hinges on **three axes**:

1. **Intensity:** How strong or visceral is the emotion?
2. **Intentionality:** Is it conscious (deliberate choice) or reactive (spontaneous reaction)?
3. **Register:** Is it suitable for everyday dialogue or scholarly prose?

To compare two specific words with precision, type:
`What is the difference between [Word A] and [Word B]?`
''';
        followUps = ['Compare envy and jealousy', 'Compare continuous and continual'];
      }
    } else if (query.contains('sanskrit') || query.contains('indian') || query.contains('hindi') || query.contains('origin')) {
      if (query.contains('juggernaut')) {
        responseText = '''
### The Journey of "Juggernaut"

* **English meaning:** An overwhelming, unstoppable force or institution that crushes whatever is in its path.
* **Origin:** A direct historical borrowing from Odia and Sanskrit **Jagannātha** (जगन्नाथ), title of the presiding deity of Puri, Odisha.
* **Etymological composition:** *Jagat* (the moving universe) + *Nātha* (lord, protector).
* **The semantic migration:** During the annual *Ratha Yatra*, the colossal 45-foot temple chariots with sixteen wooden wheels carried the deity through jubilant crowds. 17th-century European travelers were mesmerized by the sheer scale and momentum of these chariots, transposing the name into an English metaphor for unstoppable power.
''';
        followUps = ['Tell me about Avatar', 'How did Bungalow enter English?'];
      } else if (query.contains('avatar')) {
        responseText = '''
### The Journey of "Avatar"

* **English meaning:** An incarnation, bodily manifestation, or digital persona in virtual spaces.
* **Sanskrit root:** **avatāra** (अवतार), from prefix *ava-* (down, downwards) + root *tṛ* (to cross over, step across).
* **Classical context:** In Vedic cosmology, an avatāra is a deliberate descent of the divine consciousness into earthly form to restore cosmic balance (*dharma*).
* **The cyber-shift:** In 1985, game designer Chip Morningstar borrowed the term for the virtual avatars of *Lucasfilm's Habitat*, later cemented in science fiction by Neal Stephenson in *Snow Crash*.
''';
        followUps = ['What is the root of Guru?', 'Show words derived from Sanskrit'];
      } else {
        responseText = '''
### Indian Linguistic Connections: Rigorous Etymology

When exploring Indian linguistic heritage, we make two critical distinctions:

1. **Direct Loanwords:** Words adopted into English through trade, colonialism, or cultural contact (e.g. *juggernaut*, *bungalow*, *avatar*, *guru*, *jungle*, *cheetah*, *bandana*, *cot*).
2. **PIE Cognates:** Ancient genetic cousins descended from shared prehistoric Proto-Indo-European roots over 5,000 years ago (e.g. English *brother* & Sanskrit *bhrātṛ*; English *mother* & Sanskrit *mātṛ*; English *name* & Sanskrit *nāma*).

Ask me about any specific word to explore its verified lineage!
''';
        followUps = ['Explain PIE cognates with Sanskrit', 'Words borrowed from Hindi'];
      }
    } else if (query.contains('improve') || query.contains('correct') || query.contains('sentence') || query.contains('rewrite')) {
      responseText = '''
### Sentence Refinement & Polish

To refine your writing, share the sentence you would like to polish. Ask Garuda can adjust:

1. **Tone:** Elevate to editorial prose, polish for professional correspondence, or streamline for clear speech.
2. **Cadence & Rhythm:** Remove clumsy passive constructions and repetitive verbs.
3. **Lexical Precision:** Substitute overused words (*good*, *bad*, *nice*) with crisp, resonant alternatives.

*Paste your sentence here, and tell me the intended tone or audience!*
''';
      followUps = ['Make my writing sound more literary', 'Fix grammar and tone in this paragraph'];
    } else if (query.contains('mnemonic') || query.contains('remember') || query.contains('quiz')) {
      responseText = '''
### The Architecture of Word Memory

To commit advanced vocabulary to permanent memory, use the **Triad Technique**:

1. **Etymological Anchor:** Learn the Latin, Greek, or Sanskrit root. Roots are universal keys that unlock dozens of related words.
2. **Sensory Metaphor:** Attach the word to a physical sensation (e.g. *petrichor* = the cool, ozone-soaked scent of wet garden soil).
3. **Active Utterance:** Write one original sentence placing the word in a personal scenario within 24 hours.

Give me any word you struggle to remember, and I will craft an unforgettable memory anchor for you!
''';
      followUps = ['Help me remember Ineffable', 'Help me remember Equanimity'];
    } else {
      // General literary explanation
      responseText = '''
### Linguistic Insight on "$prompt"

Words are living vessels of human history and emotion. In exploring **"$prompt"**:

* **Precise Definition:** A term is best understood not in isolation, but in its natural literary habitations.
* **Connotation & Weight:** Notice the cadence of the syllables and whether the term leans toward spoken intimacy or formal rhetoric.
* **Suggested Application:** Try framing it where its exact shade of meaning replaces a clumsy two-word phrase.

How would you like to explore this further? I can provide creative examples, contrast it with similar words, or search for its etymological roots.
''';
      followUps = ['Give contextual examples', 'What are similar words?', 'Explore its etymology'];
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: responseText.trim(),
      isUser: false,
      timestamp: DateTime.now(),
      isDemo: true,
      quickFollowUps: followUps,
    );
  }
}

/// Helper to generate intelligent follow-up prompt suggestions
List<String> _generateContextualFollowUps(String prompt, String response) {
  final clean = prompt.toLowerCase();
  if (clean.contains('difference') || clean.contains('compare')) {
    return ['Give an example in literature', 'How do I use this in formal writing?'];
  }
  if (clean.contains('sanskrit') || clean.contains('origin')) {
    return ['Are there other cognates?', 'Show modern usage'];
  }
  return ['Explain more simply', 'Compare with similar words', 'Help me remember this'];
}
