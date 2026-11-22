import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/curated_words.dart';
import '../../../models/collection_model.dart';
import '../../../models/word_model.dart';
import '../../../services/audio_service.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/storage_service.dart';
import '../../word_details/screens/word_details_screen.dart';

class CollectionDetailScreen extends StatelessWidget {
  final WordCollection collection;
  final DictionaryService dictionaryService;
  final StorageService storageService;
  final AudioService audioService;
  final Function(String prompt)? onAskAi;

  const CollectionDetailScreen({
    super.key,
    required this.collection,
    required this.dictionaryService,
    required this.storageService,
    required this.audioService,
    this.onAskAi,
  });

  void _openWord(BuildContext context, String word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WordDetailsScreen(
          wordQuery: word,
          dictionaryService: dictionaryService,
          storageService: storageService,
          audioService: audioService,
          onAskAi: onAskAi,
          onSelectWord: (w) => _openWord(context, w),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.parchment,
      appBar: AppBar(
        title: Text(
          collection.title,
          style: AppTypography.serifHeading(fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceSand,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.terracottaSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.terracottaBorder),
                      ),
                      child: Icon(
                        collection.icon,
                        color: AppColors.terracotta,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.terracottaSurface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              collection.tag.toUpperCase(),
                              style: AppTypography.sansLabel(
                                fontSize: 10,
                                color: AppColors.terracottaDark,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            collection.subtitle,
                            style: AppTypography.serifHeading(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.deepInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  collection.description,
                  style: AppTypography.sansBody(
                    fontSize: 14,
                    color: AppColors.warmGray,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'CURATED VOCABULARY (${collection.wordList.length} WORDS)',
              style: AppTypography.sansLabel(
                fontSize: 11,
                color: AppColors.warmGray,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(height: 10),

          ...collection.wordList.map((word) {
            final curated = findCuratedWord(word);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                onTap: () => _openWord(context, word),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Row(
                  children: [
                    Text(
                      word,
                      style: AppTypography.serifHeading(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (curated?.phonetic != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        curated!.phonetic!,
                        style: AppTypography.phonetic(fontSize: 12),
                      ),
                    ],
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      curated?.primaryDefinition ?? 'Tap to examine comprehensive dictionary entry.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sansBody(
                        fontSize: 13,
                        color: AppColors.inkLight.withValues(alpha: 0.85),
                      ),
                    ),
                    if (curated != null && curated.indianConnections.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.sageGreenSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.sageGreenBorder),
                        ),
                        child: Text(
                          '${curated.indianConnections.first.language}: ${curated.indianConnections.first.nativeScript} (${curated.indianConnections.first.relationType.label})',
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
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.warmGray,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
