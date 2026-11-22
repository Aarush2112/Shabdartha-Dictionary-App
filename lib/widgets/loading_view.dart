import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';

class LoadingView extends StatelessWidget {
  final String message;

  const LoadingView({
    super.key,
    this.message = 'Consulting lexicon...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.terracotta),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTypography.sansLabel(
              fontSize: 13,
              color: AppColors.warmGray,
            ),
          ),
        ],
      ),
    );
  }
}
