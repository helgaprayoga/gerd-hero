import 'package:flutter/services.dart';

class ReportFileSaver {
  static const _channel = MethodChannel('gerdhero/report_file');

  static Future<bool> save(Uint8List bytes, String fileName) async {
    final saved = await _channel.invokeMethod<bool>('savePdf', {
      'bytes': bytes,
      'fileName': fileName,
    });
    return saved ?? false;
  }
}
