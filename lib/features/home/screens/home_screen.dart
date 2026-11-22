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
            backgroundColor: AppColors.obsidian,
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

  void _openCollection(int index) {
    if (index >= 0 && index < curatedCollections.length) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CollectionDetailScreen(
            collection: curatedCollections[index],
            dictionaryService: widget.dictionaryService,
            storageService: widget.storageService,
            audioService: widget.audioService,
            onAskAi: widget.onAskAi,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.terracotta,
          onRefresh: () async {
            _loadState();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 100.0),
            children: [
              // 1. Classical Museum Masthead
              _buildMasthead(),

              const SizedBox(height: 20),

              // 2. Editorial Serif Headline
              Text(
                'Curating the World\nof Words...',
                style: AppTypography.editorialHeadline(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepInk,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 18),

              // 3. Capsule Search Field
              _buildCapsuleSearchBar(),

              const SizedBox(height: 24),

              // 4. Circular Category Avatars (from reference image)
              _buildCircularCategoryRow(),

              const SizedBox(height: 28),

              // 5. Featured Masterpiece Folio (Word of the Day)
              _buildIlluminatedMasterpieceCard(),

              const SizedBox(height: 28),

              // 6. Curated Exhibitions & Folios Grid
              _buildCuratedFoliosSection(),

              const SizedBox(height: 24),

              // 7. "Ask Garuda" Literary Salon Entry
              _buildAskGarudaSalonCard(),

              const SizedBox(height: 24),

              // 8. Recent Searches Chips
              _buildRecentSearchesSection(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasthead() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.obsidian,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: AppColors.parchment,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.antiqueGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'GARUDA PRAKASHAN × RISHIHOOD',
                      style: AppTypography.sansLabel(
                        fontSize: 10,
                        color: AppColors.warmGray,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Garuda Lexicon • Edition I',
                  style: AppTypography.sansBody(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepInk,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceSand,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(
            child: Icon(
              Icons.auto_stories_rounded,
              size: 18,
              color: AppColors.terracotta,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCapsuleSearchBar() {
    return InkWell(
      onTap: _openSearch,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceSand,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: AppColors.warmGray),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search word, root, or phrase...',
                style: AppTypography.sansBody(
                  fontSize: 14,
                  color: AppColors.warmGray,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.obsidian,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'LOOKUP',
                style: AppTypography.sansLabel(
                  fontSize: 9.5,
                  color: AppColors.parchment,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularCategoryRow() {
    final categories = [
      {'title': 'Indic Roots', 'icon': Icons.temple_hindu_outlined, 'index': 0},
      {'title': 'PIE Cognates', 'icon': Icons.account_tree_outlined, 'index': 1},
      {'title': 'Emotions', 'icon': Icons.favorite_border_rounded, 'index': 2},
      {'title': 'Rhetoric', 'icon': Icons.menu_book_outlined, 'index': 3},
      {'title': 'Confused', 'icon': Icons.compare_arrows_rounded, 'index': 4},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: categories.map((cat) {
          final title = cat['title'] as String;
          final icon = cat['icon'] as IconData;
          final idx = cat['index'] as int;

          return Padding(
            padding: const EdgeInsets.only(right: 18.0),
            child: InkWell(
              onTap: () => _openCollection(idx),
              borderRadius: BorderRadius.circular(30),
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.obsidian,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: AppColors.parchment,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTypography.sansLabel(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.deepInk,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIlluminatedMasterpieceCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cathedral Arch Styled Header Plate
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.obsidian,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.antiqueGoldLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MASTERPIECE OF THE DAY',
                      style: AppTypography.sansLabel(
                        fontSize: 10.5,
                        color: AppColors.antiqueGoldLight,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isWotdSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: _isWotdSaved ? AppColors.antiqueGoldLight : Colors.white.withValues(alpha: 0.6),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Bookmark',
                  onPressed: _toggleWotdSave,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Word and Audio Pill Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        _wordOfTheDay.word,
                        style: AppTypography.editorialHeadline(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppColors.deepInk,
                        ),
                      ),
                    ),
                    if (_wordOfTheDay.audioUrl != null)
                      AudioPronunciationButton(
                        audioUrl: _wordOfTheDay.audioUrl,
                        audioService: widget.audioService,
                      ),
                  ],
                ),

                if (_wordOfTheDay.phonetic != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _wordOfTheDay.phonetic!,
                    style: AppTypography.phonetic(fontSize: 14),
                  ),
                ],

                const SizedBox(height: 14),

                // Part of Speech & Indic Tag
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSand,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _wordOfTheDay.primaryPartOfSpeech.toUpperCase(),
                        style: AppTypography.sansLabel(
                          fontSize: 10,
                          color: AppColors.deepInk,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (_wordOfTheDay.indianConnections.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreenSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.sageGreenBorder),
                        ),
                        child: Text(
                          '${_wordOfTheDay.indianConnections.first.language}: ${_wordOfTheDay.indianConnections.first.nativeScript} (${_wordOfTheDay.indianConnections.first.relationType.label})',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sageGreen,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Definition
                Text(
                  _wordOfTheDay.primaryDefinition,
                  style: AppTypography.sansBody(
                    fontSize: 15,
                    color: AppColors.deepInk,
                    height: 1.45,
                  ),
                ),

                // Editorial Insight Quote Box
                if (_wordOfTheDay.editorialInsight != null && _wordOfTheDay.editorialInsight!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSand.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(
                        left: BorderSide(color: AppColors.terracotta, width: 3),
                      ),
                    ),
                    child: Text(
                      '“${_wordOfTheDay.editorialInsight!}”',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: AppColors.inkLight.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 14),

                // Pill Action: Examine Folio ->
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
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSand,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Examine Folio',
                          style: AppTypography.sansBody(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepInk,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: AppColors.terracotta,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuratedFoliosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CURATED FOLIOS',
              style: AppTypography.sansLabel(
                fontSize: 11,
                color: AppColors.warmGray,
                letterSpacing: 1.0,
              ),
            ),
            InkWell(
              onTap: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(1); // Go to Explore
                }
              },
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: AppTypography.sansBody(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.terracotta,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.terracotta),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2-Column Aesthetic Cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (context, index) {
            final col = curatedCollections[index];
            final gradients = [
              AppColors.folioTerracotta,
              AppColors.folioIndigo,
              AppColors.folioEmerald,
              AppColors.folioBronze,
            ];

            return InkWell(
              onTap: () => _openCollection(index),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradients[index % gradients.length],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            col.icon,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${col.wordList.length} words',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          col.tag.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.antiqueGoldLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          col.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.serifHeading(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAskGarudaSalonCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.obsidian,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'The Literary Salon',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '“Words are only the beginning.”',
            style: AppTypography.editorialHeadline(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.parchment,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Inquire about semantic nuance, explore authentic Sanskrit and Hindi cognates, or refine your prose cadence with your dedicated language mentor.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              if (widget.onNavigateToTab != null) {
                widget.onNavigateToTab!(3); // Go to Ask Garuda
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter Salon',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.terracottaLight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          _recentSearches.isNotEmpty ? 'RECENTLY CONSULTED' : 'FEATURED INQUIRIES',
          style: AppTypography.sansLabel(
            fontSize: 11,
            color: AppColors.warmGray,
            letterSpacing: 1.0,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              label: Text(
                word,
                style: AppTypography.sansBody(fontSize: 12.5, color: AppColors.deepInk),
              ),
              onPressed: () => _openWord(word),
            );
          }).toList(),
        ),
      ],
    );
  }
}
