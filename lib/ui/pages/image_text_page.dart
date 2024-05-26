import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/colors_util.dart';

class ImageTextPage extends StatefulWidget {
  ImageTextPage({super.key});

  @override
  State<ImageTextPage> createState() => _ImageTextPageState();
}

class _ImageTextPageState extends State<ImageTextPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

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
      _titleController.text = extractedTitle;
      _totalController.text = extractedTotal;
    });

    textRecognizer.close();
  }

  Future<void> saveData() async {
    final String title = _titleController.text;
    final String total = _totalController.text;
    final String date = _dateController.text;

    if (title.isEmpty || total.isEmpty || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    final DateTime parsedDate = DateTime.parse(date);
    final String month = _getMonthName(parsedDate.month);

    // Obter instância do SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Criar uma chave única para o mês
    final String key = 'data_$month';

    // Recuperar dados existentes para o mês
    List<String> existingData = prefs.getStringList(key) ?? [];

    // Adicionar novos dados
    Map<String, String> newData = {
      'title': title,
      'total': total,
      'date': date,
    };
    existingData.add(jsonEncode(newData));

    // Salvar dados atualizados no SharedPreferences
    await prefs.setStringList(key, existingData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados salvos com sucesso')),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitor de Imagem'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Data'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateController.text =
                          pickedDate.toString().split(' ')[0];
                    });
                  }
                },
              ),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              TextField(
                controller: _totalController,
                decoration: const InputDecoration(labelText: 'Total'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capturar Imagem'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveData,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      AppColors.primary,
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
