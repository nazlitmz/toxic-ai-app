import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

class ShareService {
  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (status.isGranted) return true;

      // Android 13+ için
      final photos = await Permission.photos.request();
      return photos.isGranted;
    }
    return true;
  }

  static Future<Uint8List?> captureFromKey(GlobalKey key) async {
    try {
      RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing: $e');
      return null;
    }
  }

  static Future<String?> saveToFile(Uint8List imageBytes) async {
    try {
      final directory = await getTemporaryDirectory();
      final fileName = 'toxic_ai_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  static Future<void> shareFromKey(GlobalKey key) async {
    final imageBytes = await captureFromKey(key);
    if (imageBytes == null) return;

    final filePath = await saveToFile(imageBytes);
    if (filePath != null) {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Check your toxicity at toxicai.app! ☠️',
      );
    }
  }

  static Future<bool> saveToGalleryFromKey(GlobalKey key) async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) return false;

    try {
      final imageBytes = await captureFromKey(key);
      if (imageBytes == null) return false;

      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: 'toxic_ai_${DateTime.now().millisecondsSinceEpoch}',
      );

      return result['isSuccess'] ?? false;
    } catch (e) {
      debugPrint('Error saving to gallery: $e');
      return false;
    }
  }
}
