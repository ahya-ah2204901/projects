import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:accelaid/models/pdf/save_and_open_pdf.dart';

class SimplePdfApi {
  static Future<File> generateSimpleTextPdf({
    required String text,
    required String fileName,
  }) async {
    final pdf = pw.Document();

    // Load fonts
    final fontRegularData =
        await rootBundle.load("assets/font/Poppins/Poppins-Regular.ttf");
    final fontRegular = pw.Font.ttf(fontRegularData);

    final fontBoldData =
        await rootBundle.load("assets/font/Poppins/Poppins-Bold.ttf");
    final fontBold = pw.Font.ttf(fontBoldData);

    // Function to parse text and return widgets
    List<pw.Widget> parseTextToWidgets(String inputText) {
      final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
      final List<pw.Widget> widgets = [];
      final matches = boldRegex.allMatches(inputText);

      int lastMatchEnd = 0;

      for (final match in matches) {
        // Add regular text before the bold match
        if (match.start > lastMatchEnd) {
          widgets.add(
            pw.Text(
              inputText.substring(lastMatchEnd, match.start),
              style: pw.TextStyle(font: fontRegular, fontSize: 18),
            ),
          );
        }

        // Add bold text
        widgets.add(
          pw.Text(
            match.group(1)!,
            style: pw.TextStyle(font: fontBold, fontSize: 18),
          ),
        );

        lastMatchEnd = match.end;
      }

      // Add remaining regular text after the last match
      if (lastMatchEnd < inputText.length) {
        widgets.add(
          pw.Text(
            inputText.substring(lastMatchEnd),
            style: pw.TextStyle(font: fontRegular, fontSize: 18),
          ),
        );
      }

      return widgets;
    }

    // Generate PDF using pw.MultiPage
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 16),
            ...parseTextToWidgets(text),
          ];
        },
      ),
    );

    return SaveAndOpenPdf.savePdf(
      pdf: pdf,
      fileNameStart: fileName,
    );
  }
}
