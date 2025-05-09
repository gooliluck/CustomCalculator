import 'package:flutter/material.dart';
import 'database/database_helper.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _calculations = [];

  @override
  void initState() {
    super.initState();
    _loadCalculations();
  }

  Future<void> _loadCalculations() async {
    final calculations = await _dbHelper.getCalculations();
    setState(() {
      _calculations = calculations;
    });
  }

  Future<void> _deleteCalculation(int id) async {
    await _dbHelper.deleteCalculation(id);
    await _loadCalculations();
  }

  Future<void> _clearAllCalculations() async {
    await _dbHelper.clearAllCalculations();
    await _loadCalculations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('計算歷史'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearAllCalculations,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _calculations.length,
        itemBuilder: (context, index) {
          final calculation = _calculations[index];
          return Dismissible(
            key: Key(calculation['id'].toString()),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteCalculation(calculation['id']);
            },
            child: ListTile(
              title: Text(calculation['expression']),
              subtitle: Text(calculation['result']),
              trailing: Text(
                DateTime.fromMillisecondsSinceEpoch(calculation['timestamp'])
                    .toString()
                    .split('.')[0],
              ),
            ),
          );
        },
      ),
    );
  }
} 