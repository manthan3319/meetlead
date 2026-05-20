import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  static final VoiceService _i = VoiceService._internal();
  factory VoiceService() => _i;
  VoiceService._internal();

  final stt.SpeechToText _stt = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<bool> init() async {
    if (_ready) return true;
    _ready = await _stt.initialize();
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.5);
    return _ready;
  }

  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> listen({required Function(String) onResult}) async {
    if (!_ready) await init();
    if (!_stt.isAvailable) return;
    await _stt.listen(
      onResult: (r) => onResult(r.recognizedWords),
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      localeId: 'en_IN',
    );
  }

  Future<void> stop() => _stt.stop();
  bool get isListening => _stt.isListening;

  Map<String, dynamic>? parseCommand(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('meeting') && (lower.contains('schedule') || lower.contains('book'))) {
      return {'intent': 'schedule_meeting', 'text': text};
    }
    if (lower.contains('lead') && (lower.contains('add') || lower.contains('create'))) {
      return {'intent': 'add_lead', 'text': text};
    }
    if (lower.contains('today') && lower.contains('meeting')) {
      return {'intent': 'today_meetings'};
    }
    if (lower.contains('follow')) {
      return {'intent': 'today_followups'};
    }
    return null;
  }
}
