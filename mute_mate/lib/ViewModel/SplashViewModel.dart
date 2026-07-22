import 'package:flutter/material.dart';

enum SplashNavigationState { loading, navigateToNextScreen }

class SplashViewModel extends ChangeNotifier {
  SplashNavigationState _state = SplashNavigationState.loading;
  SplashNavigationState get state => _state;

  Future<void> initializeApp() async {
    await Future.delayed(const Duration(seconds: 5));
    _state = SplashNavigationState.navigateToNextScreen;
    notifyListeners();
  }
}
