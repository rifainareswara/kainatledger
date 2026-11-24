import 'dart:typed_data';
import 'file_downloader_stub.dart'
    if (dart.library.html) 'file_downloader_web.dart' as impl;

class FileDownloader {
  static Future<void> downloadBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) {
    return impl.FileDownloader.downloadBytes(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
    );
  }
}
