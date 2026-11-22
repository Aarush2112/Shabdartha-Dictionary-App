import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/curated_collections.dart';
import '../../../models/word_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import '../../search/screens/search_screen.dart';
import '../../word_details/screens/word_details_screen.dart';
import '../../word_details/widgets/audio_pronunciation_button.dart';
import '../../word_explorer/screens/collection_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final DictionaryService dictionaryService;
  final StorageService storageService;
  final AudioService audioService;
  final Function(int tabIndex)? onNavigateToTab;
  final Function(String prompt)? onAskAi;

  const HomeScreen({
    super.key,
    required this.dictionaryService,
    required this.storageService,
    required this.audioService,
    this.onNavigateToTab,
    this.onAskAi,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WordEntry _wordOfTheDay;
  bool _isWotdSaved = false;
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    _wordOfTheDay = widget.dictionaryService.getWordOfTheDay();
    _isWotdSaved = widget.storageService.isWordSaved(_wordOfTheDay.word);
    _recentSearches = widget.storageService.getRecentSearches();
    setState(() {});
  }

  Future<void> _toggleWotdSave() async {
    if (_isWotdSaved) {
      await widget.storageService.removeSavedWord(_wordOfTheDay.word);
      setState(() => _isWotdSaved = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${_wordOfTheDay.word}" from bookmarks.'),
            backgroundColor: AppColors.deepInk,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      await widget.storageService.saveWord(_wordOfTheDay);
      setState(() => _isWotdSaved = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved "${_wordOfTheDay.word}" to bookmarks.'),
            backgroundColor: AppColors.sageGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _openWord(String word) {
    widget.storageService.addRecentSearch(word);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordDetailsScreen(
          wordQuery: word,
          dictionaryService: widget.dictionaryService,
          storageService: widget.storageService,
          audioService: widget.audioService,
          onAskAi: widget.onAskAi,
          onSelectWord: (w) => _openWord(w),
        ),
      ),
    ).then((_) => _loadState());
  }

  void _openSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SearchScreen(
          dictionaryService: widget.dictionaryService,
          storageService: widget.storageService,
          audioService: widget.audioService,
          onAskAi: widget.onAskAi,
        ),
      ),
    ).then((_) => _loadState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.terracotta,
          onRefresh: () async {
            _loadState();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            children: [
              // Editorial Masthead
              _buildMasthead(),

              const SizedBox(height: 20),

              // Search Trigger Bar
              _buildSearchBarTrigger(),

              const SizedBox(height: 24),

              // Featured Word of the Day Hero Card
              _buildWordOfTheDayCard(),

              const SizedBox(height: 24),

              // Ask Garuda Entry Banner
              _buildAskGarudaBanner(),

              const SizedBox(height: 24),

              // Curated Collections Carousel
              _buildCuratedCollectionsSection(),

              const SizedBox(height: 24),

              // Recent Searches (if available) or Recommended Inquiries
              _buildRecentSearchesSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasthead() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'GARUDA LEXICON',
                  style: AppTypography.serifHeading(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSand,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'EDITION I',
                    style: AppTypography.sansLabel(
                      fontSize: 9,
                      color: AppColors.warmGray,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'The Dictionary & AI Language Companion',
              style: AppTypography.sansBody(
                fontSize: 13,
                color: AppColors.warmGray,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceSand,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 20,
            color: AppColors.terracotta,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarTrigger() {
    return InkWell(
      onTap: _openSearch,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: AppColors.warmGray),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search English, Sanskrit roots, or Hindi...',
                style: AppTypography.sansBody(
                  fontSize: 14,
                  color: AppColors.warmGray,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceSand,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'LOOKUP',
                style: AppTypography.sansLabel(
                  fontSize: 10,
                  color: AppColors.deepInk,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordOfTheDayCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Tag & Save Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.terracotta,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'WORD OF THE DAY',
                      style: AppTypography.sansLabel(
                        fontSize: 11,
                        color: AppColors.terracottaDark,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isWotdSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _isWotdSaved ? AppColors.terracotta : AppColors.warmGray,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Bookmark',
                  onPressed: _toggleWotdSave,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Word Name & Audio Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  _wordOfTheDay.word,
                  style: AppTypography.heroWord(fontSize: 34),
                ),
                if (_wordOfTheDay.phonetic != null) ...[
                  const SizedBox(width: 10),
                  Text(
                    _wordOfTheDay.phonetic!,
                    style: AppTypography.phonetic(fontSize: 14),
                  ),
                ],
                const Spacer(),
                if (_wordOfTheDay.audioUrl != null)
                  AudioPronunciationButton(
                    audioUrl: _wordOfTheDay.audioUrl,
                    audioService: widget.audioService,
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Part of Speech Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceSand,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _wordOfTheDay.primaryPartOfSpeech,
                style: AppTypography.sansLabel(
                  fontSize: 11,
                  color: AppColors.warmGray,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Definition Text
            Text(
              _wordOfTheDay.primaryDefinition,
              style: AppTypography.sansBody(
                fontSize: 15,
                color: AppColors.deepInk,
                height: 1.45,
              ),
            ),

            // Indian Linguistic Connection Callout (if present)
            if (_wordOfTheDay.indianConnections.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sageGreenSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.sageGreenBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.temple_hindu_outlined,
                      size: 16,
                      color: AppColors.sageGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_wordOfTheDay.indianConnections.first.language}: ${_wordOfTheDay.indianConnections.first.nativeScript} (${_wordOfTheDay.indianConnections.first.relationType.label})',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sageGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Read Full Entry Link
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WordDetailsScreen(
                      initialEntry: _wordOfTheDay,
                      dictionaryService: widget.dictionaryService,
                      storageService: widget.storageService,
                      audioService: widget.audioService,
                      onAskAi: widget.onAskAi,
                      onSelectWord: (w) => _openWord(w),
                    ),
                  ),
                ).then((_) => _loadState());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Examine full etymology & usage',
                    style: AppTypography.sansBody(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.terracotta,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.terracotta,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAskGarudaBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceSand,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.terracottaSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: AppColors.terracotta,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask Garuda',
                    style: AppTypography.serifHeading(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Words are only the beginning.',
                    style: AppTypography.sansLabel(
                      fontSize: 11,
                      color: AppColors.warmGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Explore etymology, contrast subtle distinctions between words, or refine your prose with an AI companion dedicated strictly to language.',
            style: AppTypography.sansBody(
              fontSize: 13.5,
              color: AppColors.inkLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(3); // 3 is Ask Garuda tab
              }
            },
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
            label: const Text('Start an Inquiry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.terracotta,
              side: const BorderSide(color: AppColors.terracottaBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuratedCollectionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CURATED COLLECTIONS',
              style: AppTypography.sansLabel(
                fontSize: 11,
                color: AppColors.warmGray,
                letterSpacing: 0.6,
              ),
            ),
            TextButton(
              onPressed: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(1); // 1 is Explore tab
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.terracotta,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('View all', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: curatedCollections.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final col = curatedCollections[index];
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CollectionDetailScreen(
                        collection: col,
                        dictionaryService: widget.dictionaryService,
                        storageService: widget.storageService,
                        audioService: widget.audioService,
                        onAskAi: widget.onAskAi,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(col.icon, size: 22, color: AppColors.terracotta),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSand,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              col.tag,
                              style: AppTypography.sansLabel(fontSize: 10, color: AppColors.warmGray),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            col.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.serifHeading(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            col.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.sansBody(fontSize: 11.5, color: AppColors.warmGray),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearchesSection() {
    final list = _recentSearches.isNotEmpty
        ? _recentSearches.take(6).toList()
        : ['juggernaut', 'avatar', 'brother', 'petrichor', 'ineffable', 'solitude'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _recentSearches.isNotEmpty ? 'RECENTLY CONSULTED' : 'RECOMMENDED INQUIRIES',
          style: AppTypography.sansLabel(
            fontSize: 11,
            color: AppColors.warmGray,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((word) {
            return ActionChip(
              backgroundColor: AppColors.surface,
              side: const BorderSide(color: AppColors.border),
              label: Text(
                word,
                style: AppTypography.sansBody(fontSize: 13, color: AppColors.deepInk),
              ),
              onPressed: () => _openWord(word),
            );
          }).toList(),
        ),
      ],
    );
  }
}
