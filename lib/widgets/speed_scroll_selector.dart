import 'package:flutter/material.dart';

class SpeedPreset {
  final double rate;
  final String label;
  final String icon;

  const SpeedPreset({
    required this.rate,
    required this.label,
    required this.icon,
  });

  static const List<SpeedPreset> presets = [
    SpeedPreset(rate: 0.25, label: '0.25x', icon: '🐌'),
    SpeedPreset(rate: 0.50, label: '0.50x', icon: '🐢'),
    SpeedPreset(rate: 0.75, label: '0.75x', icon: '☕'),
    SpeedPreset(rate: 1.00, label: '1.00x', icon: '✨'),
    SpeedPreset(rate: 1.25, label: '1.25x', icon: '⚡'),
    SpeedPreset(rate: 1.50, label: '1.50x', icon: '🏃'),
    SpeedPreset(rate: 2.00, label: '2.00x', icon: '🚀'),
    SpeedPreset(rate: 2.50, label: '2.50x', icon: '🏎️'),
    SpeedPreset(rate: 3.00, label: '3.00x', icon: '🛸'),
    SpeedPreset(rate: 3.50, label: '3.50x', icon: '🌪️'),
    SpeedPreset(rate: 4.00, label: '4.00x', icon: '⚡'),
    SpeedPreset(rate: 5.00, label: '5.00x', icon: '🌌'),
  ];
}

class SpeedScrollSelector extends StatelessWidget {
  final double currentRate;
  final ValueChanged<double> onRateChanged;
  final Color accentColor;
  final bool showSlider;

  const SpeedScrollSelector({
    super.key,
    required this.currentRate,
    required this.onRateChanged,
    this.accentColor = const Color(0xFF6366F1),
    this.showSlider = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with active speed readout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.speed_rounded, size: 16, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  'Voice Speed Scroll',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${currentRate.toStringAsFixed(2)}x Speed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Horizontal Scrollable Speed Presets Dial
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: SpeedPreset.presets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final preset = SpeedPreset.presets[index];
              final isSelected = (currentRate - preset.rate).abs() < 0.06;

              return InkWell(
                onTap: () => onRateChanged(preset.rate),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor
                        : (isDark ? const Color(0xFF1E2433) : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? accentColor
                          : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(preset.icon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        preset.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Continuous Slider Wheel
        if (showSlider) ...[
          const SizedBox(height: 4),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: accentColor,
              inactiveTrackColor: accentColor.withValues(alpha: 0.15),
              thumbColor: accentColor,
              overlayColor: accentColor.withValues(alpha: 0.2),
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: currentRate.clamp(0.25, 5.0),
              min: 0.25,
              max: 5.0,
              divisions: 95,
              onChanged: onRateChanged,
            ),
          ),
        ],
      ],
    );
  }
}
