import 'package:flutter/material.dart';
import 'package:padaria_sustentavel_app/ui/pages/product_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> months = [];

  @override
  void initState() {
    super.initState();
    _loadMonths();
  }

  Future<void> _loadMonths() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final monthKeys = keys.where((key) => key.startsWith('data_')).toList();

    setState(() {
      months = monthKeys.map((key) => key.replaceFirst('data_', '')).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meses Salvos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: months.length,
          itemBuilder: (context, index) {
            final month = months[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListScreen(month: month),
                  ),
                );
              },
              child: Card(
                child: Center(
                  child: Text(
                    month,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
