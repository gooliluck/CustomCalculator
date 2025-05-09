import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'database/database_helper.dart';
import 'utils/image_handler.dart';
import 'history_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '';
  String? _backgroundPath;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ImageHandler _imageHandler = PlatformImageHandler.instance;

  @override
  void initState() {
    super.initState();
    _loadBackground();
  }

  Future<void> _loadBackground() async {
    final path = await _imageHandler.getCurrentBackground();
    if (path != null && mounted) {
      setState(() {
        _backgroundPath = path;
      });
    }
  }

  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && mounted) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        final savedPath = await _imageHandler.saveBackgroundImage(base64Image);
        setState(() {
          _backgroundPath = savedPath;
        });
      } else {
        final savedPath = await _imageHandler.saveBackgroundImage(File(image.path));
        setState(() {
          _backgroundPath = savedPath;
        });
      }
    }
  }

  void _onDigitPress(String digit) {
    setState(() {
      _input += digit;
    });
  }

  void _onOperatorPress(String operator) {
    setState(() {
      _input += ' $operator ';
    });
  }

  void _onClear() {
    setState(() {
      _input = '';
      _result = '';
    });
  }

  void _onCalculate() async {
    try {
      final expression = _input;
      final result = _evaluateExpression(_input);
      if (mounted) {
        setState(() {
          _result = result.toString();
        });
      }
      await _dbHelper.insertCalculation(expression, result.toString());
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Error';
        });
      }
    }
  }

  double _evaluateExpression(String expression) {
    final tokens = expression.split(' ');
    if (tokens.isEmpty) return 0;

    double result = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      final operator = tokens[i];
      final operand = double.parse(tokens[i + 1]);

      switch (operator) {
        case '+':
          result += operand;
          break;
        case '-':
          result -= operand;
          break;
        case '×':
          result *= operand;
          break;
        case '÷':
          if (operand == 0) throw Exception('Division by zero');
          result /= operand;
          break;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('計算機'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_backgroundPath != null)
            Positioned.fill(
              child: Image(
                image: kIsWeb
                    ? MemoryImage(base64Decode(_backgroundPath!.split(',')[1]))
                    : FileImage(File(_backgroundPath!)) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          if (_backgroundPath != null)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        Text(
                          _input,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildButton('7', _onDigitPress),
                                    _buildButton('8', _onDigitPress),
                                    _buildButton('9', _onDigitPress),
                                    _buildButton('÷', _onOperatorPress),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildButton('4', _onDigitPress),
                                    _buildButton('5', _onDigitPress),
                                    _buildButton('6', _onDigitPress),
                                    _buildButton('×', _onOperatorPress),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildButton('1', _onDigitPress),
                                    _buildButton('2', _onDigitPress),
                                    _buildButton('3', _onDigitPress),
                                    _buildButton('-', _onOperatorPress),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildButton('0', _onDigitPress),
                                    _buildButton('C', (_) => _onClear()),
                                    _buildButton('=', (_) => _onCalculate()),
                                    _buildButton('+', _onOperatorPress),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndCropImage,
        child: const Icon(Icons.image),
      ),
    );
  }

  Widget _buildButton(String text, Function(String) onPressed) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => onPressed(text),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black,
                  offset: Offset(2.0, 2.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
