import 'package:flutter/material.dart';

class VoiceControlSliders extends StatelessWidget {
  final double pitch;
  final double rate;
  final double volume;
  final ValueChanged<double> onPitchChanged;
  final ValueChanged<double> onRateChanged;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onReset;

  const VoiceControlSliders({
    super.key,
    required this.pitch,
    required this.rate,
    required this.volume,
    required this.onPitchChanged,
    required this.onRateChanged,
    required this.onVolumeChanged,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181D29) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_rounded, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Voice Fine-Tuning',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded, size: 14),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pitch slider
          _buildSliderRow(
            context: context,
            label: 'Voice Pitch (Frequency)',
            icon: Icons.graphic_eq_rounded,
            value: pitch,
            min: 0.5,
            max: 2.0,
            valueDisplay: '${pitch.toStringAsFixed(2)}x ${pitch < 1.0 ? "(Deeper/Masculine)" : "(Higher/Feminine)"}',
            onChanged: onPitchChanged,
            accentColor: const Color(0xFF6366F1),
          ),
          const SizedBox(height: 10),

          // Speed slider
          _buildSliderRow(
            context: context,
            label: 'Speaking Speed (Rate)',
            icon: Icons.speed_rounded,
            value: rate,
            min: 0.25,
            max: 5.0,
            valueDisplay: '${rate.toStringAsFixed(2)}x',
            onChanged: onRateChanged,
            accentColor: const Color(0xFF0EA5E9),
          ),
          const SizedBox(height: 10),

          // Volume slider
          _buildSliderRow(
            context: context,
            label: 'Speech Volume',
            icon: Icons.volume_up_rounded,
            value: volume,
            min: 0.0,
            max: 1.0,
            valueDisplay: '${(volume * 100).toInt()}%',
            onChanged: onVolumeChanged,
            accentColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required BuildContext context,
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required String valueDisplay,
    required ValueChanged<double> onChanged,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                valueDisplay,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: accentColor,
            inactiveTrackColor: accentColor.withValues(alpha: 0.15),
            thumbColor: accentColor,
            overlayColor: accentColor.withValues(alpha: 0.2),
            trackHeight: 3.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
