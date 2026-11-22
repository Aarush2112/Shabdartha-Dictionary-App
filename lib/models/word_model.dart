/// Classification of Indian linguistic relationships.
/// Strictly differentiates direct borrowings from Proto-Indo-European cognates and conceptual parallels.
enum IndianRelationType {
  loanword, // Directly borrowed from Sanskrit/Hindi/Dravidian (e.g., Juggernaut from Jagannath)
  cognate, // Shared Proto-Indo-European ancestor (e.g., Mother / Matr, Brother / Bhratr)
  conceptualParallel, // Deep philosophical or expressive equivalent
}

extension IndianRelationTypeExtension on IndianRelationType {
  String get label {
    switch (this) {
      case IndianRelationType.loanword:
        return 'Direct Loanword';
      case IndianRelationType.cognate:
        return 'PIE Cognate (Shared Ancestor)';
      case IndianRelationType.conceptualParallel:
        return 'Conceptual Parallel';
    }
  }

  String get description {
    switch (this) {
      case IndianRelationType.loanword:
        return 'Adopted into English from an Indian language.';
      case IndianRelationType.cognate:
        return 'Descends from a shared Proto-Indo-European root with Sanskrit.';
      case IndianRelationType.conceptualParallel:
        return 'Explores semantic or philosophical resonance across traditions.';
    }
  }
}

class IndianLanguageConnection {
  final String language; // e.g. "Sanskrit", "Hindi", "Tamil"
  final String nativeScript; // e.g. "भ्रातृ" or "जगन्नाथ"
  final String transliteration; // e.g. "bhrātṛ" or "jagannātha"
  final String meaning;
  final IndianRelationType relationType;
  final String academicNote;
  final bool isVerified;

  const IndianLanguageConnection({
    required this.language,
    required this.nativeScript,
    required this.transliteration,
    required this.meaning,
    required this.relationType,
    required this.academicNote,
    this.isVerified = true,
  });

  Map<String, dynamic> toJson() => {
        'language': language,
        'nativeScript': nativeScript,
        'transliteration': transliteration,
        'meaning': meaning,
        'relationType': relationType.name,
        'academicNote': academicNote,
        'isVerified': isVerified,
      };

  factory IndianLanguageConnection.fromJson(Map<String, dynamic> json) {
    IndianRelationType rel;
    try {
      rel = IndianRelationType.values.byName(json['relationType'] as String);
    } catch (_) {
      rel = IndianRelationType.conceptualParallel;
    }
    return IndianLanguageConnection(
      language: json['language'] as String? ?? 'Sanskrit',
      nativeScript: json['nativeScript'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      meaning: json['meaning'] as String? ?? '',
      relationType: rel,
      academicNote: json['academicNote'] as String? ?? '',
      isVerified: json['isVerified'] as bool? ?? true,
    );
  }
}

class DefinitionItem {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  const DefinitionItem({
    required this.definition,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  Map<String, dynamic> toJson() => {
        'definition': definition,
        'example': example,
        'synonyms': synonyms,
        'antonyms': antonyms,
      };

  factory DefinitionItem.fromJson(Map<String, dynamic> json) => DefinitionItem(
        definition: json['definition'] as String? ?? '',
        example: json['example'] as String?,
        synonyms: (json['synonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        antonyms: (json['antonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
}

class WordMeaning {
  final String partOfSpeech;
  final List<DefinitionItem> definitions;

  const WordMeaning({
    required this.partOfSpeech,
    required this.definitions,
  });

  Map<String, dynamic> toJson() => {
        'partOfSpeech': partOfSpeech,
        'definitions': definitions.map((e) => e.toJson()).toList(),
      };

  factory WordMeaning.fromJson(Map<String, dynamic> json) => WordMeaning(
        partOfSpeech: json['partOfSpeech'] as String? ?? '',
        definitions: (json['definitions'] as List<dynamic>?)
                ?.map((e) => DefinitionItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class WordEntry {
  final String word;
  final String? phonetic;
  final String? audioUrl;
  final List<WordMeaning> meanings;
  final String? etymology;
  final String? origin;
  final List<IndianLanguageConnection> indianConnections;
  final String source;
  final bool isCurated;
  final String? editorialInsight;
  final DateTime? savedAt;

  const WordEntry({
    required this.word,
    this.phonetic,
    this.audioUrl,
    required this.meanings,
    this.etymology,
    this.origin,
    this.indianConnections = const [],
    this.source = 'Dictionary',
    this.isCurated = false,
    this.editorialInsight,
    this.savedAt,
  });

  WordEntry copyWith({
    String? word,
    String? phonetic,
    String? audioUrl,
    List<WordMeaning>? meanings,
    String? etymology,
    String? origin,
    List<IndianLanguageConnection>? indianConnections,
    String? source,
    bool? isCurated,
    String? editorialInsight,
    DateTime? savedAt,
  }) {
    return WordEntry(
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      audioUrl: audioUrl ?? this.audioUrl,
      meanings: meanings ?? this.meanings,
      etymology: etymology ?? this.etymology,
      origin: origin ?? this.origin,
      indianConnections: indianConnections ?? this.indianConnections,
      source: source ?? this.source,
      isCurated: isCurated ?? this.isCurated,
      editorialInsight: editorialInsight ?? this.editorialInsight,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  // Collect all distinct synonyms
  List<String> get allSynonyms {
    final set = <String>{};
    for (final m in meanings) {
      for (final d in m.definitions) {
        set.addAll(d.synonyms);
      }
    }
    return set.toList();
  }

  // Collect all distinct antonyms
  List<String> get allAntonyms {
    final set = <String>{};
    for (final m in meanings) {
      for (final d in m.definitions) {
        set.addAll(d.antonyms);
      }
    }
    return set.toList();
  }

  // Primary short definition
  String get primaryDefinition {
    if (meanings.isNotEmpty && meanings.first.definitions.isNotEmpty) {
      return meanings.first.definitions.first.definition;
    }
    return 'No definition available.';
  }

  // Primary part of speech
  String get primaryPartOfSpeech {
    if (meanings.isNotEmpty) {
      return meanings.first.partOfSpeech;
    }
    return 'noun';
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'phonetic': phonetic,
        'audioUrl': audioUrl,
        'meanings': meanings.map((e) => e.toJson()).toList(),
        'etymology': etymology,
        'origin': origin,
        'indianConnections': indianConnections.map((e) => e.toJson()).toList(),
        'source': source,
        'isCurated': isCurated,
        'editorialInsight': editorialInsight,
        'savedAt': savedAt?.toIso8601String(),
      };

  factory WordEntry.fromJson(Map<String, dynamic> json) => WordEntry(
        word: json['word'] as String? ?? '',
        phonetic: json['phonetic'] as String?,
        audioUrl: json['audioUrl'] as String?,
        meanings: (json['meanings'] as List<dynamic>?)
                ?.map((e) => WordMeaning.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        etymology: json['etymology'] as String?,
        origin: json['origin'] as String?,
        indianConnections: (json['indianConnections'] as List<dynamic>?)
                ?.map((e) => IndianLanguageConnection.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        source: json['source'] as String? ?? 'Dictionary',
        isCurated: json['isCurated'] as bool? ?? false,
        editorialInsight: json['editorialInsight'] as String?,
        savedAt: json['savedAt'] != null ? DateTime.tryParse(json['savedAt'] as String) : null,
      );

  /// Parse response from the Free Dictionary API (https://api.dictionaryapi.dev/api/v2/entries/en/{word})
  factory WordEntry.fromFreeDictionaryJson(Map<String, dynamic> json) {
    final word = json['word'] as String? ?? '';

    // Phonetic text
    String? phonetic = json['phonetic'] as String?;
    String? audioUrl;

    if (json['phonetics'] is List) {
      final phoneticsList = json['phonetics'] as List<dynamic>;
      for (final p in phoneticsList) {
        if (p is Map<String, dynamic>) {
          if (phonetic == null || phonetic.isEmpty) {
            phonetic = p['text'] as String?;
          }
          final audio = p['audio'] as String?;
          if (audio != null && audio.isNotEmpty && audioUrl == null) {
            audioUrl = audio;
          }
        }
      }
    }

    final meaningsList = <WordMeaning>[];
    if (json['meanings'] is List) {
      for (final m in json['meanings'] as List<dynamic>) {
        if (m is Map<String, dynamic>) {
          final pos = m['partOfSpeech'] as String? ?? 'word';
          final defs = <DefinitionItem>[];

          if (m['definitions'] is List) {
            for (final d in m['definitions'] as List<dynamic>) {
              if (d is Map<String, dynamic>) {
                final defText = d['definition'] as String? ?? '';
                final exText = d['example'] as String?;
                final syns = (d['synonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                final ants = (d['antonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
                defs.add(DefinitionItem(
                  definition: defText,
                  example: exText,
                  synonyms: syns,
                  antonyms: ants,
                ));
              }
            }
          }

          meaningsList.add(WordMeaning(
            partOfSpeech: pos,
            definitions: defs,
          ));
        }
      }
    }

    return WordEntry(
      word: word,
      phonetic: phonetic,
      audioUrl: audioUrl,
      meanings: meaningsList,
      source: 'Free Dictionary API',
      isCurated: false,
    );
  }
}
