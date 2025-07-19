import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'media_compressor_method_channel.dart';

abstract class MediaCompressorPlatform extends PlatformInterface {
  /// Constructs a MediaCompressorPlatform.
  MediaCompressorPlatform() : super(token: _token);

  static final Object _token = Object();

  static MediaCompressorPlatform _instance = MethodChannelMediaCompressor();

  /// The default instance of [MediaCompressorPlatform] to use.
  ///
  /// Defaults to [MethodChannelMediaCompressor].
  static MediaCompressorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MediaCompressorPlatform] when
  /// they register themselves.
  static set instance(MediaCompressorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Gets the platform version.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

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
  Future<String> compressVideo({
    required String inputPath,
    required String outputPath,
    int quality = 75,
    int bitrate = 1000,
    String preset = 'medium',
    int? maxWidth,
    int? maxHeight,
  });

  /// Gets available compression presets
  Future<List<String>> getAvailablePresets() {
    throw UnimplementedError('getAvailablePresets() has not been implemented.');
  }

  /// Gets system supported video formats
  Future<List<String>> getSupportedFormats() {
    throw UnimplementedError('getSupportedFormats() has not been implemented.');
  }

  /// Checks if the input file is supported
  Future<bool> isFormatSupported(String filePath) {
    throw UnimplementedError('isFormatSupported() has not been implemented.');
  }
}
