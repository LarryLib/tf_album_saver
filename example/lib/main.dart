import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tf_album_saver/tf_album_saver.dart';
import 'package:tf_toast/Toast.dart';
import 'package:video_player/video_player.dart';

import 'VideoPlayerHelper.dart';
import 'permission.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Title',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var type = FileType.image;
  var map = {
    FileType.image: 'images/jpg.jpg',
    FileType.gif: 'images/gif.gif',
    FileType.video: 'images/video.MOV',
    FileType.pdf: 'images/pdf.pdf',
  };

  var imgType = ImageType.jpg;
  var imgMap = {
    ImageType.jpg: 'images/jpg.jpg',
    ImageType.jpeg: 'images/jpeg.jpeg',
    ImageType.png: 'images/png.png',
  };

  //
  String pdfPath;
  VideoPlayerController videoController;

  @override
  void initState() {
    super.initState();

    saveToFile();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('tf_album_saver')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (var t in map.keys)
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        width: width / map.keys.length * 0.6,
                        height: 50,
                        color: type == t ? Colors.red : Colors.transparent,
                        child:
                            Text('${t.toString().replaceAll('FileType.', '')}'),
                      ),
                      onTap: () => setState(() => type = t),
                    )
                ],
              ),
            ),
            if (type == FileType.image)
              Container(
                height: 40,
                width: width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    for (var t in imgMap.keys)
                      GestureDetector(
                        child: Container(
                          alignment: Alignment.center,
                          width: width / map.keys.length / 3.0,
                          color: imgType == t ? Colors.red : Colors.transparent,
                          child: Text(
                            '${t.toString().replaceAll('ImageType.', '')}',
                          ),
                        ),
                        onTap: () => setState(() => imgType = t),
                      )
                  ],
                ),
              ),
            Container(
              width: width * 0.8,
              height: width * 0.8,
              child: type == FileType.video
                  ? AssetPlayerLifeCycle(map[type], (context, controller) {
                      videoController = controller;
                      return AspectRatioVideo(controller);
                    })
                  : type == FileType.pdf && pdfPath != null
                      ? PdfViewer(filePath: pdfPath)
                      : Image.asset(
                          type == FileType.gif ? map[type] : imgMap[imgType],
                          width: width * 0.8,
                          height: width * 0.8,
                        ),
            ),
            FlatButton(
              color: Colors.blue,
              child: Text('Save File To Album by FilePath'),
              onPressed: () async {
                var permissionGroup = Platform.isAndroid
                    ? PermissionGroup.storage
                    : PermissionGroup.photos;
                var b = await checkAndRequest(permissionGroup);
                if (!b) {
                  Toast.show(context, title: '请开启相册访问权限，以存储照片或Gif到相册');
                  return;
                }

                print('type = ${type.index}');
                var filePath = type == FileType.image
                    ? await getFile(imgMap[imgType])
                    : await getFile(map[type]);
                var errorMsg =
                    await TfAlbumSaver.saveToAlbum(type, filePath.path);
                var ret = errorMsg == null ? 'success' : errorMsg;
                var showText = 'Save File To Album by FilePath ${ret}';
                print(showText);
                Toast.show(context, title: showText);
              },
            ),
            if (type == FileType.image)
              FlatButton(
                color: Colors.blue,
                child: Text('Save Image To Album by Bytes'),
                onPressed: () async {
                  var permissionGroup = Platform.isAndroid
                      ? PermissionGroup.storage
                      : PermissionGroup.photos;
                  var b = await checkAndRequest(permissionGroup);
                  if (!b) {
                    Toast.show(context, title: '请开启相册访问权限，以存储照片或Gif到相册');
                    return;
                  }

                  final byteData = await rootBundle.load(imgMap[imgType]);
                  final bytes = byteData.buffer.asUint8List();

                  var errorMsg =
                      await TfAlbumSaver.saveImageByBytes(bytes, type: imgType);
                  var ret = errorMsg == null ? 'success' : errorMsg;
                  var showText = 'Save Image To Album by Bytes ${ret}';
                  print(showText);
                  Toast.show(context, title: showText);
                },
              ),
          ],
        ),
        floatingActionButton: type == FileType.video && videoController != null
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    videoController.value.isPlaying
                        ? videoController.pause()
                        : videoController.play();
                  });
                },
                child: Icon(
                  videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              )
            : null,
      ),
    );
  }

  saveToFile() async {
    map.values.forEach(saveByName);
    imgMap.values.forEach(saveByName);
  }

  void saveByName(name) async {
    var file = await getFile(name);
    await file.createSync(recursive: true);
    final byteData = await rootBundle.load(name);
    final bytes = byteData.buffer.asUint8List();
    await file.writeAsBytesSync(bytes);

    print('filePath = ${file.path}');

    if (name.contains('pdf')) setState(() => pdfPath = file.path);
  }

  Future<File> getFile(String name) async {
    var documentsDir = await getApplicationDocumentsDirectory();
    return File("${documentsDir.path}/$name");
  }
}
