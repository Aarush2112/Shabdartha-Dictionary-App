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
  bool _isPlaying = false;
  bool _isLoading = false;

  bool get _hasAudio => widget.audioUrl != null && widget.audioUrl!.trim().isNotEmpty;

  Future<void> _handlePlay() async {
    if (!_hasAudio) return;

    if (_isPlaying) {
      await widget.audioService.stop();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await widget.audioService.playPronunciation(
      widget.audioUrl!,
      onStart: () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isPlaying = true;
          });
        }
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _isLoading = false;
          });
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _isLoading = false;
          });
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handlePlay,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _isPlaying ? AppColors.terracottaSurface : AppColors.surfaceSand,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPlaying ? AppColors.terracottaBorder : AppColors.border,
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
                  _isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                  size: 16,
                  color: _isPlaying ? AppColors.terracotta : AppColors.deepInk,
                ),
              const SizedBox(width: 5),
              Text(
                _isPlaying ? 'Playing' : 'Listen',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _isPlaying ? AppColors.terracotta : AppColors.deepInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
