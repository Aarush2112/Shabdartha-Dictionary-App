import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/curated_words.dart';
import '../models/word_model.dart';

class DictionaryService {
  final http.Client _client;

  DictionaryService({http.Client? client}) : _client = client ?? http.Client();

  /// Deterministically fetches the Word of the Day.
  /// Stable for the entire calendar day without randomly changing on reopen.
  WordEntry getWordOfTheDay() {
    final now = DateTime.now();
    // Deterministic index from year and day of year
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = (now.year + dayOfYear) % curatedWordEntries.length;
    return curatedWordEntries[index];
  }

  /// Look up full definition for a word.
  /// Seamlessly checks curated repository first, then falls back to Free Dictionary API.
  Future<WordEntry> lookupWord(String word) async {
    final clean = word.trim().toLowerCase();
    if (clean.isEmpty) {
      throw Exception('Please enter a word to search.');
    }

    // 1. Check curated collection first (instant, enriched with verified Indian roots)
    final curated = findCuratedWord(clean);
    if (curated != null) {
      return curated;
    }

    // 2. Fetch from public Free Dictionary API
    final url = Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$clean');
    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        if (data.isNotEmpty && data.first is Map<String, dynamic>) {
          var entry = WordEntry.fromFreeDictionaryJson(data.first as Map<String, dynamic>);

          // Check if any partial curated connection matches
          final partialCurated = findCuratedWord(entry.word);
          if (partialCurated != null && partialCurated.indianConnections.isNotEmpty) {
            entry = entry.copyWith(
              indianConnections: partialCurated.indianConnections,
              etymology: partialCurated.etymology,
              editorialInsight: partialCurated.editorialInsight,
            );
          }

          return entry;
        }
      } else if (response.statusCode == 404) {
        throw Exception('Word not found in the dictionary.');
      } else {
        throw Exception('Dictionary service responded with code ${response.statusCode}.');
      }
    } catch (e) {
      // If network fails, re-check if we have any near curated match
      final nearMatch = curatedWordEntries.firstWhere(
        (e) => e.word.toLowerCase() == clean,
        orElse: () => throw Exception('Unable to locate "$word". Please check your spelling or network connection.'),
      );
      return nearMatch;
    }

    throw Exception('Unable to locate "$word".');
  }

  /// Provides autocomplete suggestions as user types.
  /// Combines local curated list + Datamuse API with quick timeout.
  Future<List<String>> getSuggestions(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final suggestions = <String>{};

    // 1. Local curated suggestions first
    final localMatches = searchCuratedWords(clean);
    for (final match in localMatches) {
      suggestions.add(match.word);
    }

    // 2. Query Datamuse suggestion endpoint with a strict timeout
    try {
      final url = Uri.parse('https://api.datamuse.com/sug?s=$clean&max=8');
      final res = await _client.get(url).timeout(const Duration(milliseconds: 1500));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
        for (final item in data) {
          if (item is Map<String, dynamic> && item.containsKey('word')) {
            final w = (item['word'] as String).toLowerCase();
            if (!w.contains(' ')) {
              suggestions.add(w);
            }
          }
        }
      }
    } catch (_) {
      // Ignore network timeout on suggestions; local matches suffice
    }

    return suggestions.take(8).toList();
  }
}
