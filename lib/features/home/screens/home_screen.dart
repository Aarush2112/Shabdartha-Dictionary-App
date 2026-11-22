import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/curated_collections.dart';
import '../../../models/word_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/story_overlay_screen.dart';
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

  final String _artworkFresco = 'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=600';
  final String _artworkFloral = 'https://images.unsplash.com/photo-1580136579312-94651dfd596d?w=600';
  final String _artworkColonnade = 'https://images.unsplash.com/photo-1582561424760-0321d75e81fa?w=800';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    _wordOfTheDay = widget.dictionaryService.getWordOfTheDay();
    _isWotdSaved = widget.storageService.isWordSaved(_wordOfTheDay.word);
    setState(() {});
  }

  Future<void> _toggleWotdSave() async {
    if (_isWotdSaved) {
      await widget.storageService.removeSavedWord(_wordOfTheDay.word);
      setState(() => _isWotdSaved = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed "${_wordOfTheDay.word}" from saved collection.'),
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
            content: Text('Saved "${_wordOfTheDay.word}" to vocabulary library.'),
            backgroundColor: AppColors.sageGreen,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _openWord(WordEntry entry) {
    widget.storageService.addRecentSearch(entry.word);
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

  void _openStoryMode() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, anim, _) => StoryOverlayScreen(
          onOpenWord: (entry) => _openWord(entry),
        ),
        transitionsBuilder: (context, anim, _, child) => FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.obsidian,
          onRefresh: () async => _loadState(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 110.0),
            children: [
              // 1. Top Bar (Exact layout: Grid Button, Location/Edition, Avatar)
              _buildTopBar(),

              const SizedBox(height: 24),

              // 2. High-Contrast Bold Serif Headline ("Good Morning, Brooklyn...")
              Text(
                '${_getTimeGreeting()}\nScholar...',
                style: AppTypography.editorialHeadline(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.deepInk,
                  height: 1.15,
                ),
              ),

              const SizedBox(height: 20),

              // 3. Pill Search Field ("Search exhibition, event, or artwork...")
              _buildPillSearchBar(),

              const SizedBox(height: 28),

              // 4. Circular Category Icons Row ("Exhibition", "Event", "Artwork", "Artist")
              _buildCircularCategoriesRow(),

              const SizedBox(height: 32),

              // 5. Exhibition Section Header + 2-Column Cards
              _buildExhibitionSection(),

              const SizedBox(height: 32),

              // 6. Masterpiece of the Day (Screen 3 inspired Cathedral Arch frame)
              _buildMasterpieceCard(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Black circular grid button (Story Mode)
        InkWell(
          onTap: _openStoryMode,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              size: 20,
              color: Colors.white,
            ),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.sageGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'शब्दार्थ • Garuda × Rishihood',
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

        // Right: Clean Search Trigger (NO person icon!)
        InkWell(
          onTap: _openSearch,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F2F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_rounded,
              size: 20,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillSearchBar() {
    return InkWell(
      onTap: _openSearch,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F5),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: Color(0xFF8E8E93),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Search words, roots, or Ask Garuda...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularCategoriesRow() {
    final categories = [
      {'title': 'Indic Roots', 'icon': Icons.temple_hindu_outlined, 'index': 0},
      {'title': 'Cognates', 'icon': Icons.account_tree_outlined, 'index': 1},
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
            padding: const EdgeInsets.only(right: 20.0),
            child: InkWell(
              onTap: () => _openCollection(idx),
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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

  Widget _buildExhibitionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exhibition',
              style: AppTypography.serifHeading(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            InkWell(
              onTap: () {
                if (widget.onNavigateToTab != null) {
                  widget.onNavigateToTab!(1); // Go to Explore
                }
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF8E8E93),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2-Column Cards (Exact match to "Michael Angelo's" and "Flower Poetry #1")
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card 1: Words of Indian Origin
            Expanded(
              child: _buildExhibitionCard(
                imageUrl: _artworkFresco,
                title: 'Words of Indian Origin',
                subtitle: '10 Terms • Sanskrit & Odia',
                onTap: () => _openCollection(0),
              ),
            ),
            const SizedBox(width: 14),
            // Card 2: Ancient PIE Cognates
            Expanded(
              child: _buildExhibitionCard(
                imageUrl: _artworkFloral,
                title: 'Ancient PIE Cognates',
                subtitle: '6 Terms • Shared Roots',
                onTap: () => _openCollection(1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExhibitionCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 0.85,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFEBEBF0),
                  child: const Center(
                    child: Icon(Icons.palette_outlined, size: 28, color: Color(0xFF8E8E93)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.serifHeading(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterpieceCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEEEEF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arched image frame (Cathedral arch matching Screen 3)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    _artworkColonnade,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.black12),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: InkWell(
                      onTap: _toggleWotdSave,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isWotdSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 18,
                          color: _isWotdSaved ? AppColors.antiqueGoldLight : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'MASTERPIECE OF THE DAY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _wordOfTheDay.word,
                      style: AppTypography.editorialHeadline(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
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
                    style: AppTypography.phonetic(fontSize: 13),
                  ),
                ],

                if (_wordOfTheDay.indianConnections.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    '${_wordOfTheDay.indianConnections.first.language}: ${_wordOfTheDay.indianConnections.first.nativeScript} (${_wordOfTheDay.indianConnections.first.relationType.label})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sageGreen,
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                Text(
                  _wordOfTheDay.primaryDefinition,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3C3C43),
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 18),

                // Pill Action Button: Details ->
                InkWell(
                  onTap: () => _openWord(_wordOfTheDay),
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
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
          ),
        ],
      ),
    );
  }
}
