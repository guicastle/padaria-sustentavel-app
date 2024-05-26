import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  List<String> months = [];
  Map<String, double> monthTotals = {};

  @override
  void initState() {
    super.initState();
    _loadMonths();
  }

  Future<void> _loadMonths() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final monthKeys = keys.where((key) => key.startsWith('data_')).toList();

    Map<String, double> totals = {};
    for (var key in monthKeys) {
      final List<String> productStrings = prefs.getStringList(key) ?? [];
      double total = 0.0;
      for (var productString in productStrings) {
        final product = Map<String, String>.from(jsonDecode(productString));
        final val = product['total'].toString().replaceAll(",", ".");
        final value = double.tryParse(val) ?? 0.0;
        total += value;
      }
      totals[key.replaceFirst('data_', '')] = total;
    }

    setState(() {
      months = monthKeys.map((key) => key.replaceFirst('data_', '')).toList();
      monthTotals = totals;
    });
  }

  Future<void> _exportMonth(String month) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'data_$month';
    final List<String> productStrings = prefs.getStringList(key) ?? [];

    String exportText = 'Produtos de $month:\n\n';
    for (var productString in productStrings) {
      final product = Map<String, String>.from(jsonDecode(productString));
      exportText += 'Título: ${product['title']}\n';
      exportText += 'Total: R\$ ${product['total']}\n';
      exportText += 'Data: ${product['date']}\n\n';
    }
    exportText +=
        'Total do mês: R\$ ${monthTotals[month]?.toStringAsFixed(2).replaceAll(".", ",")}';

    Share.share(exportText, subject: 'Produtos de $month');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exportar Dados'),
      ),
      body: ListView.builder(
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final total =
              monthTotals[month]?.toStringAsFixed(2).replaceAll(".", ",") ??
                  '0,00';
          return ListTile(
            title: Text('$month - Total: R\$ $total'),
            trailing: ElevatedButton(
              onPressed: () {
                _exportMonth(month);
              },
              child: const Text('Exportar'),
            ),
          );
        },
      ),
    );
  }
}
