import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'cloud_arabic_tts_service_interface.dart';

@JS('vocalLensAudio.playArabicText')
external void _jsPlayArabic(
  JSString text,
  JSNumber rate,
  JSNumber pitch,
  JSString gender,
  JSFunction onStart,
  JSFunction onWord,
  JSFunction onEnd,
  JSFunction onError,
);

@JS('vocalLensAudio.pause')
external void _jsPause();

@JS('vocalLensAudio.resume')
external void _jsResume();

@JS('vocalLensAudio.stop')
external void _jsStop();

@JS('vocalLensAudio.setRate')
external void _jsSetRate(JSNumber rate);

@JS('vocalLensAudio.setVolume')
external void _jsSetVolume(JSNumber volume);

class CloudArabicTtsService implements CloudArabicTtsServiceInterface {
  @override
  bool get isSupported => true;

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
    try {
      final jsOnStart = (() {
        onStart();
      }).toJS;

      final jsOnWord = ((JSString word) {
        onWord(word.toDart);
      }).toJS;

      final jsOnEnd = (() {
        onEnd();
      }).toJS;

      final jsOnError = ((JSString err) {
        onError(err.toDart);
      }).toJS;

      _jsPlayArabic(
        text.toJS,
        rate.toJS,
        pitch.toJS,
        gender.toJS,
        jsOnStart,
        jsOnWord,
        jsOnEnd,
        jsOnError,
      );
    } catch (e) {
      debugPrint("Error calling JS vocalLensAudio.playArabicText: $e");
      onError(e.toString());
    }
  }

  @override
  void pause() {
    try {
      _jsPause();
    } catch (e) {
      debugPrint("Error pausing JS audio: $e");
    }
  }

  @override
  void resume() {
    try {
      _jsResume();
    } catch (e) {
      debugPrint("Error resuming JS audio: $e");
    }
  }

  @override
  void stop() {
    try {
      _jsStop();
    } catch (e) {
      debugPrint("Error stopping JS audio: $e");
    }
  }

  @override
  void setRate(double rate) {
    try {
      _jsSetRate(rate.toJS);
    } catch (e) {
      debugPrint("Error setting JS audio rate: $e");
    }
  }

  @override
  void setVolume(double volume) {
    try {
      _jsSetVolume(volume.toJS);
    } catch (e) {
      debugPrint("Error setting JS audio volume: $e");
    }
  }
}
