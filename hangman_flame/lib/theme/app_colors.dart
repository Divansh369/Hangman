import 'package:flutter/material.dart';

extension AppColorTokens on ColorScheme {
  Color get gameBackground => surface;
  Color get surface1 => surfaceContainerLowest;
  Color get surface2 => surfaceContainer;
  Color get surface3 => surfaceContainerHighest;

  Color get textPrimary => onSurface;
  Color get textMuted => onSurfaceVariant;

  Color get letterNeutral => primaryContainer;
  Color get letterCorrect => brightness == Brightness.dark ? Colors.green.shade400 : Colors.green.shade600;
  Color get letterWrong => brightness == Brightness.dark ? Colors.red.shade400 : Colors.red.shade600;

  // Chat-specific colors with theme support
  Color get chatBubbleOwn => primary;
  Color get chatBubbleOther => surfaceContainerHighest;
  Color get chatBubbleTextOwn => onPrimary;
  Color get chatBubbleTextOther => onSurface;
  Color get chatHeaderBackground => surfaceContainerHigh;
  Color get chatHeaderText => onSurface;
  Color get chatSystemMessageText => onSurfaceVariant;

  // Status colors with theme support
  Color get statusSuccess => brightness == Brightness.dark ? Colors.green.shade400 : Colors.green.shade600;
  Color get statusError => brightness == Brightness.dark ? Colors.red.shade400 : Colors.red.shade600;
  Color get statusWarning => brightness == Brightness.dark ? Colors.amber.shade400 : Colors.amber.shade600;

  // Badge colors
  Color get badgeBackground => tertiaryContainer;
  Color get badgeText => onTertiaryContainer;
}
