import 'package:flutter/foundation.dart';

abstract class CloudArabicTtsServiceInterface {
  bool get isSupported;
  Future<void> play({
    required String text,
    required double rate,
    required double pitch,
    required String gender,
    required VoidCallback onStart,
    required ValueChanged<String> onWord,
    required VoidCallback onEnd,
    required ValueChanged<String> onError,
  });
  void pause();
  void resume();
  void stop();
  void setRate(double rate);
  void setVolume(double volume);
}
