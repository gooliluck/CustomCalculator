import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_handler.dart';

class WebImageHandler implements ImageHandler {
  static const String _backgroundKey = 'web_background';
  static final WebImageHandler instance = WebImageHandler._init();
  WebImageHandler._init();

  @override
  Future<String?> getCurrentBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backgroundKey);
  }

  @override
  Future<void> setCurrentBackground(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundKey, base64Image);
  }

  @override
  Future<String> saveBackgroundImage(dynamic imageData) async {
    final base64Image = imageData as String;
    await setCurrentBackground(base64Image);
    return base64Image;
  }

  @override
  Future<void> deleteBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backgroundKey);
  }
} 