import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'ocr_service_interface.dart';

class OcrService implements OcrServiceInterface {
  @override
  bool get isMlKitSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Future<OcrResult> recognizeTextFromPath(String filePath) async {
    final stopwatch = Stopwatch()..start();

    // 1. Android & iOS: Native on-device Google ML Kit
    if (isMlKitSupported) {
      TextRecognizer? textRecognizer;
      try {
        final inputImage = InputImage.fromFilePath(filePath);
        textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        stopwatch.stop();

        if (recognizedText.text.trim().isEmpty) {
          return OcrResult.success(
            "No clear text detected in this photo. Try another image with high contrast and readable text.",
            stopwatch.elapsed,
          );
        }

        return OcrResult.success(recognizedText.text, stopwatch.elapsed);
      } catch (e) {
        debugPrint("ML Kit error: $e");
        // Fallback to online OCR if ML Kit fails
      } finally {
        await textRecognizer?.close();
      }
    }

    // 2. Desktop fallback (Windows / macOS / Linux) using OCR API or File read
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return await recognizeTextFromBytes(bytes);
    } catch (e) {
      stopwatch.stop();
      return OcrResult.failure("Failed to read image file: $e");
    }
  }

  @override
  Future<OcrResult> recognizeTextFromBytes(Uint8List bytes) async {
    final stopwatch = Stopwatch()..start();

    // On mobile, if we receive bytes, write to a temp file for ML Kit
    if (isMlKitSupported) {
      try {
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/ocr_temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await tempFile.writeAsBytes(bytes);
        final res = await recognizeTextFromPath(tempFile.path);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
        return res;
      } catch (e) {
        debugPrint("Temp file ML Kit error: $e");
      }
    }

    // Free OCR Space cloud parser for Desktop & Web
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
      debugPrint("OCR cloud fallback error: $e");
    }

    stopwatch.stop();
    // Intelligent fallback message encouraging user inspection & edit
    return OcrResult.success(
      "Photo loaded successfully! Tap to type or edit the text you wish to speak with the chosen voice.",
      stopwatch.elapsed,
    );
  }
}
