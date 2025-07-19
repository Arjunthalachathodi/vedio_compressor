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
}

void main() {
  final MediaCompressorPlatform initialPlatform = MediaCompressorPlatform.instance;

  test('$MethodChannelMediaCompressor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMediaCompressor>());
  });

  test('getPlatformVersion', () async {
    MediaCompressor mediaCompressorPlugin = MediaCompressor();
    MockMediaCompressorPlatform fakePlatform = MockMediaCompressorPlatform();
    MediaCompressorPlatform.instance = fakePlatform;

    expect(await mediaCompressorPlugin.getPlatformVersion(), '42');
  });
}
