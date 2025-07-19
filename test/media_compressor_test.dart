import 'package:flutter_test/flutter_test.dart';
import 'package:media_compressor/media_compressor.dart';
import 'package:media_compressor/media_compressor_platform_interface.dart';
import 'package:media_compressor/media_compressor_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMediaCompressorPlatform
    with MockPlatformInterfaceMixin
    implements MediaCompressorPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String> compressVideo({
    required String inputPath,
    required String outputPath,
    int quality = 75,
    int bitrate = 1000,
    String preset = 'medium',
    int? maxWidth,
    int? maxHeight,
  }) {
    return Future.value(outputPath);
  }

  @override
  Future<List<String>> getAvailablePresets() {
    return Future.value([
      'ultrafast',
      'superfast',
      'veryfast',
      'faster',
      'fast',
      'medium',
      'slow',
      'slower',
      'veryslow'
    ]);
  }

  @override
  Future<List<String>> getSupportedFormats() {
    return Future.value(['mp4', 'mov', 'avi', 'mkv']);
  }

  @override
  Future<bool> isFormatSupported(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return Future.value(['mp4', 'mov', 'avi', 'mkv'].contains(extension));
  }
}

void main() {
  final MediaCompressorPlatform initialPlatform = MediaCompressorPlatform.instance;
  late MockMediaCompressorPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockMediaCompressorPlatform();
    MediaCompressorPlatform.instance = mockPlatform;
  });

  tearDown(() {
    MediaCompressorPlatform.instance = initialPlatform;
  });

  group('MediaCompressor', () {
    test('is the default instance', () {
      expect(
        MediaCompressorPlatform.instance,
        isInstanceOf<MethodChannelMediaCompressor>(),
      );
    });

    test('getPlatformVersion', () async {
      expect(await MediaCompressor.getPlatformVersion(), '42');
    });

    test('compressVideo with default parameters', () async {
      final outputPath = await MediaCompressor.compressVideo(
        inputPath: 'input.mp4',
        outputPath: 'output.mp4',
      );
      expect(outputPath, 'output.mp4');
    });

    test('compressVideo with custom parameters', () async {
      final outputPath = await MediaCompressor.compressVideo(
        inputPath: 'input.mp4',
        outputPath: 'output.mp4',
        quality: 85,
        bitrate: 2000,
        preset: 'faster',
        maxWidth: 1920,
        maxHeight: 1080,
      );
      expect(outputPath, 'output.mp4');
    });

    test('getAvailablePresets', () async {
      final presets = await MediaCompressor.getAvailablePresets();
      expect(presets, isList);
      expect(presets.length, 9);
      expect(presets.contains('medium'), isTrue);
    });

    test('getSupportedFormats', () async {
      final formats = await MediaCompressor.getSupportedFormats();
      expect(formats, isList);
      expect(formats.length, 4);
      expect(formats.contains('mp4'), isTrue);
    });

    test('isFormatSupported', () async {
      expect(await MediaCompressor.isFormatSupported('video.mp4'), isTrue);
      expect(await MediaCompressor.isFormatSupported('video.mov'), isTrue);
      expect(await MediaCompressor.isFormatSupported('video.wmv'), isFalse);
    });
  });
}
