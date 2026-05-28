import 'package:flutter/material.dart';
import 'package:mute_mate/Components/HomeShellView.dart';
import 'package:mute_mate/Model/SignupRequestModel.dart';

enum SignupState { initial, loading, success, error }

class SignupViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final SignupRequestModel registrationData = SignupRequestModel();

  SignupState _state = SignupState.initial;
  SignupState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  final List<String> governorates = [
    'Cairo',
    'Giza',
    'Alexandria',
    'Qalyubia',
    'Sharqia',
    'Dakahlia',
  ];

  void setFirstName(String value) => registrationData.firstName = value;
  void setLastName(String value) => registrationData.lastName = value;
  void setEmail(String value) => registrationData.email = value;
  void setPassword(String value) {
    registrationData.password = value;
    notifyListeners();
  }

  void setMobileNumber(String value) => registrationData.mobileNumber = value;

  void setGovernorate(String? value) {
    if (value != null) {
      registrationData.governorate = value;
      notifyListeners();
    }
  }

  double get passwordStrength {
    if (registrationData.password.isEmpty) return 0.0;
    if (registrationData.password.length < 6) return 0.3;
    if (registrationData.password.contains(RegExp(r'[A-Z]')) &&
        registrationData.password.contains(RegExp(r'[0-9]')))
      return 1.0;
    return 0.6;
  }

  Future<void> submitSignup(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    formKey.currentState!.save();

    _state = SignupState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _state = SignupState.success;
      notifyListeners();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeShellView()),
      );
    } catch (e) {
      _state = SignupState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
