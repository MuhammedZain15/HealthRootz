import 'package:flutter/material.dart';

/// Simple hand-coded localizations for English and Arabic.
///
/// Usage:
///   final l10n = AppLocalizations.of(context);
///   l10n.translate('profile')
///
/// Wire up in MaterialApp:
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static const localizationsDelegates = <LocalizationsDelegate>[
    _AppLocalizationsDelegate(),
  ];

  // ── Translation tables ──────────────────────────────────────────────────────

  static const _en = <String, String>{
    // General
    'app_name': 'Health Rootz',
    'save': 'Save',
    'cancel': 'Cancel',
    'retry': 'Retry',
    'logout': 'Logout',
    // Profile sections
    'profile': 'Profile',
    'personal_information': 'Personal Information',
    'medical_information': 'Medical Information',
    'recent_visits': 'Recent Visits',
    'emergency_contacts': 'Emergency Contacts',
    'settings': 'Appearance & Language',
    // Personal fields
    'full_name': 'Full Name',
    'email': 'Email',
    'phone': 'Phone',
    'age': 'Age',
    'address': 'Address',
    'years_old': 'years old',
    'not_provided': 'Not provided',
    // Medical fields
    'gender': 'Gender',
    'medical_history': 'Medical History',
    // Visits
    'visits': 'Visits',
    'no_visits_yet': 'No visits yet',
    // Emergency contacts
    'no_emergency_contacts': 'No emergency contacts yet',
    'add_contacts_hint': 'Add contacts for quick access in emergencies',
    'add_manually': 'Add Manually',
    'add_from_contacts': 'Add from Contacts',
    'add_emergency_contact': 'Add Emergency Contact',
    'name': 'Name',
    'save_contact': 'Save Contact',
    'no_phone_number': 'Selected contact has no phone number',
    'contacts_permission_denied':
        'Contacts permission denied. Please enable it in settings.',
    'open_settings': 'Settings',
    // Settings section
    'theme': 'Theme',
    'dark_mode': 'Dark Mode',
    'light_mode': 'Light Mode',
    'language': 'Language',
    'switch_to_arabic': 'Switch to Arabic',
    'switch_to_english': 'Switch to English',
    // Chat
    'chat': 'Chat',
    'search_patients': 'Search patients...',
    'active_now': 'Active now',
    'tap_to_view_profile': 'Tap to view profile',
    'type_message': 'Type your message...',
    'no_phone_found': 'No phone number found for this patient.',
    // Appointments / History
    'appointments': 'Appointments',
    'history': 'History',
    // Navigation
    'home': 'Home',
    'alerts': 'Alerts',
    // Extended profile fields
    'date_of_birth': 'Date of Birth',
    'national_id': 'National ID',
    'insurance': 'Insurance',
    'blood_type': 'Blood Type',
    'add_contact': 'Add Contact',
    // History
    'diagnosis': 'Diagnosis',
    'treatment': 'Treatment',
    'date': 'Date',
    'doctor': 'Doctor',
    'no_history': 'No medical history found',
    'reading_details': 'Reading Details',
    // Common
    'loading': 'Loading...',
    'error': 'Error',
    'delete': 'Delete',
    'add': 'Add',
    'send': 'Send',
    'search': 'Search',
    'no_data': 'No data found',
    'confirm': 'Confirm',
    'edit': 'Edit',
    'back': 'Back',
    'next': 'Next',
    'done': 'Done',
    'yes': 'Yes',
    'no': 'No',
    // AI Analysis / Vital detail
    'ai_analysis': 'AI Analysis',
    'risk_level': 'Risk Level',
    'ai_confidence': 'AI Confidence',
    'heart_rate': 'Heart Rate',
    'spo2': 'SpO2',
    'temperature': 'Temperature',
    'emg': 'EMG',
    'blood_pressure': 'Blood Pressure',
    'risk_low': 'LOW',
    'risk_medium': 'MEDIUM',
    'risk_high': 'HIGH',
    'vitals_check': 'Vitals Check',
  };

  static const _ar = <String, String>{
    // General
    'app_name': 'هيلث روتز',
    'save': 'حفظ',
    'cancel': 'إلغاء',
    'retry': 'إعادة المحاولة',
    'logout': 'تسجيل الخروج',
    // Profile sections
    'profile': 'الملف الشخصي',
    'personal_information': 'المعلومات الشخصية',
    'medical_information': 'المعلومات الطبية',
    'recent_visits': 'الزيارات الأخيرة',
    'emergency_contacts': 'جهات الطوارئ',
    'settings': 'المظهر واللغة',
    // Personal fields
    'full_name': 'الاسم الكامل',
    'email': 'البريد الإلكتروني',
    'phone': 'الهاتف',
    'age': 'العمر',
    'address': 'العنوان',
    'years_old': 'سنة',
    'not_provided': 'غير محدد',
    // Medical fields
    'gender': 'الجنس',
    'medical_history': 'التاريخ الطبي',
    // Visits
    'visits': 'الزيارات',
    'no_visits_yet': 'لا توجد زيارات بعد',
    // Emergency contacts
    'no_emergency_contacts': 'لا توجد جهات طوارئ بعد',
    'add_contacts_hint': 'أضف جهات اتصال للوصول السريع في الطوارئ',
    'add_manually': 'إضافة يدوياً',
    'add_from_contacts': 'إضافة من جهات الاتصال',
    'add_emergency_contact': 'إضافة جهة طوارئ',
    'name': 'الاسم',
    'save_contact': 'حفظ جهة الاتصال',
    'no_phone_number': 'جهة الاتصال المختارة ليس لها رقم هاتف',
    'contacts_permission_denied': 'تم رفض إذن جهات الاتصال. يرجى تفعيله من الإعدادات.',
    'open_settings': 'الإعدادات',
    // Settings section
    'theme': 'المظهر',
    'dark_mode': 'الوضع الداكن',
    'light_mode': 'الوضع الفاتح',
    'language': 'اللغة',
    'switch_to_arabic': 'التبديل إلى العربية',
    'switch_to_english': 'Switch to English',
    // Chat
    'chat': 'المحادثات',
    'search_patients': 'ابحث عن مريض...',
    'active_now': 'نشط الآن',
    'tap_to_view_profile': 'اضغط لعرض الملف الشخصي',
    'type_message': 'اكتب رسالتك...',
    'no_phone_found': 'لا يوجد رقم هاتف لهذا المريض.',
    // Appointments / History
    'appointments': 'المواعيد',
    'history': 'السجل',
    // Navigation
    'home': 'الرئيسية',
    'alerts': 'التنبيهات',
    // Extended profile fields
    'date_of_birth': 'تاريخ الميلاد',
    'national_id': 'الرقم القومي',
    'insurance': 'التأمين',
    'blood_type': 'فصيلة الدم',
    'add_contact': 'إضافة جهة اتصال',
    // History
    'diagnosis': 'التشخيص',
    'treatment': 'العلاج',
    'date': 'التاريخ',
    'doctor': 'الطبيب',
    'no_history': 'لا يوجد سجل طبي',
    'reading_details': 'تفاصيل القراءة',
    // Common
    'loading': 'جارٍ التحميل...',
    'error': 'خطأ',
    'delete': 'حذف',
    'add': 'إضافة',
    'send': 'إرسال',
    'search': 'بحث',
    'no_data': 'لا توجد بيانات',
    'confirm': 'تأكيد',
    'edit': 'تعديل',
    'back': 'رجوع',
    'next': 'التالي',
    'done': 'تم',
    'yes': 'نعم',
    'no': 'لا',
    // AI Analysis / Vital detail
    'ai_analysis': 'تحليل الذكاء الاصطناعي',
    'risk_level': 'مستوى الخطورة',
    'ai_confidence': 'ثقة الذكاء الاصطناعي',
    'heart_rate': 'معدل ضربات القلب',
    'spo2': 'الأكسجين في الدم',
    'temperature': 'درجة الحرارة',
    'emg': 'نشاط العضلات',
    'blood_pressure': 'ضغط الدم',
    'risk_low': 'منخفض',
    'risk_medium': 'متوسط',
    'risk_high': 'مرتفع',
    'vitals_check': 'فحص العلامات الحيوية',
  };

  String translate(String key) {
    final lang = locale.languageCode;
    if (lang == 'ar') return _ar[key] ?? _en[key] ?? key;
    return _en[key] ?? key;
  }

  // Convenience getters (add more as needed)
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get theme => translate('theme');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');
  String get language => translate('language');
  String get logout => translate('logout');
  String get personalInformation => translate('personal_information');
  String get medicalInformation => translate('medical_information');
  String get recentVisits => translate('recent_visits');
  String get emergencyContacts => translate('emergency_contacts');
  String get addManually => translate('add_manually');
  String get addFromContacts => translate('add_from_contacts');
  String get noEmergencyContacts => translate('no_emergency_contacts');
  String get addContactsHint => translate('add_contacts_hint');
  String get switchToArabic => translate('switch_to_arabic');
  String get switchToEnglish => translate('switch_to_english');
  String get home => translate('home');
  String get history => translate('history');
  String get alerts => translate('alerts');
  String get chat => translate('chat');
  String get appointments => translate('appointments');
  // Extended profile fields
  String get personalInfo => translate('personal_information');
  String get phone => translate('phone');
  String get email => translate('email');
  String get address => translate('address');
  String get age => translate('age');
  String get gender => translate('gender');
  String get dateOfBirth => translate('date_of_birth');
  String get nationalId => translate('national_id');
  String get insurance => translate('insurance');
  String get bloodType => translate('blood_type');
  String get addContact => translate('add_contact');
  String get notProvided => translate('not_provided');
  String get name => translate('name');
  String get saveContact => translate('save_contact');
  String get addEmergencyContact => translate('add_emergency_contact');
  // History
  String get medicalHistory => translate('medical_history');
  String get diagnosis => translate('diagnosis');
  String get treatment => translate('treatment');
  String get date => translate('date');
  String get doctor => translate('doctor');
  String get noHistory => translate('no_history');
  String get readingDetails => translate('reading_details');
  String get visits => translate('visits');
  String get noVisitsYet => translate('no_visits_yet');
  // Common
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get add => translate('add');
  String get send => translate('send');
  String get search => translate('search');
  String get noData => translate('no_data');
  String get confirm => translate('confirm');
  String get edit => translate('edit');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');
  String get yes => translate('yes');
  String get no => translate('no');
  // AI Analysis / Vital detail
  String get aiAnalysis => translate('ai_analysis');
  String get riskLevel => translate('risk_level');
  String get aiConfidence => translate('ai_confidence');
  String get heartRate => translate('heart_rate');
  String get spo2 => translate('spo2');
  String get temperature => translate('temperature');
  String get emg => translate('emg');
  String get bloodPressure => translate('blood_pressure');
  String get riskLow => translate('risk_low');
  String get riskMedium => translate('risk_medium');
  String get riskHigh => translate('risk_high');
  String get vitalsCheck => translate('vitals_check');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// commit update
 