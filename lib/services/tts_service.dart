import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/voice_persona.dart';

enum TtsPlaybackState {
  stopped,
  playing,
  paused,
}

class TtsService extends ChangeNotifier {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  TtsPlaybackState _state = TtsPlaybackState.stopped;
  TtsPlaybackState get state => _state;
  bool get isPlaying => _state == TtsPlaybackState.playing;
  bool get isPaused => _state == TtsPlaybackState.paused;
  bool get isStopped => _state == TtsPlaybackState.stopped;

  List<Map<String, String>> _allVoices = [];
  List<Map<String, String>> _maleVoices = [];
  List<Map<String, String>> _femaleVoices = [];

  List<Map<String, String>> get allVoices => _allVoices;
  List<Map<String, String>> get maleVoices => _maleVoices;
  List<Map<String, String>> get femaleVoices => _femaleVoices;

  Map<String, String>? _selectedSystemVoice;
  Map<String, String>? get selectedSystemVoice => _selectedSystemVoice;

  VoicePersona _currentPersona = VoicePersona.defaultPersonas[0];
  VoicePersona get currentPersona => _currentPersona;

  double _pitch = 0.70;
  double get pitch => _pitch;

  double _rate = 0.50;
  double get rate => _rate;

  double _volume = 1.0;
  double get volume => _volume;

  String _currentLanguage = 'en-US';
  String get currentLanguage => _currentLanguage;

  List<String> _languages = [];
  List<String> get languages => _languages;

  int _currentWordStart = 0;
  int _currentWordEnd = 0;
  String _currentSpokenWord = '';
  int get currentWordStart => _currentWordStart;
  int get currentWordEnd => _currentWordEnd;
  String get currentSpokenWord => _currentSpokenWord;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

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

      // Load languages
      dynamic langs = await _flutterTts.getLanguages;
      if (langs is List) {
        _languages = langs.map((e) => e.toString()).toList();
      }

      // Retry voice loading up to 8 times with delays because browser/OS voices load asynchronously
      for (int i = 0; i < 8; i++) {
        await _loadAndCategorizeVoices();
        if (_maleVoices.isNotEmpty || _femaleVoices.isNotEmpty) {
          break;
        }
        await Future.delayed(const Duration(milliseconds: 250));
      }

      // Apply initial persona
      await applyPersona(_currentPersona);

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error initializing FlutterTts: $e");
    }
  }

  Future<void> refreshVoices() async {
    await _loadAndCategorizeVoices();
    notifyListeners();
  }

  Future<void> _loadAndCategorizeVoices() async {
    try {
      dynamic voices = await _flutterTts.getVoices;
      if (voices is List && voices.isNotEmpty) {
        _allVoices = voices.map((v) {
          if (v is Map) {
            return {
              'name': v['name']?.toString() ?? 'Default Voice',
              'locale': v['locale']?.toString() ?? v['lang']?.toString() ?? 'en-US',
              'gender': v['gender']?.toString() ?? '',
            };
          }
          return {
            'name': v.toString(),
            'locale': 'en-US',
            'gender': '',
          };
        }).toList();

        // Categorize into Male and Female
        _maleVoices = [];
        _femaleVoices = [];

        final femaleKeywords = [
          'female',
          'woman',
          'zira',
          'google us english',
          'google uk english female',
          'susan',
          'samantha',
          'jenny',
          'karen',
          'victoria',
          'emma',
          'sophia',
          'eva',
          'hazel',
          'fiona',
          'catherine',
          'alice',
          'elena',
          'helena',
          'laura',
          'maria',
          'anna',
          'en-us-x-sfg#female',
          'en-us-x-tpd#female',
          'en-us-x-iol#female',
        ];

        final maleKeywords = [
          'male',
          'david',
          'mark',
          'google uk english male',
          'guy',
          'george',
          'brian',
          'oliver',
          'daniel',
          'richard',
          'alex',
          'james',
          'john',
          'tom',
          'en-us-x-sfg#male',
          'en-us-x-tpd#male',
          'en-us-x-iol#male',
        ];

        for (var voice in _allVoices) {
          final nameLower = voice['name']!.toLowerCase();
          final genderLower = voice['gender']!.toLowerCase();

          bool isMale = genderLower.contains('male') && !genderLower.contains('female');
          bool isFemale = genderLower.contains('female');

          if (!isMale && !isFemale) {
            if (femaleKeywords.any((k) => nameLower.contains(k))) {
              isFemale = true;
            } else if (maleKeywords.any((k) => nameLower.contains(k))) {
              isMale = true;
            }
          }

          if (isFemale) {
            _femaleVoices.add(voice);
          } else if (isMale) {
            _maleVoices.add(voice);
          } else {
            // Default fallback categorization based on common naming
            if (nameLower.contains('desktop') && !nameLower.contains('zira')) {
              _maleVoices.add(voice);
            }
          }
        }

        debugPrint("TtsService: Loaded ${_allVoices.length} voices (${_maleVoices.length} male, ${_femaleVoices.length} female)");
      }
    } catch (e) {
      debugPrint("Error fetching voices: $e");
    }
  }

  /// Sets one of the pre-tuned Voice Personas (Deep Male, Elegant Female, etc.)
  Future<void> applyPersona(VoicePersona persona) async {
    _currentPersona = persona;
    _pitch = persona.pitch;
    _rate = persona.rate;

    // Refresh voices if lists are currently empty
    if (_maleVoices.isEmpty && _femaleVoices.isEmpty) {
      await _loadAndCategorizeVoices();
    }

    Map<String, String>? bestMatch;

    if (persona.gender == VoiceGender.female) {
      if (_femaleVoices.isNotEmpty) {
        for (var pref in persona.preferredSystemVoices) {
          final match = _femaleVoices.where((v) => v['name']!.toLowerCase().contains(pref.toLowerCase()));
          if (match.isNotEmpty) {
            bestMatch = match.first;
            break;
          }
        }
        bestMatch ??= _femaleVoices.first;
      }
    } else if (persona.gender == VoiceGender.male) {
      if (_maleVoices.isNotEmpty) {
        for (var pref in persona.preferredSystemVoices) {
          final match = _maleVoices.where((v) => v['name']!.toLowerCase().contains(pref.toLowerCase()));
          if (match.isNotEmpty) {
            bestMatch = match.first;
            break;
          }
        }
        bestMatch ??= _maleVoices.first;
      }
    } else {
      // Neutral / Robot
      if (_allVoices.isNotEmpty) {
        bestMatch = _allVoices.first;
      }
    }

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
    }

    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setVolume(_volume);

    notifyListeners();
  }

  /// Sets a specific system voice directly
  Future<void> setSystemVoice(Map<String, String> voice) async {
    _selectedSystemVoice = voice;
    final nameLower = voice['name']!.toLowerCase();

    // Dynamically adjust pitch if male or female voice is chosen directly
    if (nameLower.contains('zira') || nameLower.contains('female') || nameLower.contains('google us english')) {
      _pitch = 1.38;
    } else if (nameLower.contains('david') || nameLower.contains('male') || nameLower.contains('mark')) {
      _pitch = 0.75;
    }

    try {
      await _flutterTts.setVoice({
        'name': voice['name']!,
        'locale': voice['locale']!,
      });
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
    await _flutterTts.setSpeechRate(_rate);
    notifyListeners();
  }

  Future<void> setVolume(double val) async {
    _volume = val;
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

    // 1. Force stop previous utterance to clear any stalled state
    await _flutterTts.stop();
    await Future.delayed(const Duration(milliseconds: 60));

    // 2. Ensure voices are loaded
    if (_maleVoices.isEmpty && _femaleVoices.isEmpty) {
      await _loadAndCategorizeVoices();
    }

    // 3. Ensure active voice is selected
    if (_selectedSystemVoice == null) {
      await applyPersona(_currentPersona);
    }

    // 4. Re-apply voice and acoustic parameters right before speaking
    if (_selectedSystemVoice != null) {
      try {
        await _flutterTts.setVoice({
          'name': _selectedSystemVoice!['name']!,
          'locale': _selectedSystemVoice!['locale']!,
        });
      } catch (e) {
        debugPrint("Error applying voice in speak(): $e");
      }
    }

    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setVolume(_volume);

    _state = TtsPlaybackState.playing;
    notifyListeners();

    await _flutterTts.speak(text);
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    _state = TtsPlaybackState.paused;
    notifyListeners();
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _state = TtsPlaybackState.stopped;
    _currentSpokenWord = '';
    _currentWordStart = 0;
    _currentWordEnd = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
