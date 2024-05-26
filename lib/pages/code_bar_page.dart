import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  String title = '';
  String total = '';
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      processImage(image);
    }
  }

  Future<void> processImage(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String extractedTitle = '';
    String extractedTotal = '';

    if (recognizedText.blocks.isNotEmpty) {
      // Pega o título da primeira linha do primeiro bloco
      extractedTitle = recognizedText.blocks.first.lines.first.text;

      // Pega o total da última linha do último bloco
      String lastLine = recognizedText.blocks.last.lines.last.text;
      RegExp regExp = RegExp(r'(\d+,\d{2})');
      Match? match = regExp.firstMatch(lastLine);
      if (match != null) {
        extractedTotal = match.group(0)!;
      }
    }

    setState(() {
      title = extractedTitle;
      total = extractedTotal;
    });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitor de Imagem'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Título: $title',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            if (total.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Total: $total',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capturar Imagem'),
            ),
          ],
        ),
      ),
    );
  }
}
