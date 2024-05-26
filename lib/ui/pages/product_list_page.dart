import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductListScreen extends StatefulWidget {
  final String month;

  const ProductListScreen({super.key, required this.month});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, String>> products = [];
  double totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'data_${widget.month}';
    final List<String> productStrings = prefs.getStringList(key) ?? [];

    setState(() {
      products = productStrings
          .map((product) => Map<String, String>.from(jsonDecode(product)))
          .toList();
      totalValue = _calculateTotalValue(products);
    });
  }

  double _calculateTotalValue(List<Map<String, String>> products) {
    double total = 0.0;
    for (var product in products) {
      final val = product['total'].toString().replaceAll(",", ".");
      final value = double.tryParse(val) ?? 0.0;
      total += value;
    }
    return total;
  }

  Future<void> _deleteProduct(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'data_${widget.month}';
    products.removeAt(index);
    final updatedProductStrings =
        products.map((product) => jsonEncode(product)).toList();
    await prefs.setStringList(key, updatedProductStrings);
    setState(() {
      totalValue = _calculateTotalValue(products);
    });
  }

  Future<void> _deleteAllProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String key = 'data_${widget.month}';
    await prefs.remove(key);
    setState(() {
      products.clear();
      totalValue = 0.0;
    });
    Get.offAndToNamed("/");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos de ${widget.month}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _deleteAllProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total: R\$ ${totalValue.toStringAsFixed(2).replaceAll(".", ",")}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product['title'] ?? 'Sem título'),
                  subtitle: Text(
                    'Total: R\$ ${product['total']}, Data: ${product['date']}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteProduct(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
