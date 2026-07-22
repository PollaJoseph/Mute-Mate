import 'package:flutter/material.dart';

enum SosState { idle, sending, sent, error }

class EmergencyViewModel extends ChangeNotifier {
  SosState _state = SosState.idle;
  SosState get state => _state;

  Future<void> sendSosAlert() async {
    if (_state == SosState.sending) return;

    _state = SosState.sending;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      _state = SosState.sent;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 3));
      _state = SosState.idle;
      notifyListeners();
    } catch (e) {
      _state = SosState.error;
      notifyListeners();
    }
  }

  void callEmergencyServices() {
    debugPrint("Launching emergency dialer...");
  }
}
