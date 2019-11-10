import 'dart:typed_data';
import 'package:flutter/services.dart';

enum FileType {
  jpg,  //  0
  jpeg, //  1
  png,  //  2
  gif,  //  3
  video,//  4
  pdf,  //  5
}

class TfAlbumSaver {
  static const MethodChannel _channel =
      const MethodChannel('tf_album_saver_channel');

  static Future<String> saveToAlbum(FileType type, String filePath) async {
    if (type == FileType.pdf) return 'Does not support pdf';
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
