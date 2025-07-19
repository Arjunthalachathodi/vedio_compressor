# Media Compressor Flutter Plugin

A Flutter plugin for compressing video files across Android and iOS platforms.

## Features

- Video compression with customizable parameters
- Support for various compression presets
- Format detection and validation
- Cross-platform support (Android & iOS)

## Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  media_compressor: ^0.0.1
```

## Usage

### Basic Usage

```dart
import 'package:media_compressor/media_compressor.dart';

try {
  // Compress a video with default settings
  final outputPath = await MediaCompressor.compressVideo(
    inputPath: '/path/to/input/video.mp4',
    outputPath: '/path/to/output/video.mp4',
  );
  
  // Check supported formats
  final supportedFormats = await MediaCompressor.getSupportedFormats();
  
  // Get available compression presets
  final presets = await MediaCompressor.getAvailablePresets();
  
  // Check if a file format is supported
  final isSupported = await MediaCompressor.isFormatSupported('/path/to/video.mp4');
} catch (e) {
  print('Error: ${e.toString()}');
}
```

### Advanced Usage

```dart
try {
  // Compress with custom settings
  final outputPath = await MediaCompressor.compressVideo(
    inputPath: '/path/to/input/video.mp4',
    outputPath: '/path/to/output/video.mp4',
    quality: 85, // 0-100, higher is better quality
    bitrate: 2000, // target bitrate in kbps
    preset: 'faster', // compression preset
    maxWidth: 1920, // maximum width
    maxHeight: 1080, // maximum height
  );
} catch (e) {
  print('Error: ${e.toString()}');
}
```

## Available Compression Presets

- ultrafast
- superfast
- veryfast
- faster
- fast
- medium
- slow
- slower
- veryslow

## Supported Video Formats

The plugin supports common video formats including:
- MP4
- MOV
- AVI
- MKV
- And more (depending on platform support)

## Error Handling

The plugin throws `MediaCompressorException` with descriptive error messages when operations fail.

## Platform Support

- Android
- iOS

## License

MIT License
