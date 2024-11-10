import 'package:shared_preferences/shared_preferences.dart';

class BusinessConfig {
  static const String _businessNameKey = 'businessName';
  static const String _addressKey = 'address';
  static const String _phoneKey = 'phone';
  static const String _businessIDKey = 'businessID';
  static const String _licenseKeyKey = 'licenseKey';

  // Save business info to SharedPreferences
  static Future<void> saveBusinessInfo(String businessName, String address,
      String phone, String businessID) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessNameKey, businessName);
    await prefs.setString(_addressKey, address);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_businessIDKey, businessID);
  }

  // Retrieve business info as a Map
  static Future<Map<String, String?>> getBusinessInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'businessName': prefs.getString(_businessNameKey),
      'address': prefs.getString(_addressKey),
      'phone': prefs.getString(_phoneKey),
      'businessID': prefs.getString(_businessIDKey),
    };
  }

  // Save license key to SharedPreferences
  static Future<void> saveLicenseKey(String licenseKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseKeyKey, licenseKey);
  }

  // Retrieve license key
  static Future<String?> getLicenseKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_licenseKeyKey);
  }

  // Check if business info is set
  static Future<bool> isBusinessInfoSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessNameKey) != null;
  }
}
