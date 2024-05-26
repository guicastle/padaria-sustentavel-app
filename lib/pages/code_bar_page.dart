import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  String scannedCode = '';
  List<String> scannedCodes = [];

  Future<void> readQRCode() async {
    try {
      String code = await FlutterBarcodeScanner.scanBarcode(
        "#FFFFFF",
        "Cancelar",
        false,
        ScanMode.BARCODE,
      );

      if (code != '-1') {
        setState(() {
          scannedCode = code;
          if (!scannedCodes.contains(code)) {
            scannedCodes.add(code);
          }
        });
      } else {
        setState(() {
          scannedCode = 'Não validado';
        });
      }
    } catch (e) {
      setState(() {
        scannedCode = 'Erro ao ler o código: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitor de Código de Barras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (scannedCode.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Código: $scannedCode',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ElevatedButton.icon(
              onPressed: readQRCode,
              icon: const Icon(Icons.qr_code),
              label: const Text('Ler Código de Barras'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: scannedCodes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(scannedCodes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
