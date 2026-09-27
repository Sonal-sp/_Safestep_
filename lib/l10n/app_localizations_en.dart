// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SafeStep';

  @override
  String get home => 'Home';

  @override
  String get medicines => 'Medicines';

  @override
  String get sos => 'SOS';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String greeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get todayMedicines => 'Today Medicines';

  @override
  String get quickAccess => 'Quick Access';

  @override
  String get addMedicine => 'Add Medicine';

  @override
  String get editMedicine => 'Edit Medicine';

  @override
  String get deleteMedicine => 'Delete Medicine';

  @override
  String get medicineName => 'Medicine Name';

  @override
  String get dosage => 'Dosage';

  @override
  String get time => 'Time';

  @override
  String get frequency => 'Frequency';

  @override
  String get markTaken => 'Mark Taken';

  @override
  String get markSkipped => 'Mark Skipped';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get taken => 'Taken';

  @override
  String get missed => 'Missed';

  @override
  String get skipped => 'Skipped';

  @override
  String get sosConfirmTitle => 'Emergency Alert';

  @override
  String sosConfirmBody(String contact) {
    return 'Calling $contact and saving alert. Continue?';
  }

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirmDelete => 'Are you sure you want to delete?';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Create Account';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get age => 'Age';

  @override
  String get bloodType => 'Blood Type';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Log Out';

  @override
  String get primaryContact => 'Primary Contact';

  @override
  String get addContact => 'Add Contact';

  @override
  String get edit => 'Edit';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get phone => 'Phone';

  @override
  String get relationship => 'Relationship';

  @override
  String get medicalHistory => 'Medical History';

  @override
  String get addEntry => 'Add Entry';

  @override
  String get condition => 'Condition';

  @override
  String get notes => 'Notes';

  @override
  String get date => 'Date';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String missedCount(int count) {
    return 'You missed $count medicines this week';
  }

  @override
  String get noMedicinesToday => 'No medicines scheduled for today';

  @override
  String get noContacts => 'No emergency contacts added';

  @override
  String get noHistory => 'No medical history entries';

  @override
  String get loginError => 'Login failed. Please try again.';

  @override
  String get networkError => 'Network error. Please check your connection.';

  @override
  String get loading => 'Loading...';
}
