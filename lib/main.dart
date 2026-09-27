import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'routes/app_router.dart';

import 'services/notification_manager.dart';
import 'services/notification_service.dart';
import 'services/location_service.dart';
import 'core/l10n/app_localizations.dart';

/// 🔥 GLOBAL SNACKBAR KEY
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. System Config
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Initialize Notification Manager (includes FCM + Local + Background Handler)
  await NotificationManager().initialize();

  // 3.1 Initialize NotificationService AFTER NotificationManager ✅
  // ⚠️ ANDROID RELIABILITY: Enable battery unrestricted + exact alarms
  await NotificationService().initializeAndReschedule().catchError((e) {
    // Silent fail - non-blocking
  });

  // 4. Request notification permissions
  await NotificationService().requestPermissions();
  // 5. Initialize Location Service Permissions
  await LocationService().handlePermissions();

  runApp(const ProviderScope(child: SafeStepApp()));
}

class SafeStepApp extends ConsumerWidget {
  const SafeStepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'SafeStep',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      /// 🔥 ATTACH GLOBAL SNACKBAR KEY
      scaffoldMessengerKey: rootScaffoldMessengerKey,

      routerConfig: router,
      locale: Locale(locale),

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('en'), Locale('hi'), Locale('mr')],

      debugShowCheckedModeBanner: false,
    );
  }
}
