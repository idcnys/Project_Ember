import 'package:flutter/material.dart';

class NotionTheme {
  // Primary Typography
  static const String fontFamily = 'EkusheInter';
  static const String pixelFont = 'Silkscreen';

  // Notion Dark Palette
  static const Color bgDark = Color(0xFF191919);
  static const Color surfaceCard = Color(0xFF222222);
  static const Color surfaceHover = Color(0xFF2B2B2B);
  static const Color surfaceElevated = Color(0xFF262626);
  static const Color borderMuted = Color(0x1FFFFFFF); // 12% white
  static const Color borderLight = Color(0x0FFFFFFF); // 6% white

  // Text Colors
  static const Color textPrimary = Color(0xFFEDEDED);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textTertiary = Color(0xFF737373);

  // Soft Pastel Tint Accents (School-friendly Notion style)
  static const Color pastelGreen = Color(0xFF85E3B3);
  static const Color pastelGreenBg = Color(0xFF1A3326);

  static const Color pastelBlue = Color(0xFF90CDF4);
  static const Color pastelBlueBg = Color(0xFF162D42);

  static const Color pastelAmber = Color(0xFFFDE68A);
  static const Color pastelAmberBg = Color(0xFF382F18);

  static const Color pastelPurple = Color(0xFFD8B4FE);
  static const Color pastelPurpleBg = Color(0xFF2D1E45);

  static const Color pastelRed = Color(0xFFFCA5A5);
  static const Color pastelRedBg = Color(0xFF3B1E1E);

  static const Color pastelTeal = Color(0xFF99F6E4);
  static const Color pastelTealBg = Color(0xFF163836);

  // Notion Callout Widget Generator
  static Widget callout({
    required IconData icon,
    required String title,
    required String message,
    Color accentColor = pastelBlue,
    Color bgColor = pastelBlueBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      fontFamily: fontFamily,
                    ),
                  ),
                  const SizedBox(height: 3),
                ],
                Text(
                  message,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 11.5,
                    height: 1.4,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Notion Badge / Tag Pill Generator
  static Widget badge({
    required String text,
    Color textColor = pastelBlue,
    Color bgColor = pastelBlueBg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 11),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                fontFamily: fontFamily,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Subtle High-Tech Telemetry Loader (No dummy emojis or crude spinners)
  static Widget subtleLoader({
    String? label,
    double size = 18.0,
    Color color = const Color(0xFF38BDF8),
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: color,
            strokeWidth: 2.0,
          ),
        ),
        if (label != null && label.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color.withValues(alpha: 0.85),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ],
    );
  }

  // High-Tech Cyber Accent Stripe (replaces low-res raster hazard stripes)
  static Widget cyberDivider({Color? color}) {
    final c = color ?? const Color(0xFF38BDF8);
    return Container(
      height: 2.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.withValues(alpha: 0.0),
            c.withValues(alpha: 0.8),
            c,
            c.withValues(alpha: 0.8),
            c.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}
