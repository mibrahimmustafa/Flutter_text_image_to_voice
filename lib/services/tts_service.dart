import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/voice_persona.dart';
import 'cloud_arabic_tts_service.dart';

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
  final CloudArabicTtsService _cloudArabicTts = CloudArabicTtsService();
  bool _isUsingCloudArabicTts = false;

  TtsPlaybackState _state = TtsPlaybackState.stopped;
  TtsPlaybackState get state => _state;
  bool get isPlaying => _state == TtsPlaybackState.playing;
  bool get isPaused => _state == TtsPlaybackState.paused;
  bool get isStopped => _state == TtsPlaybackState.stopped;

  List<Map<String, String>> _allVoices = [];
  List<Map<String, String>> _maleVoices = [];
  List<Map<String, String>> _femaleVoices = [];
  List<Map<String, String>> _arabicVoices = [];

  List<Map<String, String>> get allVoices => _allVoices;
  List<Map<String, String>> get maleVoices => _maleVoices;
  List<Map<String, String>> get femaleVoices => _femaleVoices;
  List<Map<String, String>> get arabicVoices => _arabicVoices;

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

        // Categorize into Male, Female, and Arabic
        _maleVoices = [];
        _femaleVoices = [];
        _arabicVoices = [];

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
          'zeina',
          'salma',
          'hoda',
          'laila',
          'mariam',
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
          'tarik',
          'maged',
          'naayf',
          'en-us-x-sfg#male',
          'en-us-x-tpd#male',
          'en-us-x-iol#male',
        ];

        final arabicKeywords = [
          'ar',
          'arabic',
          'arab',
          'ar-sa',
          'ar-eg',
          'ar-ae',
          'tarik',
          'maged',
          'naayf',
          'zeina',
          'salma',
          'hoda',
          'laila',
          'mariam',
        ];

        for (var voice in _allVoices) {
          final nameLower = voice['name']!.toLowerCase();
          final localeLower = voice['locale']!.toLowerCase();
          final genderLower = voice['gender']!.toLowerCase();

          // Check if Arabic
          if (arabicKeywords.any((k) => nameLower.contains(k) || localeLower.contains(k))) {
            _arabicVoices.add(voice);
          }

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
            if (nameLower.contains('desktop') && !nameLower.contains('zira')) {
              _maleVoices.add(voice);
            }
          }
        }

        // Sort voices so high-definition, neural, and studio voices appear at the top
        int voiceQualityScore(Map<String, String> voice) {
          final name = voice['name']!.toLowerCase();
          int score = 0;
          if (name.contains('natural') || name.contains('online') || name.contains('neural')) score += 100;
          if (name.contains('google')) score += 80;
          if (name.contains('uk english') || name.contains('us english')) score += 40;
          if (name.contains('mark') || name.contains('guy') || name.contains('jenny') || name.contains('aria')) score += 30;
          if (name.contains('desktop')) score -= 40; // Deprioritize legacy desktop voices
          return score;
        }

        _maleVoices.sort((a, b) => voiceQualityScore(b).compareTo(voiceQualityScore(a)));
        _femaleVoices.sort((a, b) => voiceQualityScore(b).compareTo(voiceQualityScore(a)));
        _arabicVoices.sort((a, b) => voiceQualityScore(b).compareTo(voiceQualityScore(a)));

        debugPrint("TtsService: Loaded ${_allVoices.length} voices (${_maleVoices.length} male, ${_femaleVoices.length} female, ${_arabicVoices.length} arabic)");
      }
    } catch (e) {
      debugPrint("Error fetching voices: $e");
    }
  }

  /// Sets one of the pre-tuned Voice Personas
  Future<void> applyPersona(VoicePersona persona) async {
    _currentPersona = persona;
    _pitch = persona.pitch;
    _rate = persona.rate;

    if (persona.language == PersonaLanguage.arabic) {
      _currentLanguage = 'ar-SA';
    } else {
      _currentLanguage = 'en-US';
    }

    if (_maleVoices.isEmpty && _femaleVoices.isEmpty) {
      await _loadAndCategorizeVoices();
    }

    Map<String, String>? bestMatch;

    // Check Arabic voices first if persona is Arabic
    if (persona.language == PersonaLanguage.arabic && _arabicVoices.isNotEmpty) {
      for (var pref in persona.preferredSystemVoices) {
        final match = _arabicVoices.where((v) => v['name']!.toLowerCase().contains(pref.toLowerCase()));
        if (match.isNotEmpty) {
          bestMatch = match.first;
          break;
        }
      }
      if (bestMatch == null) {
        if (persona.gender == VoiceGender.female) {
          bestMatch = _arabicVoices.firstWhere(
            (v) => v['name']!.toLowerCase().contains('female') ||
                   v['name']!.toLowerCase().contains('zeina') ||
                   v['name']!.toLowerCase().contains('salma') ||
                   v['name']!.toLowerCase().contains('laila') ||
                   v['name']!.toLowerCase().contains('mariam'),
            orElse: () => _arabicVoices.first,
          );
        } else {
          bestMatch = _arabicVoices.firstWhere(
            (v) => v['name']!.toLowerCase().contains('male') ||
                   v['name']!.toLowerCase().contains('tarik') ||
                   v['name']!.toLowerCase().contains('maged') ||
                   v['name']!.toLowerCase().contains('naayf'),
            orElse: () => _arabicVoices.first,
          );
        }
      }
    }

    if (bestMatch == null) {
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
        if (_allVoices.isNotEmpty) {
          bestMatch = _allVoices.first;
        }
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

    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setSpeechRate(_rate);
    await _flutterTts.setVolume(_volume);

    notifyListeners();
  }

  Future<void> setSystemVoice(Map<String, String> voice) async {
    _selectedSystemVoice = voice;
    final nameLower = voice['name']!.toLowerCase();

    // Natural human pitch baseline instead of artificial distortion
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
    if (_isUsingCloudArabicTts) {
      _cloudArabicTts.setRate(_rate);
    }
    await _flutterTts.setSpeechRate(_rate);
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

    // 1. Force stop previous utterance to clear any stalled state
    await stop();
    await Future.delayed(const Duration(milliseconds: 60));

    // 2. Ensure voices are loaded
    if (_maleVoices.isEmpty && _femaleVoices.isEmpty) {
      await _loadAndCategorizeVoices();
    }

    // 3. Detect Arabic text or active Arabic persona
    final hasArabic = isArabicString(text) || _currentPersona.language == PersonaLanguage.arabic;

    // 4. If speaking Arabic and no native system Arabic voice is installed, use CloudArabicTtsService
    if (hasArabic && _arabicVoices.isEmpty) {
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

    // 5. System TTS execution (English, or devices with installed Arabic voice pack)
    _isUsingCloudArabicTts = false;
    final targetLang = hasArabic ? 'ar-SA' : _currentLanguage;

    try {
      await _flutterTts.setLanguage(targetLang);
    } catch (_) {}

    // Ensure active voice is selected
    if (_selectedSystemVoice == null) {
      await applyPersona(_currentPersona);
    }

    // Route to best Arabic voice if native Arabic voices exist
    Map<String, String>? voiceToApply = _selectedSystemVoice;
    if (hasArabic && _arabicVoices.isNotEmpty) {
      final isFemale = _currentPersona.gender == VoiceGender.female;
      voiceToApply = _arabicVoices.firstWhere(
        (v) => isFemale
            ? v['name']!.toLowerCase().contains('female') || v['name']!.toLowerCase().contains('zeina')
            : v['name']!.toLowerCase().contains('male') || v['name']!.toLowerCase().contains('tarik'),
        orElse: () => _arabicVoices.first,
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
    await _flutterTts.setSpeechRate(_rate);
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
