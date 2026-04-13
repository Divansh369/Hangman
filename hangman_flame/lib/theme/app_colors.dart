import 'package:flutter/material.dart';

extension AppColorTokens on ColorScheme {
  Color get gameBackground => surface;
  Color get surface1 => surfaceContainerLowest;
  Color get surface2 => surfaceContainer;
  Color get surface3 => surfaceContainerHighest;

  Color get textPrimary => onSurface;
  Color get textMuted => onSurfaceVariant;

  Color get letterNeutral => primaryContainer;
  Color get letterCorrect => Colors.green.shade600;
  Color get letterWrong => Colors.red.shade600;
}
