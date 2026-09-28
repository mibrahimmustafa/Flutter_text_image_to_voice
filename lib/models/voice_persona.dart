import 'package:flutter/material.dart';

enum VoiceGender {
  male,
  female,
  neutral,
}

enum PersonaLanguage {
  english,
  arabic,
}

class VoicePersona {
  final String id;
  final String name;
  final String nameArabic;
  final VoiceGender gender;
  final PersonaLanguage language;
  final String tag;
  final String tagArabic;
  final String description;
  final String descriptionArabic;
  final double pitch;
  final double rate;
  final IconData icon;
  final Color accentColor;
  final List<String> preferredSystemVoices;

  const VoicePersona({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.gender,
    this.language = PersonaLanguage.english,
    required this.tag,
    required this.tagArabic,
    required this.description,
    required this.descriptionArabic,
    required this.pitch,
    required this.rate,
    required this.icon,
    required this.accentColor,
    this.preferredSystemVoices = const [],
  });

  static const List<VoicePersona> englishPersonas = [
    // --- MEN VOICES ---
    VoicePersona(
      id: 'male_deep',
      name: 'Alexander',
      nameArabic: 'ألكسندر',
      gender: VoiceGender.male,
      language: PersonaLanguage.english,
      tag: 'Deep Baritone',
      tagArabic: 'صوت رجالي عميق',
      description: 'Resonant, authoritative, deep masculine tone',
      descriptionArabic: 'نبرة رجالية فصيحة ورصينة وقوية',
      pitch: 0.70,
      rate: 0.48,
      icon: Icons.record_voice_over_rounded,
      accentColor: Color(0xFF3B82F6),
      preferredSystemVoices: [
        'david',
        'mark',
        'google uk english male',
        'guy',
        'george',
        'male',
        'en-us-x-sfg#male',
      ],
    ),
    VoicePersona(
      id: 'male_warm',
      name: 'Marcus',
      nameArabic: 'ماركوس',
      gender: VoiceGender.male,
      language: PersonaLanguage.english,
      tag: 'Warm Storyteller',
      tagArabic: 'قارئ دافئ',
      description: 'Natural everyday male voice with friendly cadence',
      descriptionArabic: 'صوت رجالي طبيعي بنبرة دافئة',
      pitch: 0.88,
      rate: 0.50,
      icon: Icons.person_rounded,
      accentColor: Color(0xFF0EA5E9),
      preferredSystemVoices: [
        'mark',
        'david',
        'brian',
        'oliver',
        'male',
      ],
    ),
    VoicePersona(
      id: 'male_crisp',
      name: 'Elijah',
      nameArabic: 'إيليا',
      gender: VoiceGender.male,
      language: PersonaLanguage.english,
      tag: 'Energetic Presenter',
      tagArabic: 'مقدم حيوي',
      description: 'Clear, dynamic and energetic modern male voice',
      descriptionArabic: 'صوت رجالي شاب مفعم بالحيوية',
      pitch: 1.02,
      rate: 0.54,
      icon: Icons.campaign_rounded,
      accentColor: Color(0xFF6366F1),
      preferredSystemVoices: [
        'david',
        'mark',
        'male',
      ],
    ),

    // --- WOMEN VOICES ---
    VoicePersona(
      id: 'female_elegant',
      name: 'Victoria',
      nameArabic: 'فيكتوريا',
      gender: VoiceGender.female,
      language: PersonaLanguage.english,
      tag: 'Warm & Elegant',
      tagArabic: 'صوت نسائي راقٍ',
      description: 'Smooth, articulate, executive feminine narration',
      descriptionArabic: 'نبرة نسائية فصيحة ورخيمة',
      pitch: 1.42,
      rate: 0.50,
      icon: Icons.voice_chat_rounded,
      accentColor: Color(0xFFEC4899),
      preferredSystemVoices: [
        'zira',
        'google us english',
        'google uk english female',
        'jenny',
        'susan',
        'female',
      ],
    ),
    VoicePersona(
      id: 'female_bright',
      name: 'Emma',
      nameArabic: 'إيما',
      gender: VoiceGender.female,
      language: PersonaLanguage.english,
      tag: 'Bright & Cheerful',
      tagArabic: 'صوت نسائي مشرق',
      description: 'Lively, friendly, crisp and engaging speech',
      descriptionArabic: 'صوت نسائي بهيج وواضح',
      pitch: 1.58,
      rate: 0.52,
      icon: Icons.face_3_rounded,
      accentColor: Color(0xFFF43F5E),
      preferredSystemVoices: [
        'google us english',
        'zira',
        'karen',
        'female',
      ],
    ),
    VoicePersona(
      id: 'female_gentle',
      name: 'Sophia',
      nameArabic: 'صوفيا',
      gender: VoiceGender.female,
      language: PersonaLanguage.english,
      tag: 'Gentle & Calming',
      tagArabic: 'صوت نسائي هادئ',
      description: 'Soft, relaxing, meditative feminine cadence',
      descriptionArabic: 'نبرة نسائية ناعمة ومريحة',
      pitch: 1.30,
      rate: 0.46,
      icon: Icons.spa_rounded,
      accentColor: Color(0xFFA855F7),
      preferredSystemVoices: [
        'zira',
        'google uk english female',
        'female',
      ],
    ),

    // --- SPECIAL EFFECTS ---
    VoicePersona(
      id: 'cyber_bot',
      name: 'Titan-9',
      nameArabic: 'تيتان-9',
      gender: VoiceGender.neutral,
      language: PersonaLanguage.english,
      tag: 'Futuristic AI',
      tagArabic: 'صوت إلكتروني',
      description: 'Cybernetic synth tone for sci-fi atmosphere',
      descriptionArabic: 'صوت روبوت ذكاء اصطناعي مستقبلي',
      pitch: 0.50,
      rate: 0.62,
      icon: Icons.smart_toy_rounded,
      accentColor: Color(0xFF10B981),
    ),
  ];

  static const List<VoicePersona> arabicPersonas = [
    // --- أصوات الرجال بالعربية ---
    VoicePersona(
      id: 'ar_male_deep',
      name: 'Tariq',
      nameArabic: 'طارق',
      gender: VoiceGender.male,
      language: PersonaLanguage.arabic,
      tag: 'Deep Arabic Male',
      tagArabic: 'صوت رجالي وقور',
      description: 'Commanding, authoritative Arabic male reader',
      descriptionArabic: 'صوت عربي فصيح بنبرة رخيمة ووقورة مناسب للشعر والخطب',
      pitch: 0.72,
      rate: 0.48,
      icon: Icons.record_voice_over_rounded,
      accentColor: Color(0xFF3B82F6),
      preferredSystemVoices: [
        'ar',
        'arabic',
        'tarik',
        'maged',
        'naayf',
        'david',
        'mark',
      ],
    ),
    VoicePersona(
      id: 'ar_male_warm',
      name: 'Omar',
      nameArabic: 'عمر',
      gender: VoiceGender.male,
      language: PersonaLanguage.arabic,
      tag: 'Calm Arabic Narrator',
      tagArabic: 'راوٍ عربي هادئ',
      description: 'Natural everyday Arabic male voice',
      descriptionArabic: 'صوت رجالي عربي طبيعي ودافئ لقراءة الكتب والمقالات',
      pitch: 0.90,
      rate: 0.50,
      icon: Icons.person_rounded,
      accentColor: Color(0xFF0EA5E9),
      preferredSystemVoices: [
        'ar',
        'arabic',
        'maged',
        'mark',
        'david',
      ],
    ),

    // --- أصوات النساء بالعربية ---
    VoicePersona(
      id: 'ar_female_warm',
      name: 'Fatima',
      nameArabic: 'فاطمة',
      gender: VoiceGender.female,
      language: PersonaLanguage.arabic,
      tag: 'Warm Arabic Female',
      tagArabic: 'صوت نسائي فصيح',
      description: 'Articulate, smooth and clear feminine voice',
      descriptionArabic: 'صوت نسائي عربي رخيم وأصيل مناسب لقراءة القصص والأخبار',
      pitch: 1.38,
      rate: 0.50,
      icon: Icons.voice_chat_rounded,
      accentColor: Color(0xFFEC4899),
      preferredSystemVoices: [
        'ar',
        'arabic',
        'zeina',
        'salma',
        'laila',
        'mariam',
        'hoda',
        'zira',
        'female',
      ],
    ),
    VoicePersona(
      id: 'ar_female_bright',
      name: 'Mariam',
      nameArabic: 'مريم',
      gender: VoiceGender.female,
      language: PersonaLanguage.arabic,
      tag: 'Bright Arabic Female',
      tagArabic: 'صوت نسائي نضر',
      description: 'Lively, friendly and cheerful Arabic female voice',
      descriptionArabic: 'صوت نسائي عربي مبهج ومفعم بالحيوية والتفاؤل',
      pitch: 1.55,
      rate: 0.52,
      icon: Icons.face_3_rounded,
      accentColor: Color(0xFFF43F5E),
      preferredSystemVoices: [
        'ar',
        'arabic',
        'zeina',
        'salma',
        'zira',
        'female',
      ],
    ),

    // --- صوت إلكتروني عربي ---
    VoicePersona(
      id: 'ar_cyber_bot',
      name: 'Titan AR',
      nameArabic: 'المعالج الذكي',
      gender: VoiceGender.neutral,
      language: PersonaLanguage.arabic,
      tag: 'Arabic AI Synth',
      tagArabic: 'روبوت باللغة العربية',
      description: 'Synthetic futuristic Arabic voice',
      descriptionArabic: 'صوت ذكاء اصطناعي إلكتروني متطور باللغة العربية',
      pitch: 0.50,
      rate: 0.60,
      icon: Icons.smart_toy_rounded,
      accentColor: Color(0xFF10B981),
      preferredSystemVoices: ['ar', 'arabic'],
    ),
  ];

  static List<VoicePersona> get allPersonas => [
        ...englishPersonas,
        ...arabicPersonas,
      ];
}
