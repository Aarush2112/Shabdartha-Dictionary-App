import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/word_model.dart';
import '../models/chat_message.dart';

class StorageService {
  static const String _keyBookmarks = 'garuda_bookmarks';
  static const String _keyRecentSearches = 'garuda_recent_searches';
  static const String _keyAiApiKey = 'garuda_ai_api_key';
  static const String _keyAiModel = 'garuda_ai_model';
  static const String _keyChatHistory = 'garuda_chat_history';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- BOOKMARKS / SAVED WORDS ---

  List<WordEntry> getSavedWords() {
    try {
      final jsonList = _prefs.getStringList(_keyBookmarks) ?? [];
      return jsonList
          .map((item) => WordEntry.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveWord(WordEntry word) async {
    final list = getSavedWords();
    // Remove if already present, to update timestamp or avoid duplicates
    list.removeWhere((e) => e.word.toLowerCase() == word.word.toLowerCase());
    final entryWithDate = word.copyWith(savedAt: DateTime.now());
    list.insert(0, entryWithDate);

    final encoded = list.map((e) => jsonEncode(e.toJson())).toList();
    return await _prefs.setStringList(_keyBookmarks, encoded);
  }

  Future<bool> removeSavedWord(String word) async {
    final list = getSavedWords();
    list.removeWhere((e) => e.word.toLowerCase() == word.toLowerCase());
    final encoded = list.map((e) => jsonEncode(e.toJson())).toList();
    return await _prefs.setStringList(_keyBookmarks, encoded);
  }

  bool isWordSaved(String word) {
    final list = getSavedWords();
    return list.any((e) => e.word.toLowerCase() == word.toLowerCase());
  }

  // --- RECENT SEARCHES ---

  List<String> getRecentSearches() {
    return _prefs.getStringList(_keyRecentSearches) ?? [];
  }

  Future<bool> addRecentSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return false;

    final list = getRecentSearches();
    list.removeWhere((item) => item.toLowerCase() == clean.toLowerCase());
    list.insert(0, clean);

    // Keep max 15 recent searches
    if (list.length > 15) {
      list.removeRange(15, list.length);
    }
    return await _prefs.setStringList(_keyRecentSearches, list);
  }

  Future<bool> clearRecentSearches() async {
    return await _prefs.remove(_keyRecentSearches);
  }

  // --- AI CONFIGURATION ---

  String? getAiApiKey() {
    return _prefs.getString(_keyAiApiKey);
  }

  Future<bool> setAiApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      return await _prefs.remove(_keyAiApiKey);
    }
    return await _prefs.setString(_keyAiApiKey, key.trim());
  }

  String getAiModel() {
    return _prefs.getString(_keyAiModel) ?? 'gemini-1.5-flash';
  }

  Future<bool> setAiModel(String model) async {
    return await _prefs.setString(_keyAiModel, model);
  }

  // --- CHAT HISTORY ---

  List<ChatMessage> getChatHistory() {
    try {
      final jsonList = _prefs.getStringList(_keyChatHistory) ?? [];
      return jsonList
          .map((item) => ChatMessage.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveChatHistory(List<ChatMessage> messages) async {
    try {
      // Keep up to 30 latest messages
      final trimmed = messages.length > 30 ? messages.sublist(messages.length - 30) : messages;
      final encoded = trimmed.map((e) => jsonEncode(e.toJson())).toList();
      return await _prefs.setStringList(_keyChatHistory, encoded);
    } catch (_) {
      return false;
    }
  }

  Future<bool> clearChatHistory() async {
    return await _prefs.remove(_keyChatHistory);
  }
}
