import 'package:flutter/material.dart';

enum VoiceGender {
  male,
  female,
  neutral,
}

class VoicePersona {
  final String id;
  final String name;
  final VoiceGender gender;
  final String tag;
  final String description;
  final double pitch;
  final double rate;
  final IconData icon;
  final Color accentColor;
  final List<String> preferredSystemVoices;

  const VoicePersona({
    required this.id,
    required this.name,
    required this.gender,
    required this.tag,
    required this.description,
    required this.pitch,
    required this.rate,
    required this.icon,
    required this.accentColor,
    this.preferredSystemVoices = const [],
  });

  static const List<VoicePersona> defaultPersonas = [
    // --- MEN VOICES ---
    VoicePersona(
      id: 'male_deep',
      name: 'Alexander',
      gender: VoiceGender.male,
      tag: 'Deep Baritone',
      description: 'Resonant, authoritative, deep masculine tone',
      pitch: 0.70,
      rate: 0.48,
      icon: Icons.record_voice_over_rounded,
      accentColor: Color(0xFF3B82F6), // Blue
      preferredSystemVoices: [
        'david',
        'mark',
        'google uk english male',
        'guy',
        'george',
        'male',
        'en-us-x-sfg#male',
        'en-gb-x-rjs#male',
      ],
    ),
    VoicePersona(
      id: 'male_warm',
      name: 'Marcus',
      gender: VoiceGender.male,
      tag: 'Warm Storyteller',
      description: 'Natural everyday male voice with friendly cadence',
      pitch: 0.88,
      rate: 0.50,
      icon: Icons.person_rounded,
      accentColor: Color(0xFF0EA5E9), // Sky
      preferredSystemVoices: [
        'mark',
        'david',
        'brian',
        'oliver',
        'male',
        'en-us-x-tpd#male',
      ],
    ),
    VoicePersona(
      id: 'male_crisp',
      name: 'Elijah',
      gender: VoiceGender.male,
      tag: 'Energetic Presenter',
      description: 'Clear, dynamic and energetic modern male voice',
      pitch: 1.02,
      rate: 0.54,
      icon: Icons.campaign_rounded,
      accentColor: Color(0xFF6366F1), // Indigo
      preferredSystemVoices: [
        'david',
        'mark',
        'male',
        'en-us-x-iol#male',
      ],
    ),

    // --- WOMEN VOICES ---
    VoicePersona(
      id: 'female_elegant',
      name: 'Victoria',
      gender: VoiceGender.female,
      tag: 'Warm & Elegant',
      description: 'Smooth, articulate, executive feminine narration',
      pitch: 1.42,
      rate: 0.50,
      icon: Icons.voice_chat_rounded,
      accentColor: Color(0xFFEC4899), // Pink
      preferredSystemVoices: [
        'zira',
        'google us english',
        'google uk english female',
        'jenny',
        'susan',
        'samantha',
        'female',
        'en-us-x-sfg#female',
      ],
    ),
    VoicePersona(
      id: 'female_bright',
      name: 'Emma',
      gender: VoiceGender.female,
      tag: 'Bright & Cheerful',
      description: 'Lively, friendly, crisp and engaging speech',
      pitch: 1.58,
      rate: 0.52,
      icon: Icons.face_3_rounded,
      accentColor: Color(0xFFF43F5E), // Rose
      preferredSystemVoices: [
        'google us english',
        'zira',
        'karen',
        'female',
        'en-us-x-tpd#female',
      ],
    ),
    VoicePersona(
      id: 'female_gentle',
      name: 'Sophia',
      gender: VoiceGender.female,
      tag: 'Gentle & Calming',
      description: 'Soft, relaxing, meditative feminine cadence',
      pitch: 1.30,
      rate: 0.46,
      icon: Icons.spa_rounded,
      accentColor: Color(0xFFA855F7), // Purple
      preferredSystemVoices: [
        'zira',
        'google uk english female',
        'google us english',
        'moira',
        'female',
        'en-us-x-iol#female',
      ],
    ),

    // --- SPECIAL EFFECTS ---
    VoicePersona(
      id: 'cyber_bot',
      name: 'Titan-9',
      gender: VoiceGender.neutral,
      tag: 'Futuristic AI',
      description: 'Cybernetic synth tone for sci-fi atmosphere',
      pitch: 0.50,
      rate: 0.62,
      icon: Icons.smart_toy_rounded,
      accentColor: Color(0xFF10B981), // Emerald
    ),
  ];
}
