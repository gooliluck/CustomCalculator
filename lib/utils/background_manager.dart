import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'image_handler.dart';

class BackgroundManager implements ImageHandler {
  static const String _backgroundKey = 'current_background';
  static final BackgroundManager instance = BackgroundManager._init();
  BackgroundManager._init();

  @override
  Future<String?> getCurrentBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backgroundKey);
  }

  @override
  Future<void> setCurrentBackground(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundKey, path);
  }

  @override
  Future<String> saveBackgroundImage(dynamic imageFile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final backgroundDir = Directory('${appDir.path}/backgrounds');
    if (!await backgroundDir.exists()) {
      await backgroundDir.create(recursive: true);
    }

    final fileName = 'background_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = File('${backgroundDir.path}/$fileName');
    await (imageFile as File).copy(savedFile.path);
    return savedFile.path;
  }

  @override
  Future<void> deleteBackgroundImage() async {
    final path = await getCurrentBackground();
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
} 