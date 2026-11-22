import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/word_model.dart';

class IndianConnectionCard extends StatelessWidget {
  final List<IndianLanguageConnection> connections;

  const IndianConnectionCard({
    super.key,
    required this.connections,
  });

  @override
  Widget build(BuildContext context) {
    if (connections.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.sageGreenSurface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.sageGreenBorder),
              ),
              child: const Icon(
                Icons.temple_hindu_outlined,
                size: 16,
                color: AppColors.sageGreen,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Indian Linguistic Heritage',
              style: AppTypography.serifHeading(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.deepInk,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...connections.map((conn) => _buildConnectionItem(context, conn)),
      ],
    );
  }

  Widget _buildConnectionItem(BuildContext context, IndianLanguageConnection conn) {
    final isCognate = conn.relationType == IndianRelationType.cognate;
    final badgeBg = isCognate ? AppColors.surfaceSand : AppColors.sageGreenSurface;
    final badgeBorder = isCognate ? AppColors.border : AppColors.sageGreenBorder;
    final badgeColor = isCognate ? AppColors.inkLight : AppColors.sageGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Native script & transliteration
              Row(
                children: [
                  if (conn.nativeScript.isNotEmpty) ...[
                    Text(
                      conn.nativeScript,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (conn.transliteration.isNotEmpty)
                    Text(
                      conn.transliteration,
                      style: AppTypography.sansBody(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warmGray,
                      ),
                    ),
                ],
              ),
              // Academic classification badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeBorder),
                ),
                child: Text(
                  conn.relationType.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            conn.meaning,
            style: AppTypography.sansBody(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.deepInk,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSand.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AppColors.warmGray,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conn.academicNote,
                    style: AppTypography.sansBody(
                      fontSize: 12.5,
                      color: AppColors.warmGray,
                      height: 1.4,
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
