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
                val type = call.argument<Int>("type")!!
                val filePath = call.argument<String>("filePath")
                val file = File(filePath)

                when (type) {
                    0 -> {
                        val fileName = System.currentTimeMillis().toString() + ".jpg"
                        notiAlbum(file, fileName)
                        result.success(null)
                    }
                    1 -> {
                        val fileName = System.currentTimeMillis().toString() + ".gif"
                        val newFile = getNewFileAndName(fileName)
                        copyFile(file.path, newFile.path)
                        notiAlbum(newFile, fileName)
                        result.success(null)
                    }
                    2 -> {
                        val fileName = System.currentTimeMillis().toString() + ".pdf"
                        val newFile = getNewFileAndName(fileName)
                        copyFile(file.path, newFile.path)
                        notiAlbum(newFile, fileName)
                        result.success(null)
                    }
                    3 -> {
                        val fileName = System.currentTimeMillis().toString() + ".MOV"
                        val newFile = getNewFileAndName(fileName)
                        copyFile(file.path, newFile.path)
                        notiAlbum(newFile, fileName)
                        result.success(null)
                    }
                    else -> result.success(null)
                }
            }
            "saveImageByBytes" -> {
                val bytes = call.argument<ByteArray>("imageBytes")
                val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes!!.size)
                saveImageToGallery(bitmap)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    //保存图片bytes到指定路径
    fun saveImageToGallery(bmp: Bitmap) {
        val fileName = System.currentTimeMillis().toString() + ".jpg"
        val file = getNewFileAndName(fileName)

        try {
            val fos = FileOutputStream(file)
            //通过io流的方式来压缩保存图片
            bmp.compress(Bitmap.CompressFormat.JPEG, 60, fos)
            fos.flush()
            fos.close()

            notiAlbum(file, fileName)
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    private fun getNewFileAndName(fileName: String): File {
        val storePath = Environment.getExternalStorageDirectory().absolutePath + File.separator
        val appDir = File(storePath)
        if (!appDir.exists()) {
            appDir.mkdir()
        }
        val file = File(appDir, fileName)
        return file
    }

    //保存file并发送广播通知更新数据库
    fun notiAlbum(file: File, fileName: String) {
        try {
            //把文件插入到系统图库
            MediaStore.Images.Media.insertImage(tfRegistrar.context().getContentResolver(), file.getAbsolutePath(), fileName, null);

            val uri = Uri.fromFile(file)
            tfRegistrar.activeContext().sendBroadcast(Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri))
        } catch (e: IOException) {
            e.printStackTrace()
        }
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


}

