import 'package:flutter/material.dart';
import '../models/voice_persona.dart';
import '../services/tts_service.dart';
import 'audio_visualizer.dart';
import 'speed_scroll_selector.dart';
import 'system_voice_browser_dialog.dart';
import 'voice_control_sliders.dart';

class VoicePlayerBar extends StatefulWidget {
  final TtsService ttsService;
  final String textToSpeak;
  final VoidCallback? onSpeakRequested;
  final bool isArabic;

  const VoicePlayerBar({
    super.key,
    required this.ttsService,
    required this.textToSpeak,
    this.onSpeakRequested,
    this.isArabic = false,
  });

  @override
  State<VoicePlayerBar> createState() => _VoicePlayerBarState();
}

class _VoicePlayerBarState extends State<VoicePlayerBar> {
  bool _showFineTuning = false;
  bool _showSpeedScroll = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final persona = widget.ttsService.currentPersona;

    final displayName = widget.ttsService.selectedSystemVoice?['name'] ??
        (widget.isArabic ? persona.nameArabic : persona.name);
    final displayTag = widget.isArabic ? persona.tagArabic : persona.tag;
    final tapToChangeText = widget.isArabic ? 'اضغط للتغيير' : 'Tap to change';
    final sayItText = widget.ttsService.isPlaying
        ? (widget.isArabic ? 'إيقاف مؤقت' : 'Pause')
        : (widget.isArabic ? 'انطق' : 'Say It');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Expandable Speed Scroll Section
              if (_showSpeedScroll) ...[
                SpeedScrollSelector(
                  currentRate: widget.ttsService.rate,
                  accentColor: persona.accentColor,
                  showSlider: true,
                  isArabic: widget.isArabic,
                  onRateChanged: (v) => widget.ttsService.setRate(v),
                ),
                const SizedBox(height: 10),
              ],

              // Expandable fine tuning sliders
              if (_showFineTuning) ...[
                VoiceControlSliders(
                  pitch: widget.ttsService.pitch,
                  rate: widget.ttsService.rate,
                  volume: widget.ttsService.volume,
                  onPitchChanged: (v) => widget.ttsService.setPitch(v),
                  onRateChanged: (v) => widget.ttsService.setRate(v),
                  onVolumeChanged: (v) => widget.ttsService.setVolume(v),
                  onReset: () => widget.ttsService.applyPersona(widget.ttsService.currentPersona),
                ),
                const SizedBox(height: 12),
              ],

              // Spoken word progress preview (if currently playing)
              if (widget.ttsService.isPlaying && widget.ttsService.currentSpokenWord.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: persona.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.record_voice_over_rounded, size: 14, color: persona.accentColor),
                      const SizedBox(width: 6),
                      Text(
                        widget.isArabic
                            ? 'يتم نطق: "${widget.ttsService.currentSpokenWord}"'
                            : 'Speaking: "${widget.ttsService.currentSpokenWord}"',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: persona.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Wave visualizer
              AudioVisualizer(
                isPlaying: widget.ttsService.isPlaying,
                isPaused: widget.ttsService.isPaused,
                activeColor: persona.accentColor,
                height: 32,
                barCount: 28,
              ),
              const SizedBox(height: 10),

              // Control Bar Row
              Row(
                children: [
                  // Active Voice Persona / Custom Voice info button
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (c) => SystemVoiceBrowserDialog(ttsService: widget.ttsService),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2433) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: persona.accentColor.withValues(alpha: 0.2),
                              child: Icon(persona.icon, size: 16, color: persona.accentColor),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        persona.gender == VoiceGender.male
                                            ? '👨'
                                            : persona.gender == VoiceGender.female
                                                ? '👩'
                                                : '🤖',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '$displayTag • $tapToChangeText',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 18,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Speed Scroll Toggle Button
                  InkWell(
                    onTap: () {
                      setState(() => _showSpeedScroll = !_showSpeedScroll);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showSpeedScroll
                            ? persona.accentColor.withValues(alpha: 0.18)
                            : (isDark ? const Color(0xFF1E2433) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showSpeedScroll
                              ? persona.accentColor
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: 16,
                            color: _showSpeedScroll ? persona.accentColor : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.ttsService.rate.toStringAsFixed(2)}x',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _showSpeedScroll ? persona.accentColor : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Fine tune toggle button
                  IconButton(
                    tooltip: widget.isArabic ? 'ضبط النبرة والسرعة' : 'Adjust Pitch & Speed',
                    icon: Icon(
                      Icons.tune_rounded,
                      color: _showFineTuning ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _showFineTuning
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : (isDark ? const Color(0xFF1E2433) : Colors.grey.shade100),
                    ),
                    onPressed: () {
                      setState(() => _showFineTuning = !_showFineTuning);
                    },
                  ),
                  const SizedBox(width: 6),

                  // Stop button (if playing or paused)
                  if (widget.ttsService.isPlaying || widget.ttsService.isPaused) ...[
                    IconButton(
                      tooltip: widget.isArabic ? 'إيقاف' : 'Stop',
                      icon: const Icon(Icons.stop_rounded, color: Colors.redAccent),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                      ),
                      onPressed: () => widget.ttsService.stop(),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Play / Pause Master FAB
                  InkWell(
                    onTap: () {
                      if (widget.ttsService.isPlaying) {
                        widget.ttsService.pause();
                      } else {
                        if (widget.onSpeakRequested != null) {
                          widget.onSpeakRequested!();
                        } else {
                          widget.ttsService.speak(widget.textToSpeak);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            persona.accentColor,
                            persona.accentColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: persona.accentColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.ttsService.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            sayItText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
