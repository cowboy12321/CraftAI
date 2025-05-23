import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  int? _userId;
  String? _username;
  String? _token; // 新增 token
  String? _error;
  bool _isLoading = false;

  int? get userId => _userId;
  String? get username => _username;
  String? get token => _token; // 新增 getter
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<bool> register(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.register(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(username, password);
      _userId = response['user_id'];
      _username = username;
      _token = response['token']; // 保存 token
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(int userId, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.changePassword(userId, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _userId = null;
    _username = null;
    _token = null; // 清除 token
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}