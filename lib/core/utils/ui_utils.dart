import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

abstract final class UiUtils {
  /// ✅ RELIABLE CONFIRM DIALOG
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final theme = Theme.of(context);
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        surfaceTintColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        content: Text(message, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(100, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
