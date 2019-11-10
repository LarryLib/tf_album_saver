import 'dart:typed_data';
import 'package:flutter/services.dart';

enum FileType {
  image,
  gif,
  pdf,
  video,
}

class TfAlbumSaver {
  static const MethodChannel _channel =
      const MethodChannel('tf_album_saver_channel');

  static Future<String> saveToAlbum(FileType type, String filePath) async {
    if (type == FileType.pdf) return '';
    return await _channel.invokeMethod(
      'saveToAlbum',
      {
        'type': type.index,
        'filePath': filePath,
      },
    );
  }

  static Future<String> saveImageByBytes(Uint8List imageBytes) async {
    return await _channel.invokeMethod(
      'saveImageByBytes',
      {
        'imageBytes': imageBytes,
      },
    );
  }
}
