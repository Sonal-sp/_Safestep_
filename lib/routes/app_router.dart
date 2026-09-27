import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/main_shell.dart';
import '../features/dashboard/screens/ai_insights_screen.dart';
import '../features/medicines/screens/medicine_form_screen.dart';
import '../features/profile/screens/profile_edit_screen.dart';
import '../features/contacts/screens/contacts_screen.dart';
import '../features/contacts/screens/contact_form_screen.dart';
import '../features/history/screens/history_form_screen.dart';
import '../features/safety/screens/incident_report_screen.dart';
import '../features/safety/screens/nearby_places_screen.dart';
import '../features/safety/screens/live_tracking_screen.dart';
import '../providers/auth_provider.dart';
import '../models/medication.dart';
import '../models/user_profile.dart';
import '../models/emergency_contact.dart';
import '../models/medical_history_entry.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/app';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/app',
        builder: (_, _) => const MainShell(),
      ),
      GoRoute(
        path: '/insights',
        builder: (_, _) => const AiInsightsScreen(),
      ),
      GoRoute(
        path: '/medicine-form',
        builder: (context, state) => MedicineFormScreen(
          medication: state.extra as Medication?,
        ),
      ),
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => ProfileEditScreen(
          profile: state.extra as UserProfile,
        ),
      ),
      GoRoute(
        path: '/contacts',
        builder: (_, _) => const ContactsScreen(),
      ),
      GoRoute(
        path: '/contact-form',
        builder: (context, state) => ContactFormScreen(
          contact: state.extra as EmergencyContact?,
        ),
      ),
      GoRoute(
        path: '/history-form',
        builder: (context, state) => HistoryFormScreen(
          entry: state.extra as MedicalHistoryEntry?,
        ),
      ),
      GoRoute(
        path: '/report-incident',
        builder: (_, _) => const IncidentReportScreen(),
      ),
      GoRoute(
        path: '/nearby-places',
        builder: (_, _) => const NearbyPlacesScreen(),
      ),
      GoRoute(
        path: '/live-tracking',
        builder: (_, _) => const LiveTrackingScreen(),
      ),
    ],
  );
});
