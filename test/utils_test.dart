import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:safestep/core/constants/app_colors.dart';
import 'package:safestep/core/constants/app_strings.dart';
import 'package:safestep/core/l10n/app_localizations.dart';
import 'package:safestep/core/theme/app_theme.dart';
import 'package:safestep/core/utils/date_time_utils.dart';

void main() {
  group('DateTimeUtils Tests', () {
    test('formats dates consistently', () {
      final date = DateTime(2026, 9, 27, 14, 30);
      final formatted = DateTimeUtils.formatDate(date);
      expect(formatted, isNotEmpty);
      expect(formatted.contains('2026') || formatted.contains('Sep'), true);
    });

    test('formats times in readable form', () {
      final time = DateTime(2026, 9, 27, 8, 15);
      final formatted = DateTimeUtils.formatTime(time);
      expect(formatted, isNotEmpty);
    });
  });

  group('Localization Tests', () {
    test('supports en, hi, mr locales', () {
      final en = AppLocalizations(const Locale('en'));
      final hi = AppLocalizations(const Locale('hi'));
      final mr = AppLocalizations(const Locale('mr'));

      expect(en.appName, 'SafeStep');
      expect(hi.appName, 'सेफस्टेप');
      expect(mr.appName, 'सेफस्टेप');
      expect(en.home, 'Home');
      expect(hi.home, 'होम');
      expect(mr.home, 'मुख्यपृष्ठ');
      expect(en.greeting('Sonal'), 'Hello, Sonal!');
    });
  });

  group('Theme and Constants Tests', () {
    test('theme defines expected primary colors', () {
      expect(AppTheme.light.brightness, Brightness.light);
      expect(AppTheme.dark.brightness, Brightness.dark);
      expect(AppColors.primary, const Color(0xFF2563EB));
      expect(AppStrings.appName, 'SafeStep');
    });
  });
}
