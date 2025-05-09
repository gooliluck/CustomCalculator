import 'package:flutter/foundation.dart' show kIsWeb;
import 'web_image_handler.dart';
import 'background_manager.dart';

abstract class ImageHandler {
  Future<String?> getCurrentBackground();
  Future<void> setCurrentBackground(String path);
  Future<String> saveBackgroundImage(dynamic imageFile);
  Future<void> deleteBackgroundImage();
}

class PlatformImageHandler {
  static ImageHandler get instance {
    if (kIsWeb) {
      return WebImageHandler.instance;
    } else {
      return BackgroundManager.instance;
    }
  }
} 