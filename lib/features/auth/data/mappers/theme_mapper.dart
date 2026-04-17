import 'package:flutter/material.dart';
import 'package:flutter_chat/core/theme/e_app_theme.dart';

class ThemeMapper {
  static ThemeMode toThemeMode(String? themeString) {
    if (themeString == null || themeString.isEmpty) {
      return ThemeMode.system;
    }

    return switch (themeString.toLowerCase()) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  static String fromThemeMode(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  static String fromAppThemeMode(AppThemeMode appThemeMode) {
    return switch (appThemeMode) {
      AppThemeMode.light => 'light',
      AppThemeMode.dark => 'dark',
      AppThemeMode.system => 'system',
    };
  }
}
