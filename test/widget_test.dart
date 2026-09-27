import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safestep/core/constants/app_colors.dart';
import 'package:safestep/core/theme/app_theme.dart';

void main() {
  testWidgets('App basic widget structure and theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('SafeStep'),
              backgroundColor: AppColors.primary,
            ),
            body: const Center(
              child: Text('Your Intelligent Safety Companion'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SafeStep'), findsOneWidget);
    expect(find.text('Your Intelligent Safety Companion'), findsOneWidget);
  });
}
