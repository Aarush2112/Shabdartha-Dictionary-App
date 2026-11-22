import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/word_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/empty_state_view.dart';
import '../../word_details/screens/word_details_screen.dart';

/// Exhibition UI implementation for Saved Words.
/// Matches the exact white exhibition canvas, high-contrast serif typography,
/// and arched museum art pieces from the reference design.
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

  final List<String> _thumbnailArtworks = [
    'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=400',
    'https://images.unsplash.com/photo-1582561424760-0321d75e81fa?w=400',
    'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=400',
    'https://images.unsplash.com/photo-1580136579312-94651dfd596d?w=400',
    'https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?w=400',
  ];

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
          content: Text('Removed "${entry.word}" from saved vocabulary.'),
          backgroundColor: Colors.black,
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.antiqueGoldLight,
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
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 110.0),
          children: [
            // 1. Top Bar (Matching Screen 2 top bar with NO person icon)
            _buildTopBar(),

            const SizedBox(height: 24),

            // 2. High-Contrast Bold Serif Headline
            Text(
              'Saved\nVocabulary...',
              style: AppTypography.editorialHeadline(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.15,
              ),
            ),

            const SizedBox(height: 20),

            // 3. Pill Search Input
            _buildPillSearch(),

            const SizedBox(height: 28),

            // 4. Section Header with Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Personal Collection',
                  style: AppTypography.serifHeading(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${filtered.length} ${filtered.length == 1 ? 'Word' : 'Words'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 5. Saved Words List or Empty State
            if (_savedWords.isEmpty)
              _buildEmptyState()
            else if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: EmptyStateView(
                  icon: Icons.search_off_rounded,
                  title: 'No Matching Terms',
                  message: 'No saved entry matches "$_filterQuery".',
                ),
              )
            else
              ...filtered.asMap().entries.map((entryItem) {
                final index = entryItem.key;
                final entry = entryItem.value;
                final thumbUrl = _thumbnailArtworks[index % _thumbnailArtworks.length];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: _buildSavedWordCard(entry, thumbUrl),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: 4-dot grid button
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bookmark_rounded,
            size: 20,
            color: Colors.white,
          ),
        ),

        // Center: App Name & Edition
        Column(
          children: [
            Text(
              'SHABDARTHA',
              style: AppTypography.editorialHeadline(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 2),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'शब्दार्थ • Saved Vocabulary',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Right: Clean Count Pill (NO person icon!)
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F2F5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${_savedWords.length}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillSearch() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F5),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 20, color: Color(0xFF8E8E93)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Filter your saved words...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: _filterQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF8E8E93)),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedWordCard(WordEntry entry, String thumbUrl) {
    return InkWell(
      onTap: () => _openWord(entry),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEEEF2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arched Cathedral Mini Thumbnail (matching Screen 3 arched motif)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: SizedBox(
                width: 58,
                height: 74,
                child: Image.network(
                  thumbUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black12,
                    child: const Icon(Icons.menu_book_rounded, color: Colors.black38, size: 20),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.word,
                        style: AppTypography.editorialHeadline(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      InkWell(
                        onTap: () => _removeWord(entry),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.bookmark_rounded,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  // Subtitle & Pills
                  Row(
                    children: [
                      if (entry.phonetic != null && entry.phonetic!.isNotEmpty)
                        Text(
                          entry.phonetic!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF8E8E93),
                          ),
                        ),
                      if (entry.indianConnections.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF5EF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            entry.indianConnections.first.nativeScript,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.sageGreen,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    entry.primaryDefinition,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF3C3C43),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEEEF2)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Your Study Notebook is Empty',
            textAlign: TextAlign.center,
            style: AppTypography.editorialHeadline(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'As you read through exhibitions and uncover words of Indian origin, tap the bookmark icon to curate your permanent collection.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF8E8E93),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(1); // Go to Explore
              }
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore Exhibitions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
