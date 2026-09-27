import 'package:flutter/material.dart';
import '../../main.dart';
import '../constants/app_colors.dart';

/// A centralized utility for showing snackbars using the global messenger key.
class SnackbarUtils {
  static void show(String message, {bool isError = false}) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    // Clear existing snackbars to avoid queueing
    messenger.clearSnackBars();

    final bgColor = isError ? AppColors.error : AppColors.primary;

    messenger.showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// ✅ CENTRALIZED FIRESTORE ERROR HANDLING
  static void showFirestoreError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('failed-precondition') || errorStr.contains('requires an index')) {
      show("Data is being prepared. Please try again in a moment.", isError: true);
    } else {
      show("Something went wrong", isError: true);
    }
  }
}
