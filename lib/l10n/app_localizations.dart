import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const _supportedLocales = ['en', 'am'];
  static const Locale en = Locale('en');
  static const Locale am = Locale('am');

  static bool isSupported(Locale locale) => _supportedLocales.contains(locale.languageCode);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appName': 'Yum Inventory',
      'dashboard': 'Dashboard',
      'pos': 'POS',
      'posSale': 'Point of Sale',
      'saleHistory': 'Sale History',
      'manageData': 'Manage Data',
      'categories': 'Categories',
      'categoriesDesc': 'Identify item types (e.g. Electronics, Clothing)',
      'units': 'Units',
      'unitsDesc': 'How items are measured (e.g. by count, kg, liter)',
      'brands': 'Brands',
      'brandsDesc': 'Company or product names (e.g. Samsung, Apple)',
      'customers': 'Customers',
      'customersDesc': 'Individuals or organizations who purchase products',
      'warehouses': 'Warehouses',
      'warehousesDesc': 'Large storage facilities for inventory',
      'locations': 'Locations',
      'locationsDesc': 'Detailed place where warehouse or item is stored',
      'settings': 'Settings',
      'logout': 'Logout',
      'language': 'Language',
      'english': 'English',
      'amharic': 'Amharic',
      'selectLanguage': 'Select Language',
      'signIn': 'Sign In',
      'username': 'Username',
      'password': 'Password',
      'enterUsername': 'Enter your username',
      'enterPassword': 'Enter your password',
      'forgotPassword': 'Forgot password?',
      'invalidCredentials': 'Invalid username or password',
      'welcome': 'Welcome',
      'signInToManage': 'Sign in to manage your inventory',
      'overview': 'Overview of your business metrics',
      'createSale': 'Create new sales transactions',
      'viewHistory': 'View past transaction records',
      'totalSales': 'Total Sales',
      'orders': 'Orders',
      'revenue': 'Revenue',
      'products': 'Products',
      'growth': 'Growth',
      'developedBy': 'developed by Yasu Solurions',
      'admin': 'Admin',
      'cashier': 'Cashier',
      'manager': 'Manager',
      'seller': 'Seller',
      'fullAccess': 'You have full system access',
      'processTransactions': 'Process customer transactions',
      'overseeOperations': 'Oversee operations and reports',
      'manageSales': 'Manage your sales and inventory',
      'appTitle': 'Inventory App',
      'inventoryItems': 'Manage your products and stock levels',
    },
    'am': {
      'appName': 'የኢንቬንቶሪ አስተዳደር',
      'dashboard': 'ዳሽቦርድ',
      'pos': 'POS',
      'posSale': 'የግብይት መፈጸሚያ',
      'saleHistory': 'የሽያጭ ታሪክ',
      'manageData': 'መረጃ አስተዳደር',
      'categories': 'ምድቦች',
      'categoriesDesc': 'የዕቃዎችን ዓይነት መለያ (ለምሳሌ፦ ኤሌክትሮኒክስ፣ አልባሳት)',
      'units': 'መመጠኛዎች',
      'unitsDesc': 'ዕቃዎች የሚለኩበት (ለምሳሌ፦ በቁጥር፣ በኪሎ፣ በሊትር)',
      'brands': 'ብራንዶች / ምርቶች',
      'brandsDesc': 'የኩባንያ ስሞች (ለምሳሌ፦ ሳምሰንግ፣ አፕል)',
      'customers': 'ደንበኞች',
      'customersDesc': 'ምርቱን የሚገዙ ግለሰቦች ወይም ድርጅቶች',
      'warehouses': 'መጋዘኖች',
      'warehousesDesc': 'ዕቃዎቹ የሚቀመጡባቸው ትላልቅ ቦታዎች',
      'locations': 'አድራሻዎች / ቦታዎች',
      'locationsDesc': 'መጋዘኑ የሚገኝበት ወይም ዕቃው የተቀመጠበት ዝርዝር ቦታ',
      'settings': 'ማስተካከያ',
      'logout': 'ውጣ',
      'language': 'ቋንቋ',
      'english': 'እንግሊዝኛ',
      'amharic': 'አማርኛ',
      'selectLanguage': 'ቋንቋ ይምረጡ',
      'signIn': 'ግባ',
      'username': 'የተጠቃሚ ስም',
      'password': 'የይለፍ ቃል',
      'enterUsername': 'የተጠቃሚ ስምዎን ያስገቡ',
      'enterPassword': 'የይለፍ ቃልዎን ያስገቡ',
      'forgotPassword': 'የይለፍ ቃል ረስተዋል?',
      'invalidCredentials': 'ልክ ያልሆነ የተጠቃሚ ስም ወይም የይለፍ ቃል',
      'welcome': 'እንኳን ደህና መጡ',
      'signInToManage': 'ኢንቬንቶሪዎን ለማስተዳደር ይግቡ',
      'overview': 'የንግድ መረጃ አጠቃላይ እይታ',
      'createSale': 'አዲስ የሽያጭ ግብይት ይፍጠሩ',
      'viewHistory': 'ያለፉ ግብይቶችን ይመልከቱ',
      'totalSales': 'ጠቅላላ ሽያጭ',
      'orders': 'ትዕዛዞች',
      'revenue': 'ገቢ',
      'products': 'ምርቶች',
      'growth': 'እድገት',
      'developedBy': 'በያሱ ሶሉሪዎንስ የተሰራ',
      'admin': 'አድሚን',
      'cashier': 'ካሽየር',
      'manager': 'ማኔጀር',
      'seller': 'ሻጭ',
      'fullAccess': 'ሙሉ የስርዓት መዳረሻ አለዎት',
      'processTransactions': 'የደንበኞችን ግብይት ያካሂዱ',
      'overseeOperations': 'እንቅስቃሴዎችን እና ሪፖርቶችን ይቆጣጠሩ',
      'manageSales': 'ሽያጮችዎን እና ኢንቬንቶሪዎን ያስተዳድሩ',
      'appTitle': 'የኢንቬንቶሪ መተግበሪያ',
      'inventoryItems': 'ምርቶችን እና የክምችት ደረጃዎችን ያስተዳድሩ',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  static final AppLocalizationsDelegate delegate = AppLocalizationsDelegate();
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
