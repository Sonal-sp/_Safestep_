// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'सेफस्टेप';

  @override
  String get home => 'मुख्यपृष्ठ';

  @override
  String get medicines => 'औषधे';

  @override
  String get sos => 'SOS';

  @override
  String get history => 'इतिहास';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String greeting(String name) {
    return 'नमस्कार, $name!';
  }

  @override
  String get todayMedicines => 'आजची औषधे';

  @override
  String get quickAccess => 'जलद प्रवेश';

  @override
  String get addMedicine => 'औषध जोडा';

  @override
  String get editMedicine => 'औषध संपादित करा';

  @override
  String get deleteMedicine => 'औषध हटवा';

  @override
  String get medicineName => 'औषधाचे नाव';

  @override
  String get dosage => 'डोस';

  @override
  String get time => 'वेळ';

  @override
  String get frequency => 'वारंवारता';

  @override
  String get markTaken => 'घेतले';

  @override
  String get markSkipped => 'वगळले';

  @override
  String get upcoming => 'आगामी';

  @override
  String get taken => 'घेतले';

  @override
  String get missed => 'चुकले';

  @override
  String get skipped => 'वगळले';

  @override
  String get sosConfirmTitle => 'आणीबाणीचे अलर्ट';

  @override
  String sosConfirmBody(String contact) {
    return '$contact ला कॉल करत आहे आणि अलर्ट सेव करत आहे. सुरू ठेवायचे?';
  }

  @override
  String get ok => 'ठीक आहे';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get save => 'जतन करा';

  @override
  String get delete => 'हटवा';

  @override
  String get confirmDelete => 'खात्रीने हटवायचे का?';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signUp => 'खाते तयार करा';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get name => 'नाव';

  @override
  String get age => 'वय';

  @override
  String get bloodType => 'रक्त गट';

  @override
  String get language => 'भाषा';

  @override
  String get logout => 'लॉग आउट';

  @override
  String get primaryContact => 'प्राथमिक संपर्क';

  @override
  String get addContact => 'संपर्क जोडा';

  @override
  String get edit => 'संपादित करा';

  @override
  String get editContact => 'संपर्क संपादित करा';

  @override
  String get phone => 'फोन';

  @override
  String get relationship => 'नाते';

  @override
  String get medicalHistory => 'वैद्यकीय इतिहास';

  @override
  String get addEntry => 'नोंद जोडा';

  @override
  String get condition => 'स्थिती';

  @override
  String get notes => 'नोट्स';

  @override
  String get date => 'तारीख';

  @override
  String get weeklySummary => 'साप्ताहिक सारांश';

  @override
  String missedCount(int count) {
    return 'या आठवड्यात $count औषधे चुकली';
  }

  @override
  String get noMedicinesToday => 'आजसाठी कोणतीही औषध नियोजित नाही';

  @override
  String get noContacts => 'कोणताही आणीबाणी संपर्क जोडलेला नाही';

  @override
  String get noHistory => 'कोणतीही वैद्यकीय नोंद नाही';

  @override
  String get loginError => 'लॉगिन अयशस्वी. कृपया पुन्हा प्रयत्न करा.';

  @override
  String get networkError => 'निवड त्रुटी. कनेक्शन तपासा.';

  @override
  String get loading => 'लोड होत आहे...';
}
