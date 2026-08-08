import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();

  bool _initialized = false;

  Future<void> _initialize() async {
    if (_initialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.38);
    await _tts.setPitch(1.15);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);

    await _selectBestEnglishVoice();

    _tts.setErrorHandler((message) {
      debugPrint('TTS error: $message');
    });

    _initialized = true;
  }

  Future<void> _selectBestEnglishVoice() async {
    try {
      final dynamic result = await _tts.getVoices;

      if (result is! List) return;

      final voices = result
          .whereType<Map>()
          .where((voice) {
        final locale =
            voice['locale']?.toString().toLowerCase() ?? '';

        return locale.startsWith('en-us');
      })
          .toList();

      if (voices.isEmpty) return;

      // Prefer an offline/local English voice when available.
      final selectedVoice = voices.firstWhere(
            (voice) {
          final name =
              voice['name']?.toString().toLowerCase() ?? '';

          return name.contains('female') ||
              name.contains('local') ||
              name.contains('network');
        },
        orElse: () => voices.first,
      );

      final name = selectedVoice['name']?.toString();
      final locale = selectedVoice['locale']?.toString();

      if (name == null || locale == null) return;

      await _tts.setVoice({
        'name': name,
        'locale': locale,
      });

      debugPrint('Selected TTS voice: $name, $locale');
    } catch (error) {
      debugPrint('Could not select TTS voice: $error');
    }
  }

  Future<bool> speak(String text) async {
    try {
      await _initialize();
      await _tts.stop();

      final result = await _tts.speak(text);

      return result == 1;
    } catch (error) {
      debugPrint('TTS exception: $error');
      return false;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}