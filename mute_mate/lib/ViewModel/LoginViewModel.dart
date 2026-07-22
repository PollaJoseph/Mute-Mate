import 'package:flutter/material.dart';

enum LoginState { initial, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  String _email = '';
  String _password = '';
  bool _isPasswordObscured = true;
  LoginState _state = LoginState.initial;
  String _errorMessage = '';

  // Getters
  String get email => _email;
  String get password => _password;
  bool get isPasswordObscured => _isPasswordObscured;
  LoginState get state => _state;
  String get errorMessage => _errorMessage;

  // Setters & Actions
  void setEmail(String value) {
    _email = value;
  }

  void setPassword(String value) {
    _password = value;
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  Future<void> submitLogin(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    _state = LoginState.loading;
    notifyListeners();

    try {
      // Simulate API network request latency
      await Future.delayed(const Duration(seconds: 2));

      _state = LoginState.success;
      notifyListeners();

      // Navigate to your Shell View dashboard upon success
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeShellView()));
    } catch (e) {
      _state = LoginState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
