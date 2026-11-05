import 'dart:ui';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../core/utils/translit_helper.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String?> pickAndRecognizeText() async {
    // 1. Открываем галерею для выбора скриншота
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null; // Пользователь отменил выбор

    // 2. Распознаем текст с картинки через ML Kit
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    try {
      // Распознаем текст с картинки
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // String readableText = TranslitHelper.normalize(recognizedText.text);
      final String cyrillicText = TranslitHelper.toCyrillic(recognizedText.text);

      // Возвращаем сырой текст
      return cyrillicText;
    } catch (e) {
      print('Ошибка OCR: $e');
      return null;
    }
  }

  void checkPhoneLocale() {
    final Locale deviceLocale = ui.PlatformDispatcher.instance.locale;
    print('Текущий язык телефона: ${deviceLocale.languageCode}');
  }

  void dispose() {
    _textRecognizer.close();
  }
}