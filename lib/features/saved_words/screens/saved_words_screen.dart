import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/word_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/empty_state_view.dart';
import '../../word_details/screens/word_details_screen.dart';

class SavedWordsScreen extends StatefulWidget {
  final StorageService storageService;
  final DictionaryService dictionaryService;
  final AudioService audioService;
  final Function(String prompt)? onAskAi;
  final Function(int tabIndex)? onNavigateToTab;

  const SavedWordsScreen({
    super.key,
    required this.storageService,
    required this.dictionaryService,
    required this.audioService,
    this.onAskAi,
    this.onNavigateToTab,
  });

  @override
  State<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends State<SavedWordsScreen> {
  List<WordEntry> _savedWords = [];
  String _filterQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedWords();
    _searchController.addListener(() {
      setState(() {
        _filterQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _loadSavedWords() {
    setState(() {
      _savedWords = widget.storageService.getSavedWords();
    });
  }

  Future<void> _removeWord(WordEntry entry) async {
    await widget.storageService.removeSavedWord(entry.word);
    _loadSavedWords();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed "${entry.word}" from vocabulary notebook.'),
          backgroundColor: AppColors.deepInk,
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.terracottaLight,
            onPressed: () async {
              await widget.storageService.saveWord(entry);
              _loadSavedWords();
            },
          ),
        ),
      );
    }
  }

  void _openWord(WordEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordDetailsScreen(
          initialEntry: entry,
          dictionaryService: widget.dictionaryService,
          storageService: widget.storageService,
          audioService: widget.audioService,
          onAskAi: widget.onAskAi,
          onSelectWord: (w) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WordDetailsScreen(
                  wordQuery: w,
                  dictionaryService: widget.dictionaryService,
                  storageService: widget.storageService,
                  audioService: widget.audioService,
                  onAskAi: widget.onAskAi,
                ),
              ),
            );
          },
        ),
      ),
    ).then((_) => _loadSavedWords());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterQuery.isEmpty
        ? _savedWords
        : _savedWords.where((e) {
            return e.word.toLowerCase().contains(_filterQuery) ||
                e.primaryDefinition.toLowerCase().contains(_filterQuery);
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: Text(
          'Saved Vocabulary',
          style: AppTypography.serifHeading(fontSize: 22),
        ),
        actions: [
          if (_savedWords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${_savedWords.length} ${_savedWords.length == 1 ? 'word' : 'words'}',
                  style: AppTypography.sansLabel(
                    fontSize: 12,
                    color: AppColors.warmGray,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _savedWords.isEmpty
          ? EmptyStateView(
              icon: Icons.bookmark_border_rounded,
              title: 'Your Vocabulary Notebook is Empty',
              message:
                  'As you read and explore words, tap the bookmark icon on any word to keep it in your permanent study collection.',
              buttonText: 'Discover Curated Collections',
              onButtonPressed: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(1); // Navigate to Explore
                }
              },
            )
          : Column(
              children: [
                // Filter search bar within saved words
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.sansBody(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Filter your saved words...',
                        hintStyle: AppTypography.sansBody(fontSize: 13, color: AppColors.warmGray),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.warmGray),
                        suffixIcon: _filterQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.warmGray),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: filtered.isEmpty
                      ? EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'No matching saved words',
                          message: 'No saved entry matches "$_filterQuery".',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            final savedDateStr = entry.savedAt != null
                                ? DateFormat('MMM d, yyyy').format(entry.savedAt!)
                                : 'Saved';

                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ListTile(
                                onTap: () => _openWord(entry),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                title: Row(
                                  children: [
                                    Text(
                                      entry.word,
                                      style: AppTypography.serifHeading(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceSand,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        entry.primaryPartOfSpeech,
                                        style: AppTypography.sansLabel(
                                          fontSize: 10,
                                          color: AppColors.warmGray,
                                        ),
                                      ),
                                    ),
                                    if (entry.indianConnections.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.sageGreenSurface,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          entry.indianConnections.first.language,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.sageGreen,
                                          ),
                                        ),
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
                                      style: AppTypography.sansBody(
                                        fontSize: 13,
                                        color: AppColors.deepInk.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Added on $savedDateStr',
                                      style: AppTypography.sansLabel(
                                        fontSize: 11,
                                        color: AppColors.warmGray,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.bookmark_remove_outlined,
                                    size: 20,
                                    color: AppColors.warmGray,
                                  ),
                                  tooltip: 'Remove',
                                  onPressed: () => _removeWord(entry),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
