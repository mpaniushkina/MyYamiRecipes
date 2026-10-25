import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String?> pickAndRecognizeText() async {
    // 1. Открываем галерею для выбора скриншота
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null; // Пользователь отменил выбор

    // 2. Распознаем текст с картинки через ML Kit
    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    return recognizedText.text;
  }

  void dispose() {
    _textRecognizer.close();
  }
}