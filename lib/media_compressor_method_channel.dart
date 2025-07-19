import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'media_compressor_platform_interface.dart';

/// An implementation of [MediaCompressorPlatform] that uses method channels.
class MethodChannelMediaCompressor extends MediaCompressorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel _channel = const MethodChannel('media_compressor');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String> compressVideo({
    required String inputPath,
    required String outputPath,
    int quality = 75,
    int bitrate = 1000,
    String preset = 'medium',
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      final Map<String, dynamic> args = {
        'inputPath': inputPath,
        'outputPath': outputPath,
        'quality': quality,
        'bitrate': bitrate,
        'preset': preset,
        'maxWidth': maxWidth,
        'maxHeight': maxHeight,
      };
      
      final result = await _channel.invokeMethod<String>('compressVideo', args);
      if (result == null) {
        throw MediaCompressorException('Video compression failed');
      }
      return result;
    } on PlatformException catch (e) {
      throw MediaCompressorException(e.message ?? 'Unknown error occurred');
    }
  }

  @override
  Future<List<String>> getAvailablePresets() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod<List>('getAvailablePresets');
      if (result == null) {
        throw MediaCompressorException('Failed to get available presets');
      }
      return result.cast<String>();
    } on PlatformException catch (e) {
      throw MediaCompressorException(e.message ?? 'Unknown error occurred');
    }
  }

  @override
  Future<List<String>> getSupportedFormats() async {
    try {
      final List<dynamic>? result = await _channel.invokeMethod<List>('getSupportedFormats');
      if (result == null) {
        throw MediaCompressorException('Failed to get supported formats');
      }
      return result.cast<String>();
    } on PlatformException catch (e) {
      throw MediaCompressorException(e.message ?? 'Unknown error occurred');
    }
  }

  @override
  Future<bool> isFormatSupported(String filePath) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isFormatSupported', {'path': filePath});
      if (result == null) {
        throw MediaCompressorException('Failed to check format support');
      }
      return result;
    } on PlatformException catch (e) {
      throw MediaCompressorException(e.message ?? 'Unknown error occurred');
    }
  }
}
