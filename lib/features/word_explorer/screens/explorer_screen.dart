import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/curated_collections.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import 'collection_detail_screen.dart';

class ExplorerScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final gradients = [
      AppColors.folioTerracotta,
      AppColors.folioIndigo,
      AppColors.folioEmerald,
      AppColors.folioBronze,
      AppColors.folioTerracotta,
    ];

    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: Text(
          'Linguistic Folios',
          style: AppTypography.editorialHeadline(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 100.0),
        children: [
          // Intro Editorial Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceSand,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.obsidian,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    size: 22,
                    color: AppColors.parchment,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Curated Linguistic Paths',
                        style: AppTypography.serifHeading(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepInk,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Discover the deep bridges between Vedic roots, delicate human emotions, and rhetorical precision.',
                        style: AppTypography.sansBody(
                          fontSize: 12.5,
                          color: AppColors.warmGray,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'CURATED EXHIBITIONS',
            style: AppTypography.sansLabel(
              fontSize: 11,
              color: AppColors.warmGray,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),

          ...curatedCollections.asMap().entries.map((entry) {
            final index = entry.key;
            final collection = entry.value;
            final gradient = gradients[index % gradients.length];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CollectionDetailScreen(
                        collection: collection,
                        dictionaryService: dictionaryService,
                        storageService: storageService,
                        audioService: audioService,
                        onAskAi: onAskAi,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(22),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              collection.icon,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${collection.wordList.length} curated terms',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        collection.tag.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.antiqueGoldLight,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.title,
                        style: AppTypography.editorialHeadline(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        collection.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Word chips preview
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: collection.wordList.take(5).map((w) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Text(
                              w,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
