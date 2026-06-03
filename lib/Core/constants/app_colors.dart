import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── App primary palette (teal theme) ─────────────────────────────────────
  static const Color primary = Color(0xFF0B4D69);
  static const Color primaryDark = Color(0xFF076189);
  static const Color primaryLight = Color(0xFFD4E5F3);
  static const Color primaryLighter = Color(0xFFE9F2FA);

  /// Used on the featured card background
  static const Color featuredCard = Color(0xFF076189);

  // ── Text colours ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0B4D69);
  static const Color textRed = Color(0xFF6D0404);
  static const Color textMuted = Color(0xFF7B7B7B);
  static const Color textHint = Color(0xFFA3A3A3);
  static const Color textSecondary = Color(0xFF909098);

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFE9F2FA);
  static const Color surface = Colors.white;
  static const Color cardBg = Color(0xFFF9FDFF);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFB42828);
  static const Color warning = Color(0xFFFFA726);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF034B6D),
      Color(0xFF07618B),
      Color(0xFF2780AA),
      Color(0xFF64B2D6),
      Color(0xFFA2CFE4),
      Color(0xFFFCFDFD),
    ],
  );

  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF07618A),
      Color(0xFFFEFFFF),
      Color(0xFF74A8BE),
    ],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE8F3F8),
      Color(0xFF115F83),
    ],
  );

  /// Diagonal primary gradient — home header strip & primary surfaces.
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF034B6D), Color(0xFF0B4D69), Color(0xFF3A8EAC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Form / input helpers ─────────────────────────────────────────────────
  static const Color fieldBgBlue = Color(0xFFA7CEE0);
  static const Color tabUnselected = Color(0xFFB4D2E1);
  static const Color navUnselected = Color(0xFFA0AEB9);
  static const Color dangerLight = Color(0xFFFFEBEB);

  // ── Borders & dividers ────────────────────────────────────────────────────
  /// Input field border colour.
  static const Color inputBorder = Color(0xFFDDE2E8);
  /// Divider line colour.
  static const Color divider = Color(0xFFE8ECF0);

  // ── Doctor tile backgrounds (rotating pastel cards) ──────────────────────
  static const List<Color> doctorTileColors = [
    Color(0xFFF8EEEE),
    Color(0xFFF3FDF4),
    Color(0xFFEDF7FF),
    Color(0xFFF7F1F8),
    Color(0xFFF8F7EC),
    Color(0xFFF3FDF4),
  ];

  // ── Shadows ───────────────────────────────────────────────────────────────
  static const Color shadowLight = Color(0xFFD9DADA);
  static const Color shadowCard = Color(0xFFC9C9C9);
}
