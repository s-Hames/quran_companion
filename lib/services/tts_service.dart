import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsPlaybackState { stopped, playing, paused }

class TtsService {
  final FlutterTts _flutterTts;
  TtsPlaybackState _state = TtsPlaybackState.stopped;
  final ValueNotifier<TtsPlaybackState> stateNotifier =
      ValueNotifier(TtsPlaybackState.stopped);
  final ValueNotifier<String?> errorNotifier = ValueNotifier(null);

  TtsService({FlutterTts? tts}) : _flutterTts = tts ?? FlutterTts() {
    _initTts();
  }

  void _initTts() {
    try {
      _flutterTts.setStartHandler(() {
        _state = TtsPlaybackState.playing;
        stateNotifier.value = TtsPlaybackState.playing;
      });

      _flutterTts.setCompletionHandler(() {
        _state = TtsPlaybackState.stopped;
        stateNotifier.value = TtsPlaybackState.stopped;
      });

      _flutterTts.setCancelHandler(() {
        _state = TtsPlaybackState.stopped;
        stateNotifier.value = TtsPlaybackState.stopped;
      });

      _flutterTts.setErrorHandler((dynamic message) {
        debugPrint('TTS Error: $message');
        _state = TtsPlaybackState.stopped;
        stateNotifier.value = TtsPlaybackState.stopped;

        final errStr = message.toString();
        if (errStr.contains('-7') ||
            errStr.contains('timeout') ||
            errStr.contains('network')) {
          errorNotifier.value = 'urdu_voice_not_installed';
        } else {
          errorNotifier.value = errStr;
        }
      });
    } catch (e) {
      debugPrint('TTS initialization warning: $e');
    }
  }

  bool get isPlaying => _state == TtsPlaybackState.playing;

  Future<void> speak(String text, {required bool isUrdu}) async {
    final cleanText = text
        .replaceAll(RegExp(r'[*#_`~]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (cleanText.isEmpty) return;

    try {
      if (isPlaying) {
        await stop();
      }

      errorNotifier.value = null;

      if (isUrdu) {
        String selectedLang = 'ur-PK';
        // Check which Urdu locale is supported on the device
        for (final candidate in ['ur-PK', 'ur_PK', 'ur-IN', 'ur_IN', 'ur']) {
          final isAvail = await _flutterTts.isLanguageAvailable(candidate);
          if (isAvail == true || isAvail == 1) {
            selectedLang = candidate;
            break;
          }
        }
        await _flutterTts.setLanguage(selectedLang);
        await _flutterTts.setSpeechRate(0.42);
      } else {
        await _flutterTts.setLanguage('en-US');
        await _flutterTts.setSpeechRate(0.48);
      }

      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      await _flutterTts.speak(cleanText);
    } catch (e) {
      debugPrint('TTS speak error: $e');
      _state = TtsPlaybackState.stopped;
      stateNotifier.value = TtsPlaybackState.stopped;
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('TTS stop error: $e');
    } finally {
      _state = TtsPlaybackState.stopped;
      stateNotifier.value = TtsPlaybackState.stopped;
    }
  }

  void dispose() {
    try {
      _flutterTts.stop();
    } catch (_) {}
    stateNotifier.dispose();
    errorNotifier.dispose();
  }
}
