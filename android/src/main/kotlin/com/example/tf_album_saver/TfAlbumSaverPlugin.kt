package com.example.tf_album_saver

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException

class TfAlbumSaverPlugin : MethodCallHandler {

    companion object {
        lateinit var tfRegistrar: Registrar

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            tfRegistrar = registrar
            val channel = MethodChannel(registrar.messenger(), "tf_album_saver_channel")
            channel.setMethodCallHandler(TfAlbumSaverPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "saveToAlbum" -> {
                val fileType = call.argument<Int>("type")!!
                val filePath = call.argument<String>("filePath")!!
                val file = File(filePath)
                val separate1 = filePath.split("/".toRegex())
                var fileName = System.currentTimeMillis().toString() + separate1.last()

                when (fileType) {
                    0 -> {
                        MediaStore.Images.Media.insertImage(tfRegistrar.context().getContentResolver(), file.getAbsolutePath(), fileName, null);
                        notiAlbum(file)
                        result.success(null)
                    }
                    1, 2 -> {
                        val newFile = getNewFileAndName(fileName)
                        copyFile(file.path, newFile.path)
                        val uri = Uri.fromFile(newFile)
                        tfRegistrar.activeContext().sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
                        result.success(null)
                    }
                    else -> result.success(null)
                }
            }
            "saveImageByBytes" -> {
                val bytes = call.argument<ByteArray>("imageBytes")
                val suffix = call.argument<String>("suffix")!!
                val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes!!.size)
                saveImageToGallery(bitmap, suffix)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    //  保存图片(bytes),并通知更新
    fun saveImageToGallery(bmp: Bitmap, suffix: String) {
        val fileName = System.currentTimeMillis().toString() + "." + suffix
        var type = Bitmap.CompressFormat.JPEG
        if (suffix == "PNG") type = Bitmap.CompressFormat.PNG   //  TODO Fix WEBP
        val file = getNewFileAndName(fileName)
        try {
            val fos = FileOutputStream(file)
            //通过io流的方式来压缩保存图片
            bmp.compress(type, 60, fos)
            fos.flush()
            fos.close()

            //把文件插入到系统图库
            MediaStore.Images.Media.insertImage(tfRegistrar.context().getContentResolver(), file.getAbsolutePath(), fileName, null);
            notiAlbum(file)
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    private fun getNewFileAndName(fileName: String): File {
        val storePath = Environment.getExternalStorageDirectory().absolutePath + File.separator
        val appDir = File(storePath)
        if (!appDir.exists()) appDir.mkdir()
        val file = File(appDir, fileName)
        return file
    }

    fun copyFile(oldPath: String, newPath: String) {
        try {
            var bytesum = 0
            var byteread = 0
            val oldfile = File(oldPath)
            if (oldfile.exists()) { //文件存在时
                val inStream = FileInputStream(oldPath) //读入原文件
                val fs = FileOutputStream(newPath)
                val buffer = ByteArray(1444)
                byteread = inStream.read(buffer)
                while (byteread != -1) {
                    bytesum += byteread //字节数 文件大小
                    println(bytesum)
                    fs.write(buffer, 0, byteread)
                    byteread = inStream.read(buffer)
                }
                inStream.close()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

    }

    //  发送广播通知更新
    fun notiAlbum(file: File) {
        try {
            val uri = Uri.fromFile(file)
            tfRegistrar.activeContext().sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }
}

