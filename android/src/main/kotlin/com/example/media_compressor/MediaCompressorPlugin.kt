package com.yourcompany.media_compressor 

import android.content.Context
import androidx.annotation.NonNull
import com.arthenica.ffmpegkit.FFmpegKit
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MediaCompressorPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "media_compressor")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        val filePath = call.argument<String>("filePath")!!
        when (call.method) {
            "compressImage" -> {
                val quality = call.argument<Int>("quality") ?: 70
                val outputPath = "$filePath-compressed.jpg"
                FFmpegKit.executeAsync("-i $filePath -qscale:v $quality $outputPath") {
                    result.success(outputPath)
                }
            }
            "compressVideo" -> {
                val outputPath = "$filePath-compressed.mp4"
                FFmpegKit.executeAsync("-i $filePath -vcodec libx264 -crf 28 $outputPath") {
                    result.success(outputPath)
                }
            }
            "compressAudio" -> {
                val outputPath = "$filePath-compressed.mp3"
                FFmpegKit.executeAsync("-i $filePath -b:a 128k $outputPath") {
                    result.success(outputPath)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
