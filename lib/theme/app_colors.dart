import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Identidad principal inspirada en Airbnb
  static const Color primary = Color(0xFFFF385C);
  static const Color primaryDark = Color(0xFFE31C5F);
  static const Color primaryPressed = Color(0xFFD70466);
  static const Color primarySoft = Color(0xFFFFEFF2);

  // Fondos y superficies
  static const Color background = Color(0xFFF7F7F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF2F2F2);

  // Textos
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF717171);
  static const Color textDisabled = Color(0xFFB0B0B0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Bordes y divisores
  static const Color border = Color(0xFFDDDDDD);
  static const Color divider = Color(0xFFEBEBEB);

  // Estados
  static const Color success = Color(0xFF008A05);
  static const Color successSoft = Color(0xFFE8F5E9);

  static const Color warning = Color(0xFFC47F00);
  static const Color warningSoft = Color(0xFFFFF4DC);

  static const Color error = Color(0xFFC13515);
  static const Color errorSoft = Color(0xFFFFEDEA);

  static const Color info = Color(0xFF0066CC);
  static const Color infoSoft = Color(0xFFEAF3FF);

  // Elementos específicos
  static const Color favorite = Color(0xFFFF385C);
  static const Color star = Color(0xFFFFB400);
  static const Color shadow = Color(0x1A000000);

  // Gradiente de botones principales
  static const List<Color> primaryGradient = [
    Color(0xFFE61E4D),
    Color(0xFFD70466),
  ];
}
