import 'package:accelaid/models/pdf/save_and_open_pdf.dart';
import 'package:accelaid/models/pdf/simple_pdf_api.dart';
import 'package:flutter/material.dart';

Color darkblue = const Color.fromRGBO(0, 48, 73, 1.0);
Color lightred = const Color.fromRGBO(193, 18, 31, 1.0);
Color darkred = const Color.fromRGBO(120, 0, 0, 1.0);
Color lightblue = const Color.fromRGBO(102, 155, 188, 1.0);
Color grey = const Color.fromARGB(255, 105, 105, 105);

void snackbarError(context, String errormessage, Color color) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errormessage),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );

TextStyle? labelTextStyle({required Color c, FontWeight? w, double? f}) {
  return TextStyle(
    color: c,
    fontWeight: w ?? FontWeight.w800,
    fontSize: f ?? 14,
    letterSpacing: 0.2,
  );
}

TextStyle? dataTextStyle({required Color c, FontWeight? w, double? f}) {
  return TextStyle(
    color: c,
    fontWeight: w ?? FontWeight.w400,
    fontSize: f ?? 18,
    letterSpacing: 0.3,
  );
}

Widget FilePageBody(String pdfContent, String title, double? bodyFontSize,
    Icon leadingIcon, String fileName) {
  final String writeToPdf = pdfContent;

  Widget formatStudyPlan(String studyPlan) {
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final List<TextSpan> spans = [];
    final matches = boldRegex.allMatches(studyPlan);

    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: studyPlan.substring(lastMatchEnd, match.start),
            style: TextStyle(fontSize: bodyFontSize, color: Colors.black87),
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
            fontSize: bodyFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < studyPlan.length) {
      spans.add(
        TextSpan(
          text: studyPlan.substring(lastMatchEnd),
          style: TextStyle(fontSize: bodyFontSize, color: Colors.black87),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            leadingIcon,
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 60,
              height: 60,
              child: IconButton(
                icon: const Icon(Icons.download_for_offline_rounded),
                color: grey,
                onPressed: () async {
                  print("Generating PDF with content: $writeToPdf");

                  final simplePdfFile =
                  await SimplePdfApi.generateSimpleTextPdf(
                      text: writeToPdf, fileName: fileName);

                  print("PDF file saved at: $simplePdfFile");

                  SaveAndOpenPdf.openPdf(simplePdfFile);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: formatStudyPlan(pdfContent),
            ),
          ),
        ),
      ],
    ),
  );
}
