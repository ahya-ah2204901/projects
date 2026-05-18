import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart';

class SaveAndOpenPdf {
  static Future<File> savePdf({required Document pdf, required String fileNameStart}) async {
    final directory = Directory('/storage/emulated/0/Download');

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = "${fileNameStart}_$timestamp.pdf";

    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(await pdf.save());
    debugPrint("PDF saved at: ${file.path}");

    return file;
  }

  static Future<void> openPdf(File file) async {
    final path = file.path;
    await OpenFile.open(path);
  }
}
