import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

enum TextType {
  appName,
  screenTitles,
  balanceAmount,
  transactionAmount,
  transactionDescription,
  buttons,
}

class AppText extends StatelessWidget {
  final String text;
  final TextType type;
  final Color color;
  final TextAlign? align;
  final double? letterSpacing;

  const AppText(
      this.text, {
        super.key,
        this.type = TextType.buttons,
        required this.color,
        this.align = TextAlign.center,
        this.letterSpacing = 0.0,
      });

  double _getResponsiveFont(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double scale = width / 375;

    switch (type) {
      case TextType.appName:
        return (22 * scale).clamp(22, 36);
      case TextType.screenTitles:
        return (20 * scale).clamp(20, 32);
      case TextType.balanceAmount:
        return (18 * scale).clamp(18, 28);
      case TextType.transactionAmount:
        return (16 * scale).clamp(16, 24);
      case TextType.transactionDescription:
        return (14 * scale).clamp(14, 20);
      case TextType.buttons:
        return (12 * scale).clamp(12, 18);
    }
  }

  TextStyle _getGoogleFontStyle() {
    switch (type) {
      case TextType.appName:
        return GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800);
      case TextType.screenTitles:
        return GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700);
      case TextType.balanceAmount:
        return GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800);
      case TextType.transactionAmount:
        return GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600);
      case TextType.transactionDescription:
        return GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500);
      case TextType.buttons:
        return GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: _getGoogleFontStyle().copyWith(
        fontSize: _getResponsiveFont(context),
        color: color,
        letterSpacing: letterSpacing,
      ),
    );
  }
}