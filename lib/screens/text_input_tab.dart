import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/voice_persona.dart';
import '../services/tts_service.dart';
import '../widgets/speed_scroll_selector.dart';
import '../widgets/voice_persona_card.dart';

class TextInputTab extends StatefulWidget {
  final TextEditingController textController;
  final TtsService ttsService;
  final ValueChanged<String> onTextUpdated;
  final VoidCallback onTriggerSpeak;

  const TextInputTab({
    super.key,
    required this.textController,
    required this.ttsService,
    required this.onTextUpdated,
    required this.onTriggerSpeak,
  });

  @override
  State<TextInputTab> createState() => _TextInputTabState();
}

class _TextInputTabState extends State<TextInputTab> {
  final List<Map<String, String>> _samplePresets = [
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

  void _applySample(String sampleText) {
    widget.textController.text = sampleText;
    widget.onTextUpdated(sampleText);
    setState(() {});
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null && data!.text!.isNotEmpty) {
      widget.textController.text = data.text!;
      widget.onTextUpdated(data.text!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    'Instant Sample Texts',
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
                  children: _samplePresets.map((preset) {
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
                          'Text to Speak',
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
                          tooltip: 'Clear text',
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
                  onChanged: (val) {
                    widget.onTextUpdated(val);
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 15, height: 1.5),
                  decoration: InputDecoration(
                    hintText: 'Type, paste, or pick any sample text here to hear it with men or women voices...',
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

                // Stats Bar: Words, Chars, Read Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$wordCount words • ${widget.textController.text.length} chars',
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
                          '~${readingTimeSeconds}s audio',
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
                    ? 'Pause Playback'
                    : 'Speak Now with ${widget.ttsService.currentPersona.name} (${widget.ttsService.currentPersona.gender == VoiceGender.male ? "Man" : "Woman"})',
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
          const SizedBox(height: 100), // Bottom padding for player bar
        ],
      ),
    );
  }

  Widget _buildVoicePersonaSelector(BuildContext context) {
    final theme = Theme.of(context);

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
                  'Select Voice (Multiple Men & Women)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              '${VoicePersona.defaultPersonas.length} styles available',
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
            itemCount: VoicePersona.defaultPersonas.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final persona = VoicePersona.defaultPersonas[index];
              final isSelected = widget.ttsService.currentPersona.id == persona.id;

              return VoicePersonaCard(
                persona: persona,
                isSelected: isSelected,
                onSelect: () => widget.ttsService.applyPersona(persona),
                onPreview: () async {
                  await widget.ttsService.applyPersona(persona);
                  final previewText = persona.gender == VoiceGender.male
                      ? "Hi, I'm ${persona.name}. Ready to speak your text with a masculine tone."
                      : "Hello, I am ${persona.name}. Ready to read your text with an expressive feminine voice.";
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
