import 'package:flutter/material.dart';

/// SafeStep Design System — Color Tokens
/// Calm + Medical trust palette. Red reserved ONLY for emergencies.
/// WCAG AA compliant contrast ratios.
class AppColors {
  AppColors._();

  // ─── PRIMARY PALETTE ─────────────────────────────────────────
  static const primary = Color(0xFF2563EB);       // Trust Blue
  static const primaryLight = Color(0xFF60A5FA);
  static const primaryDark = Color(0xFF1D4ED8);

  // ─── SECONDARY / SUCCESS ─────────────────────────────────────
  static const secondary = Color(0xFF22C55E);     // Safe Green
  static const secondaryLight = Color(0xFF86EFAC);
  static const secondaryDark = Color(0xFF16A34A);

  // ─── EMERGENCY ───────────────────────────────────────────────
  static const error = Color(0xFFDC2626);         // SOS Red — ONLY for emergencies
  static const errorLight = Color(0xFFFEE2E2);
  static const errorDark = Color(0xFFB91C1C);

  // ─── WARNING ─────────────────────────────────────────────────
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFFD97706);

  // ─── LIGHT MODE ──────────────────────────────────────────────
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const divider = Color(0xFFE2E8F0);

  // ─── LIGHT TEXT ──────────────────────────────────────────────
  static const textPrimary = Color(0xFF1E293B);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);

  // ─── DARK MODE ───────────────────────────────────────────────
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkCard = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF334155);
  static const darkDivider = Color(0xFF334155);

  // ─── DARK TEXT ───────────────────────────────────────────────
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkTextTertiary = Color(0xFF64748B);

  // ─── SEMANTIC STATUS ─────────────────────────────────────────
  static const medicineTaken = Color(0xFFDCFCE7);
  static const medicineTakenText = Color(0xFF166534);
  static const medicineMissed = Color(0xFFFEE2E2);
  static const medicineMissedText = Color(0xFF991B1B);
  static const medicineUpcoming = Color(0xFFDBEAFE);
  static const medicineUpcomingText = Color(0xFF1E40AF);
  static const medicineSkipped = Color(0xFFF1F5F9);
  static const medicineSkippedText = Color(0xFF475569);

  // ─── SAFETY SCORE COLORS ─────────────────────────────────────
  static const safetySafe = Color(0xFF22C55E);
  static const safetyModerate = Color(0xFFF59E0B);
  static const safetyRisky = Color(0xFFDC2626);

  // ─── NOTIFICATION CATEGORY COLORS ────────────────────────────
  static const notifReminder = Color(0xFF2563EB);
  static const notifSuccess = Color(0xFF22C55E);
  static const notifWarning = Color(0xFFF59E0B);
  static const notifEmergency = Color(0xFFDC2626);

  // ─── LEGACY MAPPINGS (backward compat) ───────────────────────
  static const white = Colors.white;
  static const accent = secondary;
  static const info = primary;
  static const green = secondary;
  static const red = error;
  static const blue = primary;
  static const orange = warning;
  static const foreground = textPrimary;
  static const mutedText = textSecondary;
}
