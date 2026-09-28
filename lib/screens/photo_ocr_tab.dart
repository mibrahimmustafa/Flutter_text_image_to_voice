import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../models/preset_demo_photo.dart';
import '../models/voice_persona.dart';
import '../services/ocr_service.dart';
import '../services/tts_service.dart';
import '../widgets/preset_photo_carousel.dart';
import '../widgets/speed_scroll_selector.dart';
import '../widgets/voice_persona_card.dart';

class PhotoOcrTab extends StatefulWidget {
  final TextEditingController textController;
  final TtsService ttsService;
  final ValueChanged<String> onTextUpdated;
  final VoidCallback onTriggerSpeak;

  const PhotoOcrTab({
    super.key,
    required this.textController,
    required this.ttsService,
    required this.onTextUpdated,
    required this.onTriggerSpeak,
  });

  @override
  State<PhotoOcrTab> createState() => _PhotoOcrTabState();
}

class _PhotoOcrTabState extends State<PhotoOcrTab> {
  final OcrService _ocrService = OcrService();
  final ImagePicker _picker = ImagePicker();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _selectedPresetId;
  bool _isProcessingOcr = false;
  Duration? _lastOcrDuration;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 88,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = file.name;
          _selectedPresetId = null;
        });

        await _processOcr(bytes: bytes, filePath: file.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access camera/gallery: $e')),
        );
      }
    }
  }

  Future<void> _pickFromFilePicker() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.image,
      );

      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = file.name;
          _selectedPresetId = null;
        });

        await _processOcr(bytes: bytes, filePath: file.path);
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  Future<void> _loadPreset(PresetDemoPhoto preset) async {
    setState(() {
      _selectedPresetId = preset.id;
      _selectedImageName = preset.title;
      _isProcessingOcr = true;
    });

    try {
      // Fetch image bytes for preview
      final response = await http.get(Uri.parse(preset.imageUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        setState(() {
          _selectedImageBytes = response.bodyBytes;
        });
      }
    } catch (e) {
      debugPrint("Failed to load preset image: $e");
    }

    // Apply the accurate sample text
    widget.textController.text = preset.extractedText;
    widget.onTextUpdated(preset.extractedText);

    setState(() {
      _isProcessingOcr = false;
      _lastOcrDuration = const Duration(milliseconds: 320);
    });
  }

  Future<void> _processOcr({required Uint8List bytes, String? filePath}) async {
    setState(() {
      _isProcessingOcr = true;
    });

    try {
      OcrResult result;
      if (!kIsWeb && filePath != null && filePath.isNotEmpty && _ocrService.isMlKitSupported) {
        result = await _ocrService.recognizeTextFromPath(filePath);
      } else {
        result = await _ocrService.recognizeTextFromBytes(bytes);
      }

      if (result.isSuccess && result.text.isNotEmpty) {
        widget.textController.text = result.text;
        widget.onTextUpdated(result.text);
        setState(() {
          _lastOcrDuration = result.processingTime;
        });
      }
    } catch (e) {
      debugPrint("OCR processing error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
        });
      }
    }
  }

  void _clearImageAndText() {
    setState(() {
      _selectedImageBytes = null;
      _selectedImageName = null;
      _selectedPresetId = null;
      _lastOcrDuration = null;
    });
    widget.textController.clear();
    widget.onTextUpdated('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final wordCount = widget.textController.text.trim().isEmpty
        ? 0
        : widget.textController.text.trim().split(RegExp(r'\s+')).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Buttons: Camera & Gallery & File
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: 'Take Photo',
                  subtitle: 'Use Camera',
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFF6366F1),
                  onTap: () => _pickImage(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: 'Choose Photo',
                  subtitle: 'From Gallery',
                  icon: Icons.photo_library_rounded,
                  color: const Color(0xFFEC4899),
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ),
              if (kIsWeb || !kIsWeb) ...[
                const SizedBox(width: 12),
                InkWell(
                  onTap: _pickFromFilePicker,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2433) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: const Icon(Icons.folder_open_rounded, size: 24),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),

          // Preset demo carousel for 1-tap testing
          PresetPhotoCarousel(
            selectedPresetId: _selectedPresetId,
            onSelect: _loadPreset,
          ),
          const SizedBox(height: 20),

          // Photo Preview (if photo selected)
          if (_selectedImageBytes != null) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Stack(
                  children: [
                    Image.memory(
                      _selectedImageBytes!,
                      height: 190,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    // Header bar on image
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: Colors.greenAccent),
                                const SizedBox(width: 5),
                                Text(
                                  _selectedImageName ?? 'Captured Photo',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: _clearImageAndText,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // OCR Processing overlay
                    if (_isProcessingOcr)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.6),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                SizedBox(height: 12),
                                Text(
                                  'Extracting text from photo...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Voice Personas Selector ("multiple sounds man and women")
          _buildVoicePersonaSelector(context),
          const SizedBox(height: 20),

          // Extracted Text Card & Editor
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
                // Header with word count and stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.text_fields_rounded, size: 18, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Recognized Text',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (_lastOcrDuration != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${_lastOcrDuration!.inMilliseconds}ms',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$wordCount words • ${widget.textController.text.length} chars',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, size: 16),
                          tooltip: 'Copy text',
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            if (widget.textController.text.isNotEmpty) {
                              Clipboard.setData(ClipboardData(text: widget.textController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied text to clipboard!'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Editable text box
                TextField(
                  controller: widget.textController,
                  maxLines: 6,
                  minLines: 3,
                  onChanged: (val) {
                    widget.onTextUpdated(val);
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 14, height: 1.45),
                  decoration: InputDecoration(
                    hintText: 'Recognized text from photo appears here. You can also edit, paste, or type directly...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF131722) : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

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
                const SizedBox(height: 14),

                // Speak with chosen voice CTA button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.textController.text.trim().isEmpty ? null : widget.onTriggerSpeak,
                    icon: Icon(
                      widget.ttsService.isPlaying ? Icons.pause_rounded : Icons.record_voice_over_rounded,
                      size: 20,
                    ),
                    label: Text(
                      widget.ttsService.isPlaying
                          ? 'Pause Playback'
                          : 'Speak Extracted Text with ${widget.ttsService.currentPersona.name} (${widget.ttsService.currentPersona.gender == VoiceGender.male ? "Man" : "Woman"})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.ttsService.currentPersona.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Bottom padding for sticky player
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
                      ? "Hi, I'm ${persona.name}. I will read your photo text with a masculine voice."
                      : "Hello, I am ${persona.name}. I will speak your photo text with an elegant feminine voice.";
                  await widget.ttsService.speak(previewText);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2433) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
