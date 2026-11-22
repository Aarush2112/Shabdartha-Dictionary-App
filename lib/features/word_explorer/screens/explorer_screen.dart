import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/curated_collections.dart';
import '../../../models/collection_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import '../../search/screens/search_screen.dart';
import 'collection_detail_screen.dart';

/// Exhibition UI implementation for Explore (Curated Collections).
/// Matches the exact white exhibition canvas, high-contrast serif headlines,
/// and rounded art cards from the reference design.
class ExplorerScreen extends StatefulWidget {
  final DictionaryService dictionaryService;
  final StorageService storageService;
  final AudioService audioService;
  final Function(String prompt)? onAskAi;

  const ExplorerScreen({
    super.key,
    required this.dictionaryService,
    required this.storageService,
    required this.audioService,
    this.onAskAi,
  });

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _collectionImages = [
    'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=800',
    'https://images.unsplash.com/photo-1580136579312-94651dfd596d?w=800',
    'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
    'https://images.unsplash.com/photo-1582561424760-0321d75e81fa?w=800',
    'https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?w=800',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    );
  }

  void _openCollection(WordCollection collection) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CollectionDetailScreen(
          collection: collection,
          dictionaryService: widget.dictionaryService,
          storageService: widget.storageService,
          audioService: widget.audioService,
          onAskAi: widget.onAskAi,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Indic Roots', 'Cognates', 'Emotions', 'Rhetoric', 'Confused'];

    final filtered = curatedCollections.where((c) {
      final matchesSearch = _searchQuery.isEmpty ||
          c.title.toLowerCase().contains(_searchQuery) ||
          c.description.toLowerCase().contains(_searchQuery) ||
          c.wordList.any((w) => w.toLowerCase().contains(_searchQuery));

      if (!matchesSearch) return false;

      if (_selectedCategory == 'All') return true;
      if (_selectedCategory == 'Indic Roots') return c.tag.contains('loanwords');
      if (_selectedCategory == 'Cognates') return c.tag.contains('pie');
      if (_selectedCategory == 'Emotions') return c.tag.contains('emotions');
      if (_selectedCategory == 'Rhetoric') return c.tag.contains('writing') || c.tag.contains('powerful');
      if (_selectedCategory == 'Confused') return c.tag.contains('confused');
      return true;
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
              'Linguistic\nExhibitions...',
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

            const SizedBox(height: 22),

            // 4. Horizontal Category Filter Pills
            _buildCategoryPills(categories),

            const SizedBox(height: 28),

            // 5. Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Folios',
                  style: AppTypography.serifHeading(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${filtered.length} Collections',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8E8E93),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 6. Exhibition Cards List (Matching "Michael Angelo's" & "Flower Poetry #1" style)
            ...filtered.asMap().entries.map((entry) {
              final index = entry.key;
              final collection = entry.value;
              final imageUrl = _collectionImages[index % _collectionImages.length];

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildExhibitionCard(collection, imageUrl),
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
            Icons.explore_rounded,
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
                  'शब्दार्थ • Curated Exhibitions',
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
                hintText: 'Filter exhibitions or themes...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: _searchQuery.isNotEmpty
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

  Widget _buildCategoryPills(List<String> categories) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => setState(() => _selectedCategory = cat),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : const Color(0xFFF2F2F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExhibitionCard(WordCollection collection, String imageUrl) {
    return InkWell(
      onTap: () => _openCollection(collection),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9FB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFEEEEF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arched top artwork frame
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
                      imageUrl,
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
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          collection.tag.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          '${collection.wordList.length} Curated Terms',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Text and Details
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.title,
                    style: AppTypography.editorialHeadline(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    collection.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF3C3C43),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Word Pills Preview
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: collection.wordList.take(4).map((w) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          w,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // Pill Action: Explore Exhibition ->
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Explore Exhibition',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF8E8E93)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
