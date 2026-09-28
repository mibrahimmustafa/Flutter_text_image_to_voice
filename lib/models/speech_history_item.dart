enum HistorySourceType {
  photo,
  textInput,
  samplePreset,
}

class SpeechHistoryItem {
  final String id;
  final String text;
  final HistorySourceType source;
  final String? imagePath;
  final String? imagePreviewUrl;
  final DateTime timestamp;
  final String voicePersonaName;

  SpeechHistoryItem({
    required this.id,
    required this.text,
    required this.source,
    this.imagePath,
    this.imagePreviewUrl,
    required this.timestamp,
    required this.voicePersonaName,
  });

  String get shortPreview {
    if (text.length <= 60) return text;
    return '${text.substring(0, 57)}...';
  }

  int get wordCount {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
