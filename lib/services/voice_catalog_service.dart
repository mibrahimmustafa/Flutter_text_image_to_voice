import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/voice_persona.dart';

class VoiceCatalogService {
  List<Map<String, String>> _allVoices = [];
  List<Map<String, String>> _maleVoices = [];
  List<Map<String, String>> _femaleVoices = [];
  List<Map<String, String>> _arabicVoices = [];

  List<Map<String, String>> get allVoices => _allVoices;
  List<Map<String, String>> get maleVoices => _maleVoices;
  List<Map<String, String>> get femaleVoices => _femaleVoices;
  List<Map<String, String>> get arabicVoices => _arabicVoices;

  bool _hasGenderData = false;
  /// True if the TTS engine returned real gender metadata for at least one voice.
  /// When false, the Men/Women filter tabs should be hidden.
  bool get hasGenderData => _hasGenderData;

  bool get isEmpty => _allVoices.isEmpty;

  Future<void> loadAndCategorize(FlutterTts flutterTts) async {
    try {
      dynamic voices = await flutterTts.getVoices;
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

        _maleVoices = [];
        _femaleVoices = [];
        _arabicVoices = [];
        _hasGenderData = false;

        final femaleKeywords = [
          'female', 'woman', 'zira', 'google us english', 'google uk english female',
          'susan', 'samantha', 'jenny', 'karen', 'victoria', 'emma', 'sophia', 'eva',
          'hazel', 'fiona', 'catherine', 'alice', 'elena', 'helena', 'laura', 'maria',
          'anna', 'zeina', 'salma', 'hoda', 'laila', 'mariam', 'en-us-x-sfg#female',
          'en-us-x-tpd#female', 'en-us-x-iol#female',
        ];

        final maleKeywords = [
          'male', 'david', 'mark', 'google uk english male', 'guy', 'george', 'brian',
          'oliver', 'daniel', 'richard', 'alex', 'james', 'john', 'tom', 'tarik', 'maged',
          'naayf', 'en-us-x-sfg#male', 'en-us-x-tpd#male', 'en-us-x-iol#male',
        ];

        for (var voice in _allVoices) {
          final nameLower = voice['name']!.toLowerCase();
          final localeLower = voice['locale']!.toLowerCase();
          final genderRaw = voice['gender']!.toLowerCase().trim();

          final isEnglish = localeLower.startsWith('en') || nameLower.contains('english');
          final isArabic = !isEnglish && (
            localeLower.startsWith('ar') || localeLower == 'ar' ||
            localeLower.contains('ar-') || localeLower.contains('ar_') ||
            nameLower.contains('arabic') || nameLower.contains('عربي') ||
            nameLower.contains('tarik') || nameLower.contains('maged') ||
            nameLower.contains('naayf') || nameLower.contains('zeina') ||
            nameLower.contains('salma') || nameLower.contains('laila') ||
            nameLower.contains('mariam') || nameLower.contains('hoda') ||
            nameLower.contains('shakir') || nameLower.contains('hamed')
          );

          if (isArabic) {
            _arabicVoices.add(voice);
          }

          // --- Gender detection (broadest possible) ---
          bool? isFemale;

          // 1. Explicit gender field: "female"/"male", or numeric "1"=male/"2"=female (some engines)
          if (genderRaw == 'female' || genderRaw == 'f' || genderRaw == '2') {
            isFemale = true;
          } else if (genderRaw == 'male' || genderRaw == 'm' || genderRaw == '1') {
            isFemale = false;
          }
          // 2. Gender substring (handles "VoiceName[female]" style)
          else if (genderRaw.contains('female')) {
            isFemale = true;
          } else if (genderRaw.contains('male')) {
            isFemale = false;
          }
          // 3. Name contains explicit #female / #male (Google TTS convention)
          else if (nameLower.contains('#female') || nameLower.contains('-female') || nameLower.contains('_female')) {
            isFemale = true;
          } else if (nameLower.contains('#male') || nameLower.contains('-male') || nameLower.contains('_male')) {
            isFemale = false;
          }
          // 4. Well-known name keywords
          else if (femaleKeywords.any((k) => nameLower.contains(k))) {
            isFemale = true;
          } else if (maleKeywords.any((k) => nameLower.contains(k))) {
            isFemale = false;
          }

          // Assign to list(s)
          if (isFemale == true) {
            _femaleVoices.add(voice);
            _hasGenderData = true; // real gender detected
          } else if (isFemale == false) {
            _maleVoices.add(voice);
            _hasGenderData = true; // real gender detected
          } else {
            // Gender truly unknown — add to both so users can still browse.
            _maleVoices.add(voice);
            _femaleVoices.add(voice);
          }
        }

        int voiceQualityScore(Map<String, String> voice) {
          final name = voice['name']!.toLowerCase();
          int score = 0;
          if (name.contains('natural') || name.contains('online') || name.contains('neural')) score += 100;
          if (name.contains('google')) score += 80;
          if (name.contains('uk english') || name.contains('us english')) score += 40;
          if (name.contains('mark') || name.contains('guy') || name.contains('jenny') || name.contains('aria')) score += 30;
          if (name.contains('desktop')) score -= 40;
          return score;
        }

        _maleVoices.sort((a, b) => voiceQualityScore(b).compareTo(voiceQualityScore(a)));
        _femaleVoices.sort((a, b) => voiceQualityScore(b).compareTo(voiceQualityScore(a)));
        _arabicVoices.sort((a, b) => voiceQualityScore(b).compareTo(voiceQualityScore(a)));
        
        debugPrint("VoiceCatalogService: Loaded ${_allVoices.length} voices");
      }
    } catch (e) {
      debugPrint("Error fetching voices: $e");
    }
  }

  Map<String, String>? findBestMatch(VoicePersona persona) {
    Map<String, String>? bestMatch;

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

    if (bestMatch == null && persona.language != PersonaLanguage.arabic) {
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

    return bestMatch;
  }
}
