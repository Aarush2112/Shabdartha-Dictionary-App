import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/curated_words.dart';
import '../../../models/word_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/empty_state_view.dart';
import '../../../widgets/loading_view.dart';
import '../../word_details/screens/word_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final DictionaryService dictionaryService;
  final StorageService storageService;
  final AudioService audioService;
  final Function(String prompt)? onAskAi;

  const SearchScreen({
    super.key,
    required this.dictionaryService,
    required this.storageService,
    required this.audioService,
    this.onAskAi,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;

  List<String> _recentSearches = [];
  List<String> _suggestions = [];
  List<WordEntry> _curatedMatches = [];
  bool _isLoading = false;
  String _activeQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _controller.addListener(_onQueryChanged);
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = widget.storageService.getRecentSearches();
    });
  }

  void _onQueryChanged() {
    final query = _controller.text.trim();
    if (query == _activeQuery) return;

    _activeQuery = query;
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _curatedMatches = [];
        _isLoading = false;
      });
      return;
    }

    // Immediate local curated matches
    final local = searchCuratedWords(query);
    setState(() {
      _curatedMatches = local;
      _isLoading = true;
    });

    // Debounce online suggestions
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final suggestions = await widget.dictionaryService.getSuggestions(query);
      if (mounted && _controller.text.trim() == query) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      }
    });
  }

  void _openWord(String word) {
    final clean = word.trim();
    if (clean.isEmpty) return;

    // Save to recent search history
    widget.storageService.addRecentSearch(clean);
    _loadRecentSearches();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordDetailsScreen(
          wordQuery: clean,
          dictionaryService: widget.dictionaryService,
          storageService: widget.storageService,
          audioService: widget.audioService,
          onAskAi: widget.onAskAi,
          onSelectWord: (w) => _openWord(w),
        ),
      ),
    );
  }

  Future<void> _clearAllRecent() async {
    await widget.storageService.clearRecentSearches();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _openWord,
              style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search exhibition, word, or root...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF8E8E93)),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF8E8E93)),
                        onPressed: () {
                          _controller.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    final query = _controller.text.trim();

    if (query.isEmpty) {
      return _buildRecentSearchesSection();
    }

    if (_isLoading && _curatedMatches.isEmpty && _suggestions.isEmpty) {
      return const LoadingView(message: 'Searching dictionary...');
    }

    if (_curatedMatches.isEmpty && _suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyStateView(
              icon: Icons.search_off_rounded,
              title: 'No exact matches found',
              message: 'Press Search on keyboard to look up "$query" in the comprehensive live lexicon.',
              buttonText: 'Look up "$query"',
              onButtonPressed: () => _openWord(query),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        // Curated Editorial Entries First (if any)
        if (_curatedMatches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Icon(Icons.verified_outlined, size: 15, color: AppColors.sageGreen),
                const SizedBox(width: 6),
                Text(
                  'CURATED ENTRIES WITH INDIAN ROOTS',
                  style: AppTypography.sansLabel(fontSize: 11, color: AppColors.sageGreen),
                ),
              ],
            ),
          ),
          ..._curatedMatches.map((entry) => _buildCuratedResultCard(entry)),
          const SizedBox(height: 12),
        ],

        // General suggestions & autocomplete
        if (_suggestions.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'DICTIONARY SUGGESTIONS',
              style: AppTypography.sansLabel(fontSize: 11, color: AppColors.warmGray),
            ),
          ),
          ..._suggestions.map((word) => _buildSuggestionTile(word)),
        ],

        // Fallback row allowing user to search literal term
        const Divider(height: 24),
        ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: AppColors.surfaceSand.withValues(alpha: 0.5),
          leading: const Icon(Icons.arrow_forward_rounded, color: AppColors.terracotta),
          title: Text(
            'Look up full entry for "$query"',
            style: AppTypography.sansBody(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.terracotta,
            ),
          ),
          onTap: () => _openWord(query),
        ),
      ],
    );
  }

  Widget _buildRecentSearchesSection() {
    if (_recentSearches.isEmpty) {
      return const EmptyStateView(
        icon: Icons.history_rounded,
        title: 'Begin Your Inquiry',
        message: 'Search for any word in English, or discover words with rich roots in Sanskrit and Hindi.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT SEARCHES',
              style: AppTypography.sansLabel(
                fontSize: 11,
                color: AppColors.warmGray,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: _clearAllRecent,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warmGray,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Clear all', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _recentSearches.map((term) {
            return ActionChip(
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border),
              label: Text(
                term,
                style: AppTypography.sansBody(fontSize: 13, color: AppColors.deepInk),
              ),
              avatar: const Icon(Icons.history_rounded, size: 14, color: AppColors.warmGray),
              onPressed: () => _openWord(term),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        Text(
          'RECOMMENDED EXPLORATIONS',
          style: AppTypography.sansLabel(
            fontSize: 11,
            color: AppColors.warmGray,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 10),
        ...['juggernaut', 'avatar', 'petrichor', 'brother', 'serendipity', 'solitude'].map(
          (word) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.north_west_rounded, size: 16, color: AppColors.warmGray),
            title: Text(
              word,
              style: AppTypography.sansBody(fontSize: 14.5, color: AppColors.deepInk),
            ),
            onTap: () => _openWord(word),
          ),
        ),
      ],
    );
  }

  Widget _buildCuratedResultCard(WordEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => _openWord(entry.word),
        title: Row(
          children: [
            Text(
              entry.word,
              style: AppTypography.serifHeading(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (entry.phonetic != null) ...[
              const SizedBox(width: 8),
              Text(
                entry.phonetic!,
                style: AppTypography.phonetic(fontSize: 13),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              entry.primaryDefinition,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.sansBody(fontSize: 13, color: AppColors.warmGray),
            ),
            if (entry.indianConnections.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${entry.indianConnections.first.nativeScript} (${entry.indianConnections.first.relationType.label})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sageGreen,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.warmGray),
      ),
    );
  }

  Widget _buildSuggestionTile(String word) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: const Icon(Icons.search_rounded, size: 18, color: AppColors.warmGray),
      title: Text(
        word,
        style: AppTypography.sansBody(fontSize: 14.5, color: AppColors.deepInk),
      ),
      trailing: const Icon(Icons.north_west_rounded, size: 14, color: AppColors.warmGray),
      onTap: () => _openWord(word),
    );
  }
}
