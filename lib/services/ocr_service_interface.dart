import 'dart:typed_data';

class OcrResult {
  final String text;
  final List<String> lines;
  final Duration processingTime;
  final bool isSuccess;
  final String? errorMessage;

  OcrResult({
    required this.text,
    required this.lines,
    required this.processingTime,
    required this.isSuccess,
    this.errorMessage,
  });

  factory OcrResult.success(String text, Duration duration) {
    final cleanedLines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    return OcrResult(
      text: text.trim(),
      lines: cleanedLines,
      processingTime: duration,
      isSuccess: true,
    );
  }

  factory OcrResult.failure(String error) {
    return OcrResult(
      text: '',
      lines: [],
      processingTime: Duration.zero,
      isSuccess: false,
      errorMessage: error,
    );
  }
}

abstract class OcrServiceInterface {
  Future<OcrResult> recognizeTextFromPath(String filePath);
  Future<OcrResult> recognizeTextFromBytes(Uint8List bytes);
  bool get isMlKitSupported;
}
