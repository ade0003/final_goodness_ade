import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  String? deviceId;
  String? sessionId;

  static const String _deviceIdKey = 'device_id';
  static const String _sessionIdKey = 'session_id';

  AppState() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    deviceId = prefs.getString(_deviceIdKey);
    sessionId = prefs.getString(_sessionIdKey);
    notifyListeners();
  }

  Future<void> setDeviceId(String? id) async {
    deviceId = id;
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString(_deviceIdKey, id);
    } else {
      await prefs.remove(_deviceIdKey);
    }
    notifyListeners();
  }

  Future<void> setSessionId(String? id) async {
    sessionId = id;
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString(_sessionIdKey, id);
    } else {
      await prefs.remove(_sessionIdKey);
    }
    notifyListeners();
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);
    sessionId = null;
    notifyListeners();
  }
}
