import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/audio_message_model.dart';
import '../services/audio_service.dart';
import '../utils/exceptions.dart';

enum AudioPlayerState { stopped, playing, paused, loading }

class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  AudioPlayerState _playerState = AudioPlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _currentAudioId;
  bool _isRecording = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  AudioPlayerState get playerState => _playerState;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get currentAudioId => _currentAudioId;
  bool get isRecording => _isRecording;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get isPlaying => _playerState == AudioPlayerState.playing;
  bool get isPaused => _playerState == AudioPlayerState.paused;
  bool get isStopped => _playerState == AudioPlayerState.stopped;

  AudioProvider() {
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      switch (state) {
        case PlayerState.playing:
          _playerState = AudioPlayerState.playing;
          break;
        case PlayerState.paused:
          _playerState = AudioPlayerState.paused;
          break;
        case PlayerState.stopped:
          _playerState = AudioPlayerState.stopped;
          _currentPosition = Duration.zero;
          break;
        case PlayerState.completed:
          _playerState = AudioPlayerState.stopped;
          _currentPosition = Duration.zero;
          break;
        case PlayerState.disposed:
          _playerState = AudioPlayerState.stopped;
          break;
      }
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((Duration position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      _totalDuration = duration;
      notifyListeners();
    });
  }

  Future<void> playAudio(String audioUrl, String audioId) async {
    _setLoading(true);
    _clearError();

    try {
      if (_currentAudioId == audioId && isPaused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrl));
        _currentAudioId = audioId;
      }
    } catch (e) {
      _setError('Failed to play audio');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _setError('Failed to pause audio');
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _currentAudioId = null;
    } catch (e) {
      _setError('Failed to stop audio');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _setError('Failed to seek audio');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      _setError('Failed to set volume');
    }
  }

  Future<bool> startRecording() async {
    _setLoading(true);
    _clearError();

    try {
      final success = await AudioService.startRecording();
      _isRecording = success;
      notifyListeners();
      return success;
    } on AudioException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to start recording');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> stopRecording() async {
    _setLoading(true);
    _clearError();

    try {
      final audioPath = await AudioService.stopRecording();
      _isRecording = false;
      notifyListeners();
      return audioPath;
    } on AudioException catch (e) {
      _setError(e.message);
      _isRecording = false;
      notifyListeners();
      return null;
    } catch (e) {
      _setError('Failed to stop recording');
      _isRecording = false;
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadAudioMessage({
    required String appointmentId,
    required String senderId,
    required String audioPath,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await AudioService.uploadAudioMessage(
        appointmentId: appointmentId,
        senderId: senderId,
        audioPath: audioPath,
      );
      return true;
    } on AudioException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to upload audio message');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> generateTextToSpeech(String text) async {
    _setLoading(true);
    _clearError();

    try {
      final audioUrl = await AudioService.generateTextToSpeech(text);
      return audioUrl;
    } on AudioException catch (e) {
      _setError(e.message);
      return null;
    } catch (e) {
      _setError('Failed to generate text-to-speech');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}