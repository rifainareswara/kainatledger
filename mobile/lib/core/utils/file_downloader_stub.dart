import 'dart:typed_data';

abstract class FileDownloader {
  static Future<void> downloadBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) async {
    throw UnsupportedError('Platform not supported');
  }
}
