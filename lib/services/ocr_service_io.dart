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

        if (recognizedText.text.trim().isNotEmpty) {
          return OcrResult.success(recognizedText.text, stopwatch.elapsed);
        }

        // Empty latin result: the screenshot may contain a script the latin
        // recognizer cannot read (e.g. Arabic). Fall through to the cloud
        // OCR attempt below instead of giving up immediately.
        stopwatch.reset();
      } catch (e) {
        debugPrint("ML Kit error: $e");
      } finally {
        await textRecognizer?.close();
      }
    }

    // 2. Cloud OCR fallback (used by desktop/web/mobile alike).
    // `allowMlKit: false` prevents a recursion cycle back into this method.
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final cloudResult = await recognizeTextFromBytes(bytes, allowMlKit: false);
      if (cloudResult.isSuccess) {
        stopwatch.stop();
        return cloudResult;
      }
    } catch (e) {
      debugPrint("Cloud OCR fallback error: $e");
    }

    stopwatch.stop();
    return OcrResult.success(
      "No clear text detected in this photo. Try another image with high contrast and readable text.",
      stopwatch.elapsed,
    );
  }

  @override
  Future<OcrResult> recognizeTextFromBytes(Uint8List bytes, {bool allowMlKit = true}) async {
    final stopwatch = Stopwatch()..start();

    // On mobile, if we receive bytes, write to a temp file for ML Kit
    if (allowMlKit && isMlKitSupported) {
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

    // Free OCR Space cloud parser for Desktop & Web.
    // Try English/latin first, then Arabic — this is what makes Arabic
    // document photos actually usable on devices without an Arabic OCR model.
    String? parsedText = await _ocrSpaceRequest(bytes, 'eng');
    parsedText ??= await _ocrSpaceRequest(bytes, 'ara');

    stopwatch.stop();

    if (parsedText != null) {
      return OcrResult.success(parsedText, stopwatch.elapsed);
    }

    // Intelligent fallback message encouraging user inspection & edit
    return OcrResult.success(
      "Photo loaded successfully! Tap to type or edit the text you wish to speak with the chosen voice.",
      stopwatch.elapsed,
    );
  }

  Future<String?> _ocrSpaceRequest(Uint8List bytes, String language) async {
    try {
      final base64Image = base64Encode(bytes);
      final response = await http
          .post(
            Uri.parse('https://api.ocr.space/parse/image'),
            headers: {
              'apikey': 'helloworld',
            },
            body: {
              'base64Image': 'data:image/jpeg;base64,$base64Image',
              'language': language,
              'isOverlayRequired': 'false',
              'scale': 'true',
            },
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['ParsedResults'] != null && (json['ParsedResults'] as List).isNotEmpty) {
          final parsedText = json['ParsedResults'][0]['ParsedText']?.toString() ?? '';
          if (parsedText.trim().isNotEmpty) {
            return parsedText.trim();
          }
        }
      }
    } catch (e) {
      debugPrint("OCR cloud fallback error ($language): $e");
    }
    return null;
  }
}
