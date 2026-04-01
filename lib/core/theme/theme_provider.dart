import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import 'app_themes.dart';

class ThemeState {
  final AppTheme theme;
  final String themeMode; // 'dark', 'light', 'auto'

  const ThemeState({
    required this.theme,
    this.themeMode = 'dark',
  });

  ThemeState copyWith({AppTheme? theme, String? themeMode}) {
    return ThemeState(
      theme: theme ?? this.theme,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    _loadTheme();
    return ThemeState(theme: AppThemes.midnight);
  }

  Future<void> _loadTheme() async {
    final themeId = await SecureStorageService.instance.getSelectedTheme();
    final mode = await SecureStorageService.instance.getThemeMode();
    final theme = AppThemes.getById(themeId);
    state = ThemeState(theme: theme, themeMode: mode);
  }

  Future<void> setTheme(String themeId) async {
    final theme = AppThemes.getById(themeId);
    await SecureStorageService.instance.setSelectedTheme(themeId);
    state = state.copyWith(theme: theme);
  }

  Future<void> setThemeMode(String mode) async {
    await SecureStorageService.instance.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> toggleDarkMode() async {
    final newMode = state.themeMode == 'dark' ? 'light' : 'dark';
    await setThemeMode(newMode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() => ThemeNotifier());