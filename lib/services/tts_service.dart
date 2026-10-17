import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/voice_persona.dart';
import 'cloud_arabic_tts_service.dart';
import 'voice_catalog_service.dart';

enum TtsPlaybackState { stopped, playing, paused }

class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  final CloudArabicTtsService _cloudArabicTts = CloudArabicTtsService();
  final VoiceCatalogService _catalog = VoiceCatalogService();
  bool _isUsingCloudArabicTts = false;

  TtsPlaybackState _state = TtsPlaybackState.stopped;
  TtsPlaybackState get state => _state;
  bool get isPlaying => _state == TtsPlaybackState.playing;
  bool get isPaused => _state == TtsPlaybackState.paused;
  bool get isStopped => _state == TtsPlaybackState.stopped;

  List<Map<String, String>> get allVoices => _catalog.allVoices;
  List<Map<String, String>> get maleVoices => _catalog.maleVoices;
  List<Map<String, String>> get femaleVoices => _catalog.femaleVoices;
  List<Map<String, String>> get arabicVoices => _catalog.arabicVoices;
  bool get hasGenderData => _catalog.hasGenderData;

  Map<String, String>? _selectedSystemVoice;
  Map<String, String>? get selectedSystemVoice => _selectedSystemVoice;

  bool _isArabicMode = false;
  bool get isArabicMode => _isArabicMode;

  VoicePersona _currentPersona = VoicePersona.englishPersonas[0];
  VoicePersona get currentPersona => _currentPersona;

  double _pitch = 0.94;
  double get pitch => _pitch;

  double _rate = 1.00;
  double get rate => _rate;
  bool _userHasSetRate = false; // true once user explicitly picks a speed

  // Android TTS engines on many devices treat 0.5 as "normal" speed.
  // This scale factor maps the user-facing rate (1.0 = natural) to the
  // correct engine value so the UI and audio stay in sync.
  static const double _kEngineRateScale = 0.5;
  double get _engineRate => (_rate * _kEngineRateScale).clamp(0.1, 5.0);

  double _volume = 1.0;
  double get volume => _volume;

  String _currentLanguage = 'en-US';
  String get currentLanguage => _currentLanguage;

  List<String> _languages = [];
  List<String> get languages => _languages;

  int _currentWordStart = 0;
  int _currentWordEnd = 0;
  String _currentSpokenWord = '';
  String _lastSpokenText = '';
  int get currentWordStart => _currentWordStart;
  int get currentWordEnd => _currentWordEnd;
  String get currentSpokenWord => _currentSpokenWord;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static bool isArabicString(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
  }

  void setArabicMode(bool arabic) {
    _isArabicMode = arabic;
    if (_isArabicMode) {
      _currentLanguage = 'ar-SA';
      _currentPersona = VoicePersona.arabicPersonas[0];
    } else {
      _currentLanguage = 'en-US';
      _currentPersona = VoicePersona.englishPersonas[0];
    }
    applyPersona(_currentPersona);
    notifyListeners();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts.setStartHandler(() {
        _state = TtsPlaybackState.playing;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _state = TtsPlaybackState.stopped;
        _currentSpokenWord = '';
        _currentWordStart = 0;
        _currentWordEnd = 0;
        notifyListeners();
      });

      _flutterTts.setCancelHandler(() {
        _state = TtsPlaybackState.stopped;
        _currentSpokenWord = '';
        notifyListeners();
      });

      _flutterTts.setPauseHandler(() {
        _state = TtsPlaybackState.paused;
        notifyListeners();
      });

      _flutterTts.setContinueHandler(() {
        _state = TtsPlaybackState.playing;
        notifyListeners();
      });

      _flutterTts.setProgressHandler((text, start, end, word) {
        _currentWordStart = start;
        _currentWordEnd = end;
        _currentSpokenWord = word;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((message) {
        debugPrint("FlutterTTS Error: $message");
        _state = TtsPlaybackState.stopped;
        notifyListeners();
      });

      dynamic langs = await _flutterTts.getLanguages;
      if (langs is List) {
        _languages = langs.map((e) => e.toString()).toList();
      }

      for (int i = 0; i < 8; i++) {
        await _catalog.loadAndCategorize(_flutterTts);
        if (!_catalog.isEmpty) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 250));
      }

      await applyPersona(_currentPersona);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing FlutterTts: $e");
    }
  }

  Future<void> refreshVoices() async {
    await _catalog.loadAndCategorize(_flutterTts);
    notifyListeners();
  }

  Future<void> applyPersona(VoicePersona persona) async {
    _currentPersona = persona;
    _pitch = persona.pitch;
    // Only use persona default rate if the user hasn't explicitly chosen a speed.
    // This preserves the user's speed selection across persona and voice changes.
    if (!_userHasSetRate) {
      _rate = persona.rate;
    }
    _currentLanguage = persona.language == PersonaLanguage.arabic ? 'ar-SA' : 'en-US';

    if (_catalog.isEmpty) {
      await _catalog.loadAndCategorize(_flutterTts);
    }

    final bestMatch = _catalog.findBestMatch(persona);

    if (bestMatch != null) {
      _selectedSystemVoice = bestMatch;
      try {
        await _flutterTts.setVoice({
          'name': bestMatch['name']!,
          'locale': bestMatch['locale']!,
        });
      } catch (e) {
        debugPrint("applyPersona setVoice error: $e");
      }
    } else {
      _selectedSystemVoice = null;
    }

    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_engineRate);
    await _flutterTts.setVolume(_volume);

    notifyListeners();
  }

  Future<void> setSystemVoice(Map<String, String> voice) async {
    _selectedSystemVoice = voice;
    final nameLower = voice['name']!.toLowerCase();

    if (nameLower.contains('female') || nameLower.contains('zira') || nameLower.contains('zeina')) {
      _pitch = 1.02;
    } else if (nameLower.contains('male') || nameLower.contains('david') || nameLower.contains('tarik')) {
      _pitch = 0.96;
    } else {
      _pitch = 1.00;
    }

    try {
      await _flutterTts.setVoice({
        'name': voice['name']!,
        'locale': voice['locale']!,
      });
      if (voice['locale'] != null && voice['locale']!.isNotEmpty) {
        await _flutterTts.setLanguage(voice['locale']!);
        _currentLanguage = voice['locale']!;
      }
    } catch (e) {
      debugPrint("setSystemVoice error: $e");
    }

    await _flutterTts.setPitch(_pitch);
    notifyListeners();
  }

  Future<void> setPitch(double val) async {
    _pitch = val;
    await _flutterTts.setPitch(_pitch);
    notifyListeners();
  }

  Future<void> setRate(double val) async {
    _rate = val;
    _userHasSetRate = true; // user explicitly chose this speed — preserve it
    if (_isUsingCloudArabicTts) {
      _cloudArabicTts.setRate(_rate);
    }
    await _flutterTts.setSpeechRate(_engineRate);
    
    // If we're currently playing, apply the speed change immediately
    // by stopping and restarting from the current word.
    if (_state == TtsPlaybackState.playing && _lastSpokenText.isNotEmpty) {
      if (_isUsingCloudArabicTts) {
        // Cloud service handles its own rate, but we can restart it
        _cloudArabicTts.stop();
        await speak(_lastSpokenText.substring(_currentWordStart));
      } else {
        await _flutterTts.stop();
        // A small delay ensures the engine has fully stopped before restarting
        await Future.delayed(const Duration(milliseconds: 50));
        await speak(_lastSpokenText.substring(_currentWordStart));
      }
    }
    
    notifyListeners();
  }

  Future<void> setVolume(double val) async {
    _volume = val;
    if (_isUsingCloudArabicTts) {
      _cloudArabicTts.setVolume(_volume);
    }
    await _flutterTts.setVolume(_volume);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _currentLanguage = lang;
    await _flutterTts.setLanguage(lang);
    notifyListeners();
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;

    // Only reset the start index if we are starting a completely new text
    // (not just resuming from a speed change slice)
    if (!_lastSpokenText.endsWith(text)) {
      _currentWordStart = 0;
    }
    _lastSpokenText = text;

    await stop();
    await Future.delayed(const Duration(milliseconds: 60));

    if (_catalog.isEmpty) {
      await _catalog.loadAndCategorize(_flutterTts);
    }

    final hasArabic = isArabicString(text) || _currentPersona.language == PersonaLanguage.arabic;

    // The cloud Arabic engine is a JS hook that only exists on the web.
    // On native platforms we must fall through to FlutterTTS even when no
    // Arabic voice is listed, otherwise nothing would play at all.
    if (hasArabic && _catalog.arabicVoices.isEmpty && kIsWeb && _cloudArabicTts.isSupported) {
      _isUsingCloudArabicTts = true;
      _state = TtsPlaybackState.playing;
      notifyListeners();

      final genderString = _currentPersona.gender == VoiceGender.male
          ? 'male'
          : (_currentPersona.gender == VoiceGender.female ? 'female' : 'neutral');

      await _cloudArabicTts.play(
        text: text,
        rate: _rate,
        pitch: _pitch,
        gender: genderString,
        onStart: () {
          _state = TtsPlaybackState.playing;
          notifyListeners();
        },
        onWord: (word) {
          _currentSpokenWord = word;
          notifyListeners();
        },
        onEnd: () {
          _state = TtsPlaybackState.stopped;
          _currentSpokenWord = '';
          _isUsingCloudArabicTts = false;
          notifyListeners();
        },
        onError: (err) {
          debugPrint("Cloud Arabic TTS playback notice: $err");
          _state = TtsPlaybackState.stopped;
          _isUsingCloudArabicTts = false;
          notifyListeners();
        },
      );
      return;
    }

    _isUsingCloudArabicTts = false;
    final targetLang = hasArabic ? 'ar-SA' : _currentLanguage;

    try {
      await _flutterTts.setLanguage(targetLang);
    } catch (_) {}

    if (_selectedSystemVoice == null) {
      await applyPersona(_currentPersona);
    }

    Map<String, String>? voiceToApply = _selectedSystemVoice;
    if (hasArabic && _catalog.arabicVoices.isNotEmpty) {
      final isFemale = _currentPersona.gender == VoiceGender.female;
      voiceToApply = _catalog.arabicVoices.firstWhere(
        (v) => isFemale
            ? v['name']!.toLowerCase().contains('female') || v['name']!.toLowerCase().contains('zeina')
            : v['name']!.toLowerCase().contains('male') || v['name']!.toLowerCase().contains('tarik'),
        orElse: () => _catalog.arabicVoices.first,
      );
    }

    if (voiceToApply != null) {
      try {
        await _flutterTts.setVoice({
          'name': voiceToApply['name']!,
          'locale': voiceToApply['locale']!,
        });
      } catch (e) {
        debugPrint("Error applying voice in speak(): $e");
      }
    }

    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_engineRate);
    await _flutterTts.setVolume(_volume);

    _state = TtsPlaybackState.playing;
    notifyListeners();

    await _flutterTts.speak(text);
  }

  Future<void> pause() async {
    if (_isUsingCloudArabicTts) {
      _cloudArabicTts.pause();
    } else {
      await _flutterTts.pause();
    }
    _state = TtsPlaybackState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_isUsingCloudArabicTts) {
      _cloudArabicTts.resume();
    }
    _state = TtsPlaybackState.playing;
    notifyListeners();
  }

  Future<void> stop() async {
    if (_isUsingCloudArabicTts) {
      _cloudArabicTts.stop();
      _isUsingCloudArabicTts = false;
    }
    await _flutterTts.stop();
    _state = TtsPlaybackState.stopped;
    _currentSpokenWord = '';
    _currentWordStart = 0;
    _currentWordEnd = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}
