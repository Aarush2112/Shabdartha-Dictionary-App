import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  AudioPlayer? _player;
  bool _isPlaying = false;
  String? _currentlyPlayingUrl;

  bool get isPlaying => _isPlaying;
  String? get currentlyPlayingUrl => _currentlyPlayingUrl;

  AudioPlayer get player {
    _player ??= AudioPlayer();
    return _player!;
  }

  Future<void> playPronunciation(
    String audioUrl, {
    VoidCallback? onStart,
    VoidCallback? onComplete,
    Function(String error)? onError,
  }) async {
    try {
      if (_isPlaying) {
        await stop();
      }

      // Format URL if protocol is relative (e.g. "//ssl.gstatic.com/...")
      var url = audioUrl.trim();
      if (url.startsWith('//')) {
        url = 'https:$url';
      }

      _isPlaying = true;
      _currentlyPlayingUrl = url;
      onStart?.call();

      player.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _currentlyPlayingUrl = null;
        onComplete?.call();
      });

      await player.play(UrlSource(url));
    } catch (e) {
      _isPlaying = false;
      _currentlyPlayingUrl = null;
      onError?.call('Could not play audio: ${e.toString()}');
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
    _isPlaying = false;
    _currentlyPlayingUrl = null;
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }
}
