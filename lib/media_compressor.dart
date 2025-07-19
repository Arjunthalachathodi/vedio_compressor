import 'package:flutter/services.dart';
import 'media_compressor_platform_interface.dart';

class MediaCompressor {
  static const MethodChannel _channel = MethodChannel('media_compressor');

  /// Compresses a video file with specified parameters
  /// 
  /// [inputPath] - Path to the input video file
  /// [outputPath] - Path where the compressed video will be saved
  /// [quality] - Compression quality (0-100, higher is better quality)
  /// [bitrate] - Target bitrate in kbps
  /// [preset] - Compression preset (ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow)
  /// [maxWidth] - Maximum width of the output video
  /// [maxHeight] - Maximum height of the output video
  /// 
  /// Returns the path to the compressed video file on success, or throws an exception on error
  static Future<String> compressVideo({
    required String inputPath,
    required String outputPath,
    int quality = 75,
    int bitrate = 1000,
    String preset = 'medium',
    int? maxWidth,
    int? maxHeight,
  }) {
    return MediaCompressorPlatform.instance.compressVideo(
      inputPath: inputPath,
      outputPath: outputPath,
      quality: quality,
      bitrate: bitrate,
      preset: preset,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  /// Gets available compression presets
  static Future<List<String>> getAvailablePresets() {
    return MediaCompressorPlatform.instance.getAvailablePresets();
  }

  /// Gets system supported video formats
  static Future<List<String>> getSupportedFormats() {
    return MediaCompressorPlatform.instance.getSupportedFormats();
  }

  /// Checks if the input file is supported
  static Future<bool> isFormatSupported(String filePath) {
    return MediaCompressorPlatform.instance.isFormatSupported(filePath);
  }

  /// Gets the platform version
  static Future<String?> getPlatformVersion() {
    return MediaCompressorPlatform.instance.getPlatformVersion();
  }

  static Future<String?> compressImage(String filePath, {int quality = 70}) async {
    return await _channel.invokeMethod<String>('compressImage', {
      'filePath': filePath,
      'quality': quality,
    });
  }

  static Future<String?> compressAudio(String filePath) async {
    return await _channel.invokeMethod<String>('compressAudio', {
      'filePath': filePath,
    });
  }
}
