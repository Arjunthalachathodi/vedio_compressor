package com.example.media_compressor

import android.content.Context
import com.arthenica.ffmpegkit.FFmpegKit
import com.arthenica.ffmpegkit.ReturnCode
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class MediaCompressorPlugin : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "media_compressor")
            channel.setMethodCallHandler(MediaCompressorPlugin())
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "compressVideo" -> {
                val inputPath = call.argument<String>("inputPath")
                val outputPath = call.argument<String>("outputPath")
                val quality = call.argument<Int>("quality") ?: 75
                val bitrate = call.argument<Int>("bitrate") ?: 1000
                val preset = call.argument<String>("preset") ?: "medium"
                val maxWidth = call.argument<Int>("maxWidth")
                val maxHeight = call.argument<Int>("maxHeight")

                val command = buildFFmpegCommand(
                    inputPath,
                    outputPath,
                    quality,
                    bitrate,
                    preset,
                    maxWidth,
                    maxHeight
                )

                FFmpegKit.executeAsync(command) { session ->
                    val returnCode = session.returnCode
                    if (ReturnCode.isSuccess(returnCode)) {
                        result.success(outputPath)
                    } else {
                        val errorMessage = session.failStackTrace
                        result.error("ERROR", "Video compression failed", errorMessage)
                    }
                }
            }
            "getAvailablePresets" -> {
                result.success(listOf(
                    "ultrafast",
                    "superfast",
                    "veryfast",
                    "faster",
                    "fast",
                    "medium",
                    "slow",
                    "slower",
                    "veryslow"
                ))
            }
            "getSupportedFormats" -> {
                result.success(listOf("mp4", "mov", "avi", "mkv", "webm", "3gp"))
            }
            "isFormatSupported" -> {
                val filePath = call.argument<String>("path")
                val extension = filePath?.toLowerCase()?.split('.')?.last()
                result.success(extension in listOf("mp4", "mov", "avi", "mkv", "webm", "3gp"))
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun buildFFmpegCommand(
        inputPath: String?,
        outputPath: String?,
        quality: Int,
        bitrate: Int,
        preset: String,
        maxWidth: Int? = null,
        maxHeight: Int? = null
    ): String {
        if (inputPath == null || outputPath == null) {
            throw IllegalArgumentException("Input and output paths must be provided")
        }

        val qualityValue = quality.coerceIn(0, 100)
        val bitrateValue = bitrate.coerceAtLeast(100)

        val commandBuilder = StringBuilder()
        commandBuilder.append("-i \"$inputPath\" ")
        commandBuilder.append("-c:v libx264 ")
        commandBuilder.append("-preset $preset ")
        commandBuilder.append("-crf ${100 - qualityValue} ")
        commandBuilder.append("-b:v ${bitrateValue}k ")
        
        if (maxWidth != null && maxHeight != null) {
            commandBuilder.append("-vf \"scale='min($maxWidth,iw)':min($maxHeight,ih):force_original_aspect_ratio=decrease\" ")
        }
        
        commandBuilder.append("-c:a copy ")
        commandBuilder.append("\"$outputPath\" ")

        return commandBuilder.toString()
    }
}
