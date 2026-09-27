import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, String>(
  (ref) => LocaleNotifier(ref),
);

class LocaleNotifier extends StateNotifier<String> {
  final Ref ref;
  LocaleNotifier(this.ref) : super('en') {
    ref.listen(profileProvider, (prev, next) {
      final profile = next.valueOrNull;
      final newLang = profile?.language ?? 'en';
      if (newLang != state && ['en', 'hi', 'mr'].contains(newLang)) {
        state = newLang;
      }
    });
  }

  void setLocale(String lang) {
    if (state != lang && ['en', 'hi', 'mr'].contains(lang)) {
      state = lang;
    }
  }
}
