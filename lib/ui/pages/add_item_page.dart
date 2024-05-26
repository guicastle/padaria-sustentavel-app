import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:padaria_sustentavel_app/ui/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../utils/colors_util.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  Future<void> pickImage() async {
    setState(() {
      _isLoading = true;
    });
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await processImage(image);
    }

    setState(() {
      _isLoading = false;
    });
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

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'data_$month';
    List<String> existingData = prefs.getStringList(key) ?? [];

    Map<String, String> newData = {
      'title': title,
      'total': total,
      'date': date,
    };
    existingData.add(jsonEncode(newData));
    await prefs.setStringList(key, existingData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados salvos com sucesso')),
    );

    await _sortAndSaveMonths(prefs);
  }

  Future<void> _sortAndSaveMonths(SharedPreferences prefs) async {
    final keys = prefs.getKeys();
    final monthKeys = keys.where((key) => key.startsWith('data_')).toList();
    final months =
        monthKeys.map((key) => key.replaceFirst('data_', '')).toList();

    months.sort((a, b) => _monthToNumber(b).compareTo(_monthToNumber(a)));

    await prefs.setStringList('sorted_months', months);
  }

  int _monthToNumber(String month) {
    switch (month.toLowerCase()) {
      case 'janeiro':
        return 1;
      case 'fevereiro':
        return 2;
      case 'março':
        return 3;
      case 'abril':
        return 4;
      case 'maio':
        return 5;
      case 'junho':
        return 6;
      case 'julho':
        return 7;
      case 'agosto':
        return 8;
      case 'setembro':
        return 9;
      case 'outubro':
        return 10;
      case 'novembro':
        return 11;
      case 'dezembro':
        return 12;
      default:
        return 0;
    }
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
    return _isLoading == false
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Adicionar item'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Get.toNamed("/");
                },
              ),
            ),
            body: Stack(
              children: [
                SingleChildScrollView(
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
                          decoration:
                              const InputDecoration(labelText: 'Título'),
                        ),
                        TextField(
                          controller: _totalController,
                          decoration: const InputDecoration(labelText: 'Total'),
                          keyboardType: TextInputType.number,
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
              ],
            ))
        : Scaffold(
            appBar: AppBar(
              title: const Text('Adicionando item...'),
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
  }
}
