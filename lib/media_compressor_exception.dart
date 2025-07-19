class MediaCompressorException implements Exception {
  final String message;

  MediaCompressorException(this.message);

  @override
  String toString() => 'MediaCompressorException: $message';
}
