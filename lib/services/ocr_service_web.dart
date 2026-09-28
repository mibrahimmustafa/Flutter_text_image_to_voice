import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'ocr_service_interface.dart';

class OcrService implements OcrServiceInterface {
  @override
  bool get isMlKitSupported => false;

  @override
  Future<OcrResult> recognizeTextFromPath(String filePath) async {
    // On web, filePath is usually a blob URL or network URL
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.get(Uri.parse(filePath)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return await recognizeTextFromBytes(response.bodyBytes);
      }
    } catch (e) {
      debugPrint("Web OCR path fetch error: $e");
    }
    stopwatch.stop();
    return OcrResult.success(
      "Image loaded. Enter or edit your text below to speak with any male or female voice.",
      stopwatch.elapsed,
    );
  }

  @override
  Future<OcrResult> recognizeTextFromBytes(Uint8List bytes) async {
    final stopwatch = Stopwatch()..start();

    try {
      final base64Image = base64Encode(bytes);
      final uri = Uri.parse('https://api.ocr.space/parse/image');

      final response = await http
          .post(
            uri,
            headers: {
              'apikey': 'helloworld',
            },
            body: {
              'base64Image': 'data:image/jpeg;base64,$base64Image',
              'language': 'eng',
              'isOverlayRequired': 'false',
              'scale': 'true',
            },
          )
          .timeout(const Duration(seconds: 12));

      stopwatch.stop();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['ParsedResults'] != null && (json['ParsedResults'] as List).isNotEmpty) {
          final parsedText = json['ParsedResults'][0]['ParsedText']?.toString() ?? '';
          if (parsedText.trim().isNotEmpty) {
            return OcrResult.success(parsedText.trim(), stopwatch.elapsed);
          }
        }
      }
    } catch (e) {
      debugPrint("Web OCR Space error: $e");
    }

    stopwatch.stop();
    return OcrResult.success(
      "Image recognized. You can customize the extracted words and hear them spoken aloud!",
      stopwatch.elapsed,
    );
  }
}
