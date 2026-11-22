import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class EtymologyCard extends StatelessWidget {
  final String? etymology;
  final String? origin;

  const EtymologyCard({
    super.key,
    this.etymology,
    this.origin,
  });

  @override
  Widget build(BuildContext context) {
    final hasContent = (etymology != null && etymology!.isNotEmpty) ||
        (origin != null && origin!.isNotEmpty);

    if (!hasContent) return const SizedBox.shrink();

    return Container(
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
            children: [
              const Icon(
                Icons.history_edu_outlined,
                size: 18,
                color: AppColors.terracotta,
              ),
              const SizedBox(width: 8),
              Text(
                'Etymology & Origin',
                style: AppTypography.serifHeading(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepInk,
                ),
              ),
            ],
          ),
          if (origin != null && origin!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              origin!,
              style: AppTypography.sansBody(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.terracottaDark,
              ),
            ),
          ],
          if (etymology != null && etymology!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              etymology!,
              style: AppTypography.sansBody(
                fontSize: 14,
                color: AppColors.inkLight,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
