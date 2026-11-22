import 'package:flutter/material.dart';
import '../core/theme/app_typography.dart';
import '../data/curated_words.dart';
import '../models/word_model.dart';

/// Screen 1 implementation: Full-bleed classical artwork story mode.
/// Matches the leftmost phone in the exhibition design reference.
class StoryOverlayScreen extends StatefulWidget {
  final Function(WordEntry word)? onOpenWord;

  const StoryOverlayScreen({super.key, this.onOpenWord});

  @override
  State<StoryOverlayScreen> createState() => _StoryOverlayScreenState();
}

class _StoryOverlayScreenState extends State<StoryOverlayScreen> {
  int _currentIndex = 0;

  final List<String> _storyImages = [
    'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?w=800',
    'https://images.unsplash.com/photo-1582561424760-0321d75e81fa?w=800',
    'https://images.unsplash.com/photo-1578301978693-85fa9c0320b9?w=800',
    'https://images.unsplash.com/photo-1580136579312-94651dfd596d?w=800',
    'https://images.unsplash.com/photo-1577083552431-6e5fd01aa342?w=800',
  ];

  void _next() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % curatedWordEntries.length;
    });
  }

  void _prev() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + curatedWordEntries.length) % curatedWordEntries.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = curatedWordEntries[_currentIndex];
    final imageUrl = _storyImages[_currentIndex % _storyImages.length];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -200) {
              _next();
            } else if (details.primaryVelocity! > 200) {
              _prev();
            }
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-bleed Artwork Background
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2C1B14), Color(0xFF161513)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // 2. Subtle Dark Vignette & Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 3. Top Bar with Folio Indicator and Close Button
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'FOLIO ${_currentIndex + 1} OF ${curatedWordEntries.length}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // 4. Bottom Content (Screen 1 Typography & Controls)
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'A Living World of\nThe Greatest\nVocabulary',
                    style: AppTypography.editorialHeadline(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    entry.editorialInsight ?? entry.primaryDefinition,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Controls Row: Circular Buttons < > and Details Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Left circular button [ < ]
                          InkWell(
                            onTap: _prev,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right circular button [ > ]
                          InkWell(
                            onTap: _next,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),

                      // Details pill button
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onOpenWord?.call(entry);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Explore',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 15, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
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
