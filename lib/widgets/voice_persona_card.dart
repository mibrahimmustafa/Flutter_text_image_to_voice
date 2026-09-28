import 'package:flutter/material.dart';
import '../models/voice_persona.dart';

class VoicePersonaCard extends StatelessWidget {
  final VoicePersona persona;
  final bool isSelected;
  final bool isArabic;
  final VoidCallback onSelect;
  final VoidCallback onPreview;

  const VoicePersonaCard({
    super.key,
    required this.persona,
    required this.isSelected,
    this.isArabic = false,
    required this.onSelect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final genderLabel = switch (persona.gender) {
      VoiceGender.male => isArabic ? '👨 رجل' : '👨 Man',
      VoiceGender.female => isArabic ? '👩 امرأة' : '👩 Woman',
      VoiceGender.neutral => isArabic ? '🤖 آلي' : '🤖 Synth',
    };

    final genderBgColor = switch (persona.gender) {
      VoiceGender.male => Colors.blue.withValues(alpha: 0.15),
      VoiceGender.female => Colors.pink.withValues(alpha: 0.15),
      VoiceGender.neutral => const Color(0xFF10B981).withValues(alpha: 0.15),
    };

    final genderTextColor = switch (persona.gender) {
      VoiceGender.male => Colors.blue.shade400,
      VoiceGender.female => Colors.pink.shade400,
      VoiceGender.neutral => const Color(0xFF10B981),
    };

    final displayName = isArabic ? persona.nameArabic : persona.name;
    final displayTag = isArabic ? persona.tagArabic : persona.tag;
    final previewText = isArabic ? 'معاينة' : 'Preview';

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 175,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? persona.accentColor.withValues(alpha: isDark ? 0.20 : 0.12)
              : (isDark ? const Color(0xFF1E2433) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? persona.accentColor
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: persona.accentColor.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Avatar with accent glow
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: persona.accentColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    persona.icon,
                    size: 18,
                    color: persona.accentColor,
                  ),
                ),
                // Gender badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: genderBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    genderLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: genderTextColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? persona.accentColor : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  displayTag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
            // Action preview button
            InkWell(
              onTap: onPreview,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? persona.accentColor
                      : theme.colorScheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.volume_up_rounded,
                      size: 13,
                      color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      previewText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
