import 'dart:typed_data';
import 'package:flutter/services.dart';

enum FileType {
  image,  //  0
  gif,    //  1
  video,  //  2
  pdf,    //  3
}

enum ImageType {
  jpg,  //  0
  jpeg, //  1
  png,  //  2
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

  static Future<String> saveImageByBytes(
    Uint8List imageBytes, {
    ImageType type = ImageType.jpg,
  }) async {
    return await _channel.invokeMethod(
      'saveImageByBytes',
      {
        'suffix': type.toString().split('.').last,
        'imageBytes': imageBytes,
      },
    );
  }
}
