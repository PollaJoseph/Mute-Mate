import 'dart:async';
import 'package:flutter/material.dart';

import 'package:mute_mate/Model/MedicalPhrase.dart';
import 'package:mute_mate/Model/TranslationSession.dart';

enum TranslationState { idle, recording, translating, playing }

class HomeViewModel extends ChangeNotifier {
  // 1. Core Controllers & Services
  final TextEditingController inputController = TextEditingController();
  final TranslationExpertSystem _expertSystem = TranslationExpertSystem();
  Timer? _debounceTimer;

  // 2. Private State Variables
  TranslationInputType _inputType = TranslationInputType.textAndVoice;
  TranslationInputType _outputType = TranslationInputType.signLanguage;
  TranslationState _state = TranslationState.idle;

  double _playbackSpeed = 1.0;
  bool _isVoiceSelected = false;
  bool _isCameraRecording = false;

  MedicalPhrase? currentTranslation;

  // 3. Public Getters
  TranslationInputType get inputType => _inputType;
  TranslationInputType get outputType => _outputType;
  TranslationState get state => _state;
  double get playbackSpeed => _playbackSpeed;
  bool get isVoiceSelected => _isVoiceSelected;
  bool get isCameraRecording => _isCameraRecording;

  // 4. Methods & Logic

  /// Handles keystrokes and auto-translates after a pause (Debouncing)
  void onInputTextChanged(String text) {
    // Cancel the previous timer if the user is still typing
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Start a new timer for 1.2 seconds
    _debounceTimer = Timer(const Duration(milliseconds: 1200), () {
      // When the timer finishes, check if there is text, then translate
      if (text.trim().isNotEmpty) {
        executeTranslation();
      }
    });
  }

  void toggleInputDevice(bool useVoice) {
    _isVoiceSelected = useVoice;
    notifyListeners();
  }

  void toggleCameraRecording() {
    _isCameraRecording = !_isCameraRecording;
    if (!_isCameraRecording) {
      // If stopped recording, auto-translate the captured video
      _executeSignToTextTranslation();
    }
    notifyListeners();
  }

  void swapTranslationModes() {
    final temp = _inputType;
    _inputType = _outputType;
    _outputType = temp;
    clearInputs(); // Reset UI on swap
    notifyListeners();
  }

  void changePlaybackSpeed() {
    _playbackSpeed = _playbackSpeed == 1.0
        ? 1.5
        : (_playbackSpeed == 1.5 ? 2.0 : 1.0);
    notifyListeners();
  }

  void clearInputs() {
    inputController.clear();
    currentTranslation = null;
    _state = TranslationState.idle;
    _isCameraRecording = false;
    notifyListeners();
  }

  // FLOW 1: Text -> Sign Language
  Future<void> executeTranslation() async {
    if (_inputType == TranslationInputType.textAndVoice) {
      if (inputController.text.isEmpty) return;

      _state = TranslationState.translating;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1)); // UX delay

      currentTranslation = _expertSystem.translateToSign(inputController.text);

      _state = TranslationState.playing;
      notifyListeners();
    }
  }

  // FLOW 2: Sign Language -> Text/Voice
  Future<void> _executeSignToTextTranslation() async {
    _state = TranslationState.translating;
    notifyListeners();

    // Pass a dummy video path to the expert system
    currentTranslation = await _expertSystem.processSignVideo("dummy_path.mp4");

    _state = TranslationState.playing;
    notifyListeners();
  }

  void playTranslatedAudio() {
    if (currentTranslation != null &&
        currentTranslation!.audioAssetPath.isNotEmpty) {
      // TODO: Use audioplayers package to play currentTranslation!.audioAssetPath
      debugPrint("Playing Audio: ${currentTranslation!.audioAssetPath}");
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    _debounceTimer?.cancel(); // Clean up the timer when the screen closes
    super.dispose();
  }
}
