import 'package:flutter/material.dart';
import '../models/preset_demo_photo.dart';

class PresetPhotoCarousel extends StatelessWidget {
  final ValueChanged<PresetDemoPhoto> onSelect;
  final String? selectedPresetId;
  final bool isArabic;

  const PresetPhotoCarousel({
    super.key,
    required this.onSelect,
    this.selectedPresetId,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final samples = PresetDemoPhoto.getSamples(isArabic);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    isArabic ? 'نماذج سريعة للاختبار' : 'Quick Test Samples',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Text(
                isArabic ? 'اضغط لتجربة الصوت' : 'Tap to test OCR & Voice',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: samples.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final preset = samples[index];
              final isSelected = selectedPresetId == preset.id;

              return InkWell(
                onTap: () => onSelect(preset),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      children: [
                        // Background image
                        Positioned.fill(
                          child: Image.network(
                            preset.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: isDark ? const Color(0xFF232938) : Colors.grey.shade300,
                              child: const Icon(Icons.image_rounded, size: 36),
                            ),
                          ),
                        ),
                        // Gradient shadow
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Category Badge
                        Positioned(
                          top: 8,
                          left: isArabic ? null : 8,
                          right: isArabic ? 8 : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              preset.category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Title and prompt
                        Positioned(
                          bottom: 8,
                          left: 10,
                          right: 10,
                          child: Column(
                            crossAxisAlignment: isArabic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                preset.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: isArabic ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
                                    size: 13,
                                    color: isSelected ? Colors.greenAccent : Colors.white70,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isSelected ? (isArabic ? 'تم الاختيار' : 'Selected') : (isArabic ? 'اضغط للفحص' : 'Tap to scan'),
                                    style: TextStyle(
                                      color: isSelected ? Colors.greenAccent : Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
