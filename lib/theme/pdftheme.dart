import 'package:flutter/services.dart'; // For rootBundle
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfTheme {
  final pw.Font baseFont;
  final pw.Font boldFont;
  final PdfColor primaryColor;
  final PdfColor secondaryColor;

  // Private constructor to force the use of the load() method
  PdfTheme._({
    required this.baseFont,
    required this.boldFont,
    this.primaryColor = PdfColors.black,
    this.secondaryColor = PdfColors.grey,
  });

  // Method to load the fonts and return the theme instance
  static Future<PdfTheme> load() async {
    // Load the fonts from the assets
    final ByteData baseFontData =
        await rootBundle.load('assets/fonts/DavidLibre-Regular.ttf');
    final ByteData boldFontData =
        await rootBundle.load('assets/fonts/DavidLibre-Bold.ttf');

    // Create pw.Font instances from the loaded data
    final pw.Font baseFont = pw.Font.ttf(baseFontData.buffer.asByteData());
    final pw.Font boldFont = pw.Font.ttf(boldFontData.buffer.asByteData());

    // Return an instance of PdfTheme with loaded fonts
    return PdfTheme._(
      baseFont: baseFont,
      boldFont: boldFont,
    );
  }

  // Base text style
  pw.TextStyle get baseTextStyle => pw.TextStyle(
        font: baseFont,
        fontSize: 10,
        color: primaryColor,
      );

  // Bold text style
  pw.TextStyle get boldTextStyle => pw.TextStyle(
        font: boldFont,
        fontSize: 12,
        color: primaryColor,
      );

  // Header text style
  pw.TextStyle get headerTextStyle => pw.TextStyle(
        font: boldFont,
        fontSize: 18,
        color: primaryColor,
      );

  // Subtitle text style
  pw.TextStyle get subtitleTextStyle => pw.TextStyle(
        font: baseFont,
        fontSize: 14,
        color: secondaryColor,
      );
}
