import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyActiveProfile = 'active_profile_id';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyTextScaleFactor = 'explanation_text_scale';
  static const String _keyCustomApiKey = 'custom_gemini_api_key';
  static const String _keyRetainImages = 'retain_reading_images';
  static const String _keyLastUserId = 'last_synced_user_id';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  static Future<SettingsService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  // Last Synced User ID for multi-account safety
  String? getLastSyncedUserId() {
    return _prefs.getString(_keyLastUserId);
  }

  Future<void> setLastSyncedUserId(String? userId) async {
    if (userId == null) {
      await _prefs.remove(_keyLastUserId);
    } else {
      await _prefs.setString(_keyLastUserId, userId);
    }
  }

  // Active Profile
  String getActiveProfileId() {
    return _prefs.getString(_keyActiveProfile) ?? 'me';
  }

  Future<void> setActiveProfileId(String id) async {
    await _prefs.setString(_keyActiveProfile, id);
  }

  // Theme Mode: system, light, dark
  ThemeMode getThemeMode() {
    final modeStr = _prefs.getString(_keyThemeMode);
    switch (modeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String val;
    switch (mode) {
      case ThemeMode.light:
        val = 'light';
        break;
      case ThemeMode.dark:
        val = 'dark';
        break;
      case ThemeMode.system:
        val = 'system';
        break;
    }
    await _prefs.setString(_keyThemeMode, val);
  }

  // Explanation Text Size Factor (Accessibility for older family members)
  // 1.0 (Standard), 1.15 (Comfortable), 1.30 (Large), 1.45 (Extra Large)
  double getTextScaleFactor() {
    return _prefs.getDouble(_keyTextScaleFactor) ?? 1.15;
  }

  Future<void> setTextScaleFactor(double factor) async {
    await _prefs.setDouble(_keyTextScaleFactor, factor);
  }

  // Gemini API Key: check runtime override first, then dotenv, then empty
  String getGeminiApiKey() {
    final custom = _prefs.getString(_keyCustomApiKey)?.trim() ?? '';
    if (custom.isNotEmpty) return custom;

    final fromEnv = dotenv.isInitialized ? (dotenv.env['GEMINI_API_KEY'] ?? '') : '';
    if (fromEnv.isNotEmpty && fromEnv != 'your_gemini_api_key_here') {
      return fromEnv.trim();
    }
    return '';
  }

  bool isApiKeyConfigured() {
    final key = getGeminiApiKey();
    return key.isNotEmpty && key != 'your_gemini_api_key_here';
  }

  Future<void> setCustomApiKey(String key) async {
    await _prefs.setString(_keyCustomApiKey, key.trim());
  }

  Future<void> clearCustomApiKey() async {
    await _prefs.remove(_keyCustomApiKey);
  }

  // Image retention setting
  bool getRetainImages() {
    return _prefs.getBool(_keyRetainImages) ?? true;
  }

  Future<void> setRetainImages(bool retain) async {
    await _prefs.setBool(_keyRetainImages, retain);
  }
}
