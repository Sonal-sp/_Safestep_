import 'package:flutter/material.dart';

/// Manual localization for SafeStep. Supports en, hi, mr.
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'SafeStep',
      'home': 'Home',
      'medicines': 'Medicines',
      'sos': 'SOS',
      'history': 'History',
      'profile': 'Profile',
      'greeting': 'Hello, {name}!',
      'todayMedicines': "Today's Medicines",
      'quickAccess': 'Quick Access',
      'addMedicine': 'Add Medicine',
      'editMedicine': 'Edit Medicine',
      'deleteMedicine': 'Delete Medicine',
      'medicineName': 'Medicine Name',
      'dosage': 'Dosage',
      'time': 'Time',
      'frequency': 'Frequency',
      'markTaken': 'Mark Taken',
      'markSkipped': 'Mark Skipped',
      'upcoming': 'Upcoming',
      'taken': 'Taken',
      'missed': 'Missed',
      'skipped': 'Skipped',
      'sosConfirmTitle': 'Emergency Alert',
      'sosConfirmBody': 'Calling {contact} and saving alert. Continue?',
      'ok': 'OK',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'confirmDelete': 'Are you sure you want to delete?',
      'signIn': 'Sign In',
      'signUp': 'Create Account',
      'email': 'Email',
      'password': 'Password',
      'name': 'Name',
      'age': 'Age',
      'bloodType': 'Blood Type',
      'language': 'Language',
      'logout': 'Log Out',
      'primaryContact': 'Primary Contact',
      'addContact': 'Add Contact',
      'edit': 'Edit',
      'editContact': 'Edit Contact',
      'phone': 'Phone',
      'relationship': 'Relationship',
      'medicalHistory': 'Medical History',
      'addEntry': 'Add Entry',
      'condition': 'Condition',
      'notes': 'Notes',
      'date': 'Date',
      'weeklySummary': 'Weekly Summary',
      'missedCount': 'You missed {count} medicines this week',
      'noMedicinesToday': 'No medicines scheduled for today',
      'noContacts': 'No emergency contacts added',
      'noHistory': 'No medical history entries',
      'loginError': 'Login failed. Please try again.',
      'networkError': 'Network error. Please check your connection.',
      'loading': 'Loading...',
    },
    'hi': {
      'appName': 'सेफस्टेप',
      'home': 'होम',
      'medicines': 'दवाएं',
      'sos': 'SOS',
      'history': 'इतिहास',
      'profile': 'प्रोफ़ाइल',
      'greeting': 'नमस्ते, {name}!',
      'todayMedicines': 'आज की दवाएं',
      'quickAccess': 'त्वरित पहुंच',
      'addMedicine': 'दवा जोड़ें',
      'editMedicine': 'दवा संपादित करें',
      'deleteMedicine': 'दवा हटाएं',
      'medicineName': 'दवा का नाम',
      'dosage': 'मात्रा',
      'time': 'समय',
      'frequency': 'आवृत्ति',
      'markTaken': 'लिया गया',
      'markSkipped': 'छोड़ा गया',
      'upcoming': 'आगामी',
      'taken': 'लिया',
      'missed': 'छूट गया',
      'skipped': 'छोड़ा',
      'sosConfirmTitle': 'आपातकालीन अलर्ट',
      'sosConfirmBody': '{contact} को कॉल कर रहे हैं। जारी रखें?',
      'ok': 'ठीक है',
      'cancel': 'रद्द करें',
      'save': 'सहेजें',
      'delete': 'हटाएं',
      'confirmDelete': 'क्या आप वाकई हटाना चाहते हैं?',
      'signIn': 'साइन इन',
      'signUp': 'खाता बनाएं',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'name': 'नाम',
      'age': 'उम्र',
      'bloodType': 'ब्लड ग्रुप',
      'language': 'भाषा',
      'logout': 'लॉग आउट',
      'primaryContact': 'प्राथमिक संपर्क',
      'addContact': 'संपर्क जोड़ें',
      'edit': 'संपादित करें',
      'editContact': 'संपर्क संपादित करें',
      'phone': 'फ़ोन',
      'relationship': 'संबंध',
      'medicalHistory': 'चिकित्सा इतिहास',
      'addEntry': 'एंट्री जोड़ें',
      'condition': 'स्थिति',
      'notes': 'नोट्स',
      'date': 'तारीख',
      'weeklySummary': 'साप्ताहिक सारांश',
      'missedCount': 'इस सप्ताह {count} दवाएं छूट गईं',
      'noMedicinesToday': 'आज के लिए कोई दवा निर्धारित नहीं',
      'noContacts': 'कोई आपातकालीन संपर्क नहीं',
      'noHistory': 'कोई चिकित्सा इतिहास नहीं',
      'loginError': 'लॉगिन विफल।',
      'networkError': 'नेटवर्क त्रुटि।',
      'loading': 'लोड हो रहा है...',
    },
    'mr': {
      'appName': 'सेफस्टेप',
      'home': 'मुख्यपृष्ठ',
      'medicines': 'औषधे',
      'sos': 'SOS',
      'history': 'इतिहास',
      'profile': 'प्रोफाइल',
      'greeting': 'नमस्कार, {name}!',
      'todayMedicines': 'आजची औषधे',
      'quickAccess': 'जलद प्रवेश',
      'addMedicine': 'औषध जोडा',
      'editMedicine': 'औषध संपादित करा',
      'deleteMedicine': 'औषध हटवा',
      'medicineName': 'औषधाचे नाव',
      'dosage': 'डोस',
      'time': 'वेळ',
      'frequency': 'वारंवारता',
      'markTaken': 'घेतले',
      'markSkipped': 'वगळले',
      'upcoming': 'आगामी',
      'taken': 'घेतले',
      'missed': 'चुकले',
      'skipped': 'वगळले',
      'sosConfirmTitle': 'आणीबाणीचे अलर्ट',
      'sosConfirmBody': '{contact} ला कॉल करत आहे। जारी?',
      'ok': 'ठीक आहे',
      'cancel': 'रद्द करा',
      'save': 'जतन करा',
      'delete': 'हटवा',
      'confirmDelete': 'खात्रीने हटवायचे का?',
      'signIn': 'साइन इन',
      'signUp': 'खाते तयार करा',
      'email': 'ईमेल',
      'password': 'पासवर्ड',
      'name': 'नाव',
      'age': 'वय',
      'bloodType': 'रक्त गट',
      'language': 'भाषा',
      'logout': 'लॉग आउट',
      'primaryContact': 'प्राथमिक संपर्क',
      'addContact': 'संपर्क जोडा',
      'edit': 'संपादित करा',
      'editContact': 'संपर्क संपादित करा',
      'phone': 'फोन',
      'relationship': 'नाते',
      'medicalHistory': 'वैद्यकीय इतिहास',
      'addEntry': 'नोंद जोडा',
      'condition': 'स्थिती',
      'notes': 'नोट्स',
      'date': 'तारीख',
      'weeklySummary': 'साप्ताहिक सारांश',
      'missedCount': 'या आठवड्यात {count} औषधे चुकली',
      'noMedicinesToday': 'आजसाठी कोणतीही औषध नाही',
      'noContacts': 'कोणताही आणीबाणी संपर्क नाही',
      'noHistory': 'कोणतीही वैद्यकीय नोंद नाही',
      'loginError': 'लॉगिन अयशस्वी.',
      'networkError': 'निवड त्रुटी.',
      'loading': 'लोड होत आहे...',
    },
  };

  String _t(String key, [Map<String, Object>? args]) {
    final map = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
    var s = map[key] ?? key;
    if (args != null) {
      for (final e in args.entries) {
        s = s.replaceAll('{${e.key}}', e.value.toString());
      }
    }
    return s;
  }

  String get appName => _t('appName');
  String get home => _t('home');
  String get medicines => _t('medicines');
  String get sos => _t('sos');
  String get history => _t('history');
  String get profile => _t('profile');
  String greeting(String name) => _t('greeting', {'name': name});
  String get todayMedicines => _t('todayMedicines');
  String get quickAccess => _t('quickAccess');
  String get addMedicine => _t('addMedicine');
  String get editMedicine => _t('editMedicine');
  String get deleteMedicine => _t('deleteMedicine');
  String get medicineName => _t('medicineName');
  String get dosage => _t('dosage');
  String get time => _t('time');
  String get frequency => _t('frequency');
  String get markTaken => _t('markTaken');
  String get markSkipped => _t('markSkipped');
  String get upcoming => _t('upcoming');
  String get taken => _t('taken');
  String get missed => _t('missed');
  String get skipped => _t('skipped');
  String get sosConfirmTitle => _t('sosConfirmTitle');
  String sosConfirmBody(String contact) => _t('sosConfirmBody', {'contact': contact});
  String get ok => _t('ok');
  String get cancel => _t('cancel');
  String get save => _t('save');
  String get delete => _t('delete');
  String get confirmDelete => _t('confirmDelete');
  String get signIn => _t('signIn');
  String get signUp => _t('signUp');
  String get email => _t('email');
  String get password => _t('password');
  String get name => _t('name');
  String get age => _t('age');
  String get bloodType => _t('bloodType');
  String get language => _t('language');
  String get logout => _t('logout');
  String get primaryContact => _t('primaryContact');
  String get addContact => _t('addContact');
  String get edit => _t('edit');
  String get editContact => _t('editContact');
  String get phone => _t('phone');
  String get relationship => _t('relationship');
  String get medicalHistory => _t('medicalHistory');
  String get addEntry => _t('addEntry');
  String get condition => _t('condition');
  String get notes => _t('notes');
  String get date => _t('date');
  String get weeklySummary => _t('weeklySummary');
  String missedCount(int count) => _t('missedCount', {'count': count.toString()});
  String get noMedicinesToday => _t('noMedicinesToday');
  String get noContacts => _t('noContacts');
  String get noHistory => _t('noHistory');
  String get loginError => _t('loginError');
  String get networkError => _t('networkError');
  String get loading => _t('loading');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'hi', 'mr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
