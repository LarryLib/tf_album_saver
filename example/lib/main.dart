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
  var type = FileType.jpg;
  var map = {
    FileType.jpg: 'images/jpg.jpg',
    FileType.jpeg: 'images/jpeg.jpeg',
    FileType.png: 'images/png.png',
    FileType.gif: 'images/gif.gif',
    FileType.pdf: 'images/pdf.pdf',
    FileType.video: 'images/video.MOV',
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
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (var t in map.keys)
                    GestureDetector(
                      child: Container(
                        alignment: Alignment.center,
                        width: width / map.keys.length * 0.8,
                        color: type == t ? Colors.red : Colors.transparent,
                        child:
                            Text('${t.toString().replaceAll('FileType.', '')}'),
                      ),
                      onTap: () => setState(() => type = t),
                    )
                ],
              ),
            ),
            Container(
              width: width * 0.8,
              height: width * 0.8,
              child: type == FileType.video
                  ? AssetPlayerLifeCycle('images/video.MOV',
                      (context, controller) {
                      videoController = controller;
                      return AspectRatioVideo(controller);
                    })
                  : type == FileType.pdf && pdfPath != null
                      ? PdfViewer(filePath: pdfPath)
                      : Image.asset(
                          map[type],
                          width: width * 0.8,
                          height: width * 0.8,
                        ),
            ),
            FlatButton(
              color: Colors.blue,
              child: Text('Save To Album'),
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
                var filePath = await getFile(map[type]);
                var errorMsg =
                    await TfAlbumSaver.saveToAlbum(type, filePath.path);
                var showText =
                    'Save To Album ${errorMsg == null ? 'success' : errorMsg}';
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
    map.values.forEach((name) async {
      var file = await getFile(name);
      await file.createSync(recursive: true);
      final byteData = await rootBundle.load(name);
      final bytes = byteData.buffer.asUint8List();
      await file.writeAsBytesSync(bytes);

      print(file.path);

      if (name.contains('pdf'))
        setState(() {
          pdfPath = file.path;
        });
    });
  }

  Future<File> getFile(String name) async {
    var documentsDir = await getApplicationDocumentsDirectory();
    return File("${documentsDir.path}/$name");
  }
}
