import 'package:flutter/foundation.dart';
import 'cloud_arabic_tts_service_interface.dart';

class CloudArabicTtsService implements CloudArabicTtsServiceInterface {
  @override
  bool get isSupported => false;

  @override
  Future<void> play({
    required String text,
    required double rate,
    required double pitch,
    required String gender,
    required VoidCallback onStart,
    required ValueChanged<String> onWord,
    required VoidCallback onEnd,
    required ValueChanged<String> onError,
  }) async {
    // Native platforms (Android/iOS) utilize the system TTS engine directly
    debugPrint("CloudArabicTtsService: Native platform handles TTS via FlutterTTS");
    onEnd();
  }

  @override
  void pause() {}

  @override
  void resume() {}

  @override
  void stop() {}

  @override
  void setRate(double rate) {}

  @override
  void setVolume(double volume) {}
}
