import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 0, 36, 16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.obsidian,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDockItem(
                index: 0,
                icon: Icons.menu_book_outlined,
                activeIcon: Icons.menu_book_rounded,
                tooltip: 'Lexicon',
              ),
              _buildDockItem(
                index: 1,
                icon: Icons.explore_outlined,
                activeIcon: Icons.explore_rounded,
                tooltip: 'Explore',
              ),
              _buildDockItem(
                index: 2,
                icon: Icons.bookmark_border_rounded,
                activeIcon: Icons.bookmark_rounded,
                tooltip: 'Saved',
              ),
              _buildDockItem(
                index: 3,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome_rounded,
                tooltip: 'Ask Garuda',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDockItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String tooltip,
  }) {
    final isSelected = currentIndex == index;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? AppColors.parchment : Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isSelected ? 4 : 0,
                height: isSelected ? 4 : 0,
                decoration: const BoxDecoration(
                  color: AppColors.terracottaLight,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
