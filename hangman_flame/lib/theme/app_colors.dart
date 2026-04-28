import 'package:flutter/material.dart';

extension AppColorTokens on ColorScheme {
  Color get gameBackground => surface;
  Color get surface1 => surfaceContainerLowest;
  Color get surface2 => surfaceContainer;
  Color get surface3 => surfaceContainerHighest;

  Color get textPrimary => onSurface;
  Color get textMuted => onSurfaceVariant;

  Color get letterNeutral => primaryContainer;
  Color get letterCorrect => brightness == Brightness.dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
  Color get letterWrong => brightness == Brightness.dark ? const Color(0xFFF87171) : const Color(0xFFDC2626);

  // Chat-specific colors with theme support
  Color get chatBubbleOwn => primary;
  Color get chatBubbleOther => surfaceContainerHighest;
  Color get chatBubbleTextOwn => onPrimary;
  Color get chatBubbleTextOther => onSurface;
  Color get chatHeaderBackground => surfaceContainerHigh;
  Color get chatHeaderText => onSurface;
  Color get chatSystemMessageText => onSurfaceVariant;

  // Status colors with theme support
  Color get statusSuccess => brightness == Brightness.dark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
  Color get statusError => brightness == Brightness.dark ? const Color(0xFFF87171) : const Color(0xFFDC2626);
  Color get statusWarning => brightness == Brightness.dark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

  // Badge colors
  Color get badgeBackground => tertiaryContainer;
  Color get badgeText => onTertiaryContainer;

  // Glass morphism colors
  Color get glassBackground => brightness == Brightness.dark
      ? const Color(0xFF1A1A2E).withValues(alpha: 0.7)
      : Colors.white.withValues(alpha: 0.65);
  Color get glassBorder => brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.1)
      : Colors.white.withValues(alpha: 0.5);
  Color get glassHighlight => brightness == Brightness.dark
      ? Colors.white.withValues(alpha: 0.05)
      : Colors.white.withValues(alpha: 0.3);

  // Glow colors
  Color get primaryGlow => primary.withValues(alpha: 0.3);
  Color get successGlow => letterCorrect.withValues(alpha: 0.3);
  Color get errorGlow => letterWrong.withValues(alpha: 0.3);
  Color get accentGlow => tertiary.withValues(alpha: 0.25);

  // Gradient sets
  List<Color> get primaryGradient => brightness == Brightness.dark
      ? [primary, tertiary]
      : [primary, primary.withValues(alpha: 0.7)];
  List<Color> get cardGradient => brightness == Brightness.dark
      ? [const Color(0xFF1E1E3F).withValues(alpha: 0.8), const Color(0xFF16213E).withValues(alpha: 0.6)]
      : [Colors.white.withValues(alpha: 0.85), Colors.white.withValues(alpha: 0.55)];
  List<Color> get heroGradient => brightness == Brightness.dark
      ? [primary.withValues(alpha: 0.4), tertiary.withValues(alpha: 0.2), surface.withValues(alpha: 0.0)]
      : [primary.withValues(alpha: 0.15), tertiary.withValues(alpha: 0.08), surface.withValues(alpha: 0.0)];

  // Ambient background
  Color get ambientDark => brightness == Brightness.dark
      ? const Color(0xFF0F0F23)
      : const Color(0xFFF0F4FF);
}
