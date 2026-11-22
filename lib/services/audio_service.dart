import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService extends ChangeNotifier {
  AudioPlayer? _player;
  bool _isPlaying = false;
  String? _currentlyPlayingUrl;
  StreamSubscription? _completeSubscription;

  bool get isPlaying => _isPlaying;
  String? get currentlyPlayingUrl => _currentlyPlayingUrl;

  AudioPlayer get player {
    if (_player == null) {
      _player = AudioPlayer();
      _completeSubscription = _player!.onPlayerComplete.listen((_) {
        _isPlaying = false;
        _currentlyPlayingUrl = null;
        notifyListeners();
      });
    }
    return _player!;
  }

  bool isUrlPlaying(String? url) {
    if (url == null || !_isPlaying || _currentlyPlayingUrl == null) return false;
    var clean = url.trim();
    if (clean.startsWith('//')) clean = 'https:$clean';
    return _currentlyPlayingUrl == clean;
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

      var url = audioUrl.trim();
      if (url.startsWith('//')) {
        url = 'https:$url';
      }

      _isPlaying = true;
      _currentlyPlayingUrl = url;
      notifyListeners();
      onStart?.call();

      await player.play(UrlSource(url));
    } catch (e) {
      _isPlaying = false;
      _currentlyPlayingUrl = null;
      notifyListeners();
      onError?.call('Audio playback unavailable on this device: ${e.toString()}');
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
    _isPlaying = false;
    _currentlyPlayingUrl = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _completeSubscription?.cancel();
    _player?.dispose();
    _player = null;
    super.dispose();
  }
}
