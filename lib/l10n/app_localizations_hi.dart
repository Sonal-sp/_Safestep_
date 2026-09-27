// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'सेफस्टेप';

  @override
  String get home => 'होम';

  @override
  String get medicines => 'दवाएं';

  @override
  String get sos => 'SOS';

  @override
  String get history => 'इतिहास';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String greeting(String name) {
    return 'नमस्ते, $name!';
  }

  @override
  String get todayMedicines => 'आज की दवाएं';

  @override
  String get quickAccess => 'त्वरित पहुंच';

  @override
  String get addMedicine => 'दवा जोड़ें';

  @override
  String get editMedicine => 'दवा संपादित करें';

  @override
  String get deleteMedicine => 'दवा हटाएं';

  @override
  String get medicineName => 'दवा का नाम';

  @override
  String get dosage => 'मात्रा';

  @override
  String get time => 'समय';

  @override
  String get frequency => 'आवृत्ति';

  @override
  String get markTaken => 'लिया गया';

  @override
  String get markSkipped => 'छोड़ा गया';

  @override
  String get upcoming => 'आगामी';

  @override
  String get taken => 'लिया';

  @override
  String get missed => 'छूट गया';

  @override
  String get skipped => 'छोड़ा';

  @override
  String get sosConfirmTitle => 'आपातकालीन अलर्ट';

  @override
  String sosConfirmBody(String contact) {
    return '$contact को कॉल कर रहे हैं और अलर्ट सहेज रहे हैं। जारी रखें?';
  }

  @override
  String get ok => 'ठीक है';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएं';

  @override
  String get confirmDelete => 'क्या आप वाकई हटाना चाहते हैं?';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signUp => 'खाता बनाएं';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get name => 'नाम';

  @override
  String get age => 'उम्र';

  @override
  String get bloodType => 'ब्लड ग्रुप';

  @override
  String get language => 'भाषा';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get primaryContact => 'प्राथमिक संपर्क';

  @override
  String get addContact => 'संपर्क जोड़ें';

  @override
  String get edit => 'संपादित करें';

  @override
  String get editContact => 'संपर्क संपादित करें';

  @override
  String get phone => 'फ़ोन';

  @override
  String get relationship => 'संबंध';

  @override
  String get medicalHistory => 'चिकित्सा इतिहास';

  @override
  String get addEntry => 'एंट्री जोड़ें';

  @override
  String get condition => 'स्थिति';

  @override
  String get notes => 'नोट्स';

  @override
  String get date => 'तारीख';

  @override
  String get weeklySummary => 'साप्ताहिक सारांश';

  @override
  String missedCount(int count) {
    return 'इस सप्ताह आपकी $count दवाएं छूट गईं';
  }

  @override
  String get noMedicinesToday => 'आज के लिए कोई दवा निर्धारित नहीं';

  @override
  String get noContacts => 'कोई आपातकालीन संपर्क नहीं जोड़ा गया';

  @override
  String get noHistory => 'कोई चिकित्सा इतिहास नहीं';

  @override
  String get loginError => 'लॉगिन विफल। कृपया पुनः प्रयास करें।';

  @override
  String get networkError => 'नेटवर्क त्रुटि। कनेक्शन जांचें।';

  @override
  String get loading => 'लोड हो रहा है...';
}
