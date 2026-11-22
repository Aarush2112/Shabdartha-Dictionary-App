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
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: Text(
          'Word Explorer',
          style: AppTypography.serifHeading(fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Intro Editorial Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceSand,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.explore_rounded,
                  size: 28,
                  color: AppColors.terracotta,
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
                        'Discover connections between Sanskrit roots, complex emotions, and the architecture of prose.',
                        style: AppTypography.sansBody(
                          fontSize: 13,
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

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'FEATURED COLLECTIONS',
              style: AppTypography.sansLabel(
                fontSize: 11,
                color: AppColors.warmGray,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),

          ...curatedCollections.map((collection) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
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
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.terracottaSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              collection.icon,
                              size: 20,
                              color: AppColors.terracotta,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSand,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${collection.wordList.length} words',
                              style: AppTypography.sansLabel(
                                fontSize: 11,
                                color: AppColors.warmGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        collection.title,
                        style: AppTypography.serifHeading(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        collection.subtitle,
                        style: AppTypography.sansBody(
                          fontSize: 13,
                          color: AppColors.warmGray,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Small preview of 3 words
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: collection.wordList.take(4).map((w) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSand.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Text(
                              w,
                              style: AppTypography.sansBody(
                                fontSize: 12,
                                color: AppColors.inkLight,
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
