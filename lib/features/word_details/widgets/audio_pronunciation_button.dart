import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/audio_service.dart';

class AudioPronunciationButton extends StatefulWidget {
  final String? audioUrl;
  final AudioService audioService;

  const AudioPronunciationButton({
    super.key,
    required this.audioUrl,
    required this.audioService,
  });

  @override
  State<AudioPronunciationButton> createState() => _AudioPronunciationButtonState();
}

class _AudioPronunciationButtonState extends State<AudioPronunciationButton> {
  bool _isLoading = false;

  bool get _hasAudio => widget.audioUrl != null && widget.audioUrl!.trim().isNotEmpty;

  Future<void> _handlePlay() async {
    if (!_hasAudio) return;

    final isCurrentlyPlaying = widget.audioService.isUrlPlaying(widget.audioUrl);
    if (isCurrentlyPlaying) {
      await widget.audioService.stop();
      return;
    }

    setState(() => _isLoading = true);

    await widget.audioService.playPronunciation(
      widget.audioUrl!,
      onStart: () {
        if (mounted) setState(() => _isLoading = false);
      },
      onComplete: () {
        if (mounted) setState(() => _isLoading = false);
      },
      onError: (err) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: AppColors.deepInk,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAudio) {
      return const SizedBox.shrink();
    }

    return ListenableBuilder(
      listenable: widget.audioService,
      builder: (context, _) {
        final isPlaying = widget.audioService.isUrlPlaying(widget.audioUrl);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handlePlay,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isPlaying ? AppColors.terracottaSurface : AppColors.surfaceSand,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isPlaying ? AppColors.terracottaBorder : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.terracotta),
                      ),
                    )
                  else
                    Icon(
                      isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                      size: 16,
                      color: isPlaying ? AppColors.terracotta : AppColors.deepInk,
                    ),
                  const SizedBox(width: 5),
                  Text(
                    isPlaying ? 'Playing' : 'Listen',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isPlaying ? AppColors.terracotta : AppColors.deepInk,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
