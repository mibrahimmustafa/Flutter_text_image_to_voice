import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/app_strings.dart';
import '../models/voice_persona.dart';
import '../services/tts_service.dart';
import '../widgets/speed_scroll_selector.dart';
import '../widgets/voice_persona_card.dart';

class TextInputTab extends StatefulWidget {
  final TextEditingController textController;
  final TtsService ttsService;
  final ValueChanged<String> onTextUpdated;
  final VoidCallback onTriggerSpeak;
  final bool isArabic;

  const TextInputTab({
    super.key,
    required this.textController,
    required this.ttsService,
    required this.onTextUpdated,
    required this.onTriggerSpeak,
    this.isArabic = false,
  });

  @override
  State<TextInputTab> createState() => _TextInputTabState();
}

class _TextInputTabState extends State<TextInputTab> {
  AppStrings get strings => AppStrings(isArabic: widget.isArabic);

  final List<Map<String, String>> _englishPresets = [
    {
      'title': '💡 Perseverance Quote',
      'text':
          'Success is not final, failure is not fatal: it is the courage to continue that counts. Believe you can and you are halfway there.',
    },
    {
      'title': '🚀 AI & Future',
      'text':
          'Artificial intelligence and neural speech engines are transforming how humans and computers communicate across continents and languages.',
    },
    {
      'title': '☕ Morning Story',
      'text':
          'The morning sun broke through the golden horizon, warming the misty cobblestone streets as the aroma of freshly ground coffee drifted into the crisp air.',
    },
    {
      'title': '👅 Tongue Twister',
      'text':
          'She sells seashells by the seashore, and the shells she sells are seashells for sure. How much wood would a woodchuck chuck if a woodchuck could chuck wood?',
    },
  ];

  final List<Map<String, String>> _arabicPresets = [
    {
      'title': '📜 حكمة عربية ملهمة',
      'text':
          'العلم يبني بيوتاً لا عماد لها، والجهل يهدم بيوت العز والشرف. لا تحسبن العلم ينفع وحده ما لم يتوج ربه بخلاق.',
    },
    {
      'title': '🚀 ثورة الذكاء الاصطناعي',
      'text':
          'تطور تقنيات الذكاء الاصطناعي وتحويل النصوص العربية والصور إلى أصوات بشرية طبيعية يفتح آفاقاً واسعة لمستقبل التعليم والمعرفة والتواصل الإنساني.',
    },
    {
      'title': '☕ إشراقة الصباح',
      'text':
          'تنفست الطبيعة في هذا الصباح المشرق بنسمات هادئة عليلة، وتفتحت أزهار الياسمين لتملأ الأفق بعبيرها الفواح وأمل يوم جديد مليء بالنجاح.',
    },
    {
      'title': '👅 تحدي النطق السريع',
      'text':
          'خيط حرير على حيط خليل. وقبر حرب بمكان قفر، وليس قرب قبر حرب قبر. شمس تمشي وشمس مشمسة.',
    },
  ];

  void _applySample(String sampleText) {
    widget.textController.text = sampleText;
    widget.onTextUpdated(sampleText);

    // If applied text is Arabic, auto-switch to Arabic voice if needed
    if (TtsService.isArabicString(sampleText) && !widget.isArabic) {
      widget.ttsService.applyPersona(VoicePersona.arabicPersonas[0]);
    }

    setState(() {});
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      widget.textController.text = data.text!;
      widget.onTextUpdated(data.text!);

      if (TtsService.isArabicString(data.text!)) {
        widget.ttsService.applyPersona(VoicePersona.arabicPersonas[0]);
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtlText = TtsService.isArabicString(widget.textController.text) || widget.isArabic;
    final presets = widget.isArabic ? _arabicPresets : _englishPresets;

    final wordCount = widget.textController.text.trim().isEmpty
        ? 0
        : widget.textController.text.trim().split(RegExp(r'\s+')).length;
    final readingTimeSeconds = (wordCount / 2.5).ceil();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sample Preset Pills
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    strings.instantSampleTexts,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: presets.map((preset) {
                    final isCurrent = widget.textController.text == preset['text'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(preset['title']!),
                        backgroundColor: isCurrent
                            ? theme.colorScheme.primary.withValues(alpha: 0.18)
                            : (isDark ? const Color(0xFF1E2433) : Colors.white),
                        side: BorderSide(
                          color: isCurrent
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08)),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                        onPressed: () => _applySample(preset['text']!),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Text Editor Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181D29) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          strings.textToSpeak,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Paste from clipboard',
                          icon: const Icon(Icons.paste_rounded, size: 18),
                          onPressed: _pasteFromClipboard,
                        ),
                        IconButton(
                          tooltip: strings.clear,
                          icon: const Icon(Icons.clear_all_rounded, size: 18),
                          onPressed: () {
                            widget.textController.clear();
                            widget.onTextUpdated('');
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Text Input Area
                TextField(
                  controller: widget.textController,
                  maxLines: 8,
                  minLines: 4,
                  textDirection: isRtlText ? TextDirection.rtl : TextDirection.ltr,
                  onChanged: (val) {
                    widget.onTextUpdated(val);
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 15, height: 1.6),
                  decoration: InputDecoration(
                    hintText: strings.textInputHint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF131722) : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Stats Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$wordCount ${widget.isArabic ? "كلمة" : "words"} • ${widget.textController.text.length} ${widget.isArabic ? "حرف" : "chars"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '~$readingTimeSeconds${widget.isArabic ? "ث تسجيل" : "s audio"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Voice Persona Selection Section
          _buildVoicePersonaSelector(context),
          const SizedBox(height: 18),

          // Speed Scroll Selector
          SpeedScrollSelector(
            currentRate: widget.ttsService.rate,
            accentColor: widget.ttsService.currentPersona.accentColor,
            showSlider: true,
            isArabic: widget.isArabic,
            onRateChanged: (v) {
              widget.ttsService.setRate(v);
              setState(() {});
            },
          ),
          const SizedBox(height: 16),

          // Big Master Speak Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.textController.text.trim().isEmpty ? null : widget.onTriggerSpeak,
              icon: Icon(
                widget.ttsService.isPlaying ? Icons.pause_rounded : Icons.volume_up_rounded,
                size: 22,
              ),
              label: Text(
                widget.ttsService.isPlaying
                    ? strings.pausePlayback
                    : strings.speakNowButton(
                        widget.isArabic
                            ? widget.ttsService.currentPersona.nameArabic
                            : widget.ttsService.currentPersona.name,
                        widget.ttsService.currentPersona.gender == VoiceGender.male
                            ? strings.man
                            : strings.woman,
                      ),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.ttsService.currentPersona.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildVoicePersonaSelector(BuildContext context) {
    final theme = Theme.of(context);
    final personas = widget.isArabic ? VoicePersona.arabicPersonas : VoicePersona.englishPersonas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.spatial_audio_rounded, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  strings.selectVoiceTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              '${personas.length} ${strings.stylesAvailable}',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: personas.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final persona = personas[index];
              final isSelected = widget.ttsService.currentPersona.id == persona.id;

              return VoicePersonaCard(
                persona: persona,
                isSelected: isSelected,
                isArabic: widget.isArabic,
                onSelect: () => widget.ttsService.applyPersona(persona),
                onPreview: () async {
                  await widget.ttsService.applyPersona(persona);
                  String previewText;
                  if (widget.isArabic) {
                    previewText = persona.gender == VoiceGender.male
                        ? "مرحباً، أنا ${persona.nameArabic}. جاهز لقراءة نصوصك بصوت رجالي عربي."
                        : "أهلاً، أنا ${persona.nameArabic}. جاهزة لنطق كتاباتك بصوت نسائي عربي فصيح.";
                  } else {
                    previewText = persona.gender == VoiceGender.male
                        ? "Hi, I'm ${persona.name}. Ready to speak your text with a masculine tone."
                        : "Hello, I am ${persona.name}. Ready to read your text with an expressive feminine voice.";
                  }
                  await widget.ttsService.speak(previewText);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
