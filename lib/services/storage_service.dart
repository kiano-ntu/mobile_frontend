import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/app_config.dart';
import '../models/user.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static SharedPreferences? _prefs;

  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ============= TOKEN MANAGEMENT =============
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConfig.authTokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConfig.authTokenKey);
  }

  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConfig.authTokenKey);
  }

  // ============= USER DATA MANAGEMENT =============
  static Future<void> saveUser(User user) async {
    await init();
    final userJson = jsonEncode(user.toJson());
    await _prefs!.setString(AppConfig.userDataKey, userJson);
    await _prefs!.setString(AppConfig.userRoleKey, user.role);
  }

  static Future<User?> getUser() async {
    await init();
    final userJson = _prefs!.getString(AppConfig.userDataKey);
    final userRole = _prefs!.getString(AppConfig.userRoleKey);
    
    if (userJson != null && userRole != null) {
      try {
        final userMap = jsonDecode(userJson);
        return User(
          id: userMap['id'],
          name: userMap['name'],
          email: userMap['email'],
          role: userMap['role'],
          phone: userMap['phone'],
          additionalData: userMap['additionalData'],
        );
      } catch (e) {
        print('Error parsing user data: $e');
        return null;
      }
    }
    return null;
  }

  static Future<String?> getUserRole() async {
    await init();
    return _prefs!.getString(AppConfig.userRoleKey);
  }

  static Future<void> deleteUser() async {
    await init();
    await _prefs!.remove(AppConfig.userDataKey);
    await _prefs!.remove(AppConfig.userRoleKey);
  }

  // ============= CHECK AUTH STATUS =============
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ============= CLEAR ALL DATA =============
  static Future<void> clearAll() async {
    await deleteToken();
    await deleteUser();
    await init();
    await _prefs!.clear();
  }

  // ============= ADDITIONAL STORAGE =============
  static Future<void> saveString(String key, String value) async {
    await init();
    await _prefs!.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await init();
    await _prefs!.setBool(key, value);
  }

  static Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await init();
    return _prefs!.getBool(key) ?? defaultValue;
  }

  static Future<void> saveInt(String key, int value) async {
    await init();
    await _prefs!.setInt(key, value);
  }

  static Future<int> getInt(String key, {int defaultValue = 0}) async {
    await init();
    return _prefs!.getInt(key) ?? defaultValue;
  }
}