import 'package:flutter/material.dart';
import '../models/voice_persona.dart';
import '../models/app_strings.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
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
  void initState() {
    super.initState();
    widget.ttsService.addListener(_onServiceChanged);
  }

  @override
  void didUpdateWidget(VoicePlayerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ttsService != widget.ttsService) {
      oldWidget.ttsService.removeListener(_onServiceChanged);
      widget.ttsService.addListener(_onServiceChanged);
    }
  }

  @override
  void dispose() {
    widget.ttsService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final persona = widget.ttsService.currentPersona;
    final strings = AppStrings(isArabic: widget.isArabic);

    final displayName = widget.ttsService.selectedSystemVoice?['name'] ??
        (widget.isArabic ? persona.nameArabic : persona.name);
    final displayTag = widget.isArabic ? persona.tagArabic : persona.tag;
    
    final sayItText = widget.ttsService.isPlaying
        ? strings.pause
        : widget.ttsService.isPaused
            ? strings.resumePlayback
            : strings.sayIt;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusRound)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            blurRadius: AppSizes.radiusXxl,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.xxl, AppSizes.xl, AppSizes.xxl, AppSizes.lg + AppSizes.xs),
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
                const SizedBox(height: AppSizes.lg),
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
                const SizedBox(height: AppSizes.xl),
              ],

              // Spoken word progress preview
              if (widget.ttsService.isPlaying && widget.ttsService.currentSpokenWord.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.xs),
                  decoration: BoxDecoration(
                    color: persona.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSizes.lg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.record_voice_over_rounded, size: AppSizes.iconLg, color: persona.accentColor),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        strings.speakingWord(widget.ttsService.currentSpokenWord),
                        style: TextStyle(
                          fontSize: AppSizes.fontBase,
                          fontWeight: FontWeight.bold,
                          color: persona.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],

              // Wave visualizer
              AudioVisualizer(
                isPlaying: widget.ttsService.isPlaying,
                isPaused: widget.ttsService.isPaused,
                activeColor: persona.accentColor,
                height: AppSizes.audioVisualizerH,
                barCount: 28,
              ),
              const SizedBox(height: AppSizes.lg),

              // Control Bar Row
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (c) => SystemVoiceBrowserDialog(ttsService: widget.ttsService),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.md),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                          border: Border.all(
                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: AppSizes.personaAvatarRadius,
                              backgroundColor: persona.accentColor.withValues(alpha: 0.2),
                              child: Icon(persona.icon, size: AppSizes.iconSm, color: persona.accentColor),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$displayName ${persona.gender == VoiceGender.male ? '👨' : persona.gender == VoiceGender.female ? '👩' : '🤖'}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: AppSizes.fontMdLg,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$displayTag • ${strings.tapToChange}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppSizes.fontSm,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: AppSizes.iconMd,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),

                  InkWell(
                    onTap: () {
                      setState(() => _showSpeedScroll = !_showSpeedScroll);
                    },
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.md),
                      decoration: BoxDecoration(
                        color: _showSpeedScroll
                            ? persona.accentColor.withValues(alpha: 0.18)
                            : (isDark ? AppColors.darkCard : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color: _showSpeedScroll
                              ? persona.accentColor
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed_rounded,
                            size: AppSizes.iconSm,
                            color: _showSpeedScroll ? persona.accentColor : theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            '${widget.ttsService.rate.toStringAsFixed(2)}x',
                            style: TextStyle(
                              fontSize: AppSizes.fontBase,
                              fontWeight: FontWeight.bold,
                              color: _showSpeedScroll ? persona.accentColor : theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sm),

                  IconButton(
                    tooltip: strings.adjustPitch,
                    icon: Icon(
                      Icons.tune_rounded,
                      color: _showFineTuning ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: _showFineTuning
                          ? theme.colorScheme.primary.withValues(alpha: 0.15)
                          : (isDark ? AppColors.darkCard : Colors.grey.shade100),
                    ),
                    onPressed: () {
                      setState(() => _showFineTuning = !_showFineTuning);
                    },
                  ),
                  const SizedBox(width: AppSizes.sm),

                  if (widget.ttsService.isPlaying || widget.ttsService.isPaused) ...[
                    IconButton(
                      tooltip: strings.stop,
                      icon: const Icon(Icons.stop_rounded, color: AppColors.stop),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.stop.withValues(alpha: 0.15),
                      ),
                      onPressed: () => widget.ttsService.stop(),
                    ),
                    const SizedBox(width: AppSizes.sm),
                  ],

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
                    borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.iconMd, vertical: AppSizes.xl),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            persona.accentColor,
                            persona.accentColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
                        boxShadow: [
                          BoxShadow(
                            color: persona.accentColor.withValues(alpha: 0.4),
                            blurRadius: AppSizes.radiusMd,
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
                            size: AppSizes.iconLg,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Text(
                            sayItText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: AppSizes.fontMdLg,
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
