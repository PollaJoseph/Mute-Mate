import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:mute_mate/Model/MedicalPhrase.dart';
import 'package:mute_mate/Model/SignPhrase.dart';
import 'package:mute_mate/Model/TranslationSession.dart';

enum TranslationState { idle, listening, translating, playing }

class HomeViewModel extends ChangeNotifier {
  // ─── Core Services ──────────────────────────────────────────────────────
  final TextEditingController inputController = TextEditingController();
  final TranslationExpertSystem _expertSystem = TranslationExpertSystem();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  Timer? _debounceTimer;

  // ─── Translation Mode ────────────────────────────────────────────────────
  TranslationInputType _inputType = TranslationInputType.textAndVoice;
  TranslationInputType _outputType = TranslationInputType.signLanguage;

  // ─── State ───────────────────────────────────────────────────────────────
  TranslationState _state = TranslationState.idle;
  bool _isListening = false;
  bool _isCameraRecording = false;
  bool _isSpeechAvailable = false;
  bool _isTtsSpeaking = false;

  // ─── Expert System Results ────────────────────────────────────────────────
  MatchResult? _currentResult;
  List<MatchResult> _suggestions = [];
  PhraseCategory? _selectedCategory;

  // ─── Getters ─────────────────────────────────────────────────────────────
  TranslationInputType get inputType => _inputType;
  TranslationInputType get outputType => _outputType;
  TranslationState get state => _state;
  bool get isListening => _isListening;
  bool get isCameraRecording => _isCameraRecording;
  bool get isSpeechAvailable => _isSpeechAvailable;
  bool get isTtsSpeaking => _isTtsSpeaking;
  MatchResult? get currentResult => _currentResult;
  List<MatchResult> get suggestions => _suggestions;
  PhraseCategory? get selectedCategory => _selectedCategory;

  /// Convenience getter — the best-match phrase (or null)
  SignPhrase? get currentPhrase => _currentResult?.phrase;

  /// Confidence as 0–100 integer, or null when no result
  int? get matchConfidencePercent => _currentResult?.confidencePercent;

  // ─── Initialisation ───────────────────────────────────────────────────────

  HomeViewModel() {
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    _isSpeechAvailable = await _speechToText.initialize(
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        _isListening = false;
        if (_state == TranslationState.listening) {
          _state = TranslationState.idle;
        }
        notifyListeners();
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          if (_state == TranslationState.listening) {
            _state = TranslationState.idle;
          }
          notifyListeners();
        }
      },
    );
    notifyListeners();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isTtsSpeaking = true;
      notifyListeners();
    });
    _flutterTts.setCompletionHandler(() {
      _isTtsSpeaking = false;
      notifyListeners();
    });
    _flutterTts.setErrorHandler((msg) {
      _isTtsSpeaking = false;
      notifyListeners();
    });
  }

  // ─── Input: Text ──────────────────────────────────────────────────────────

  /// Debounces keystrokes and auto-translates after 1.2 s of inactivity.
  void onInputTextChanged(String text) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1200), () {
      if (text.trim().isNotEmpty) executeTranslation();
    });
  }

  // ─── Input: Voice (Speech-to-Text) ────────────────────────────────────────

  /// Toggles between mic (voice) and keyboard input.
  /// When switching to mic, immediately starts listening.
  Future<void> toggleVoiceListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    if (!_isSpeechAvailable) return;

    inputController.clear();
    _currentResult = null;
    _suggestions = [];
    _state = TranslationState.listening;
    _isListening = true;
    notifyListeners();

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        localeId: 'ar-SA',
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    _state = TranslationState.idle;
    notifyListeners();
    // Auto-translate whatever was captured
    if (inputController.text.trim().isNotEmpty) {
      await executeTranslation();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    inputController.text = result.recognizedWords;
    inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: inputController.text.length),
    );
    notifyListeners();

    // Auto-translate on a final (confirmed) result
    if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
      _isListening = false;
      executeTranslation();
    }
  }

  // ─── Translation: Text / Voice → Sign ─────────────────────────────────────

  Future<void> executeTranslation() async {
    if (_inputType != TranslationInputType.textAndVoice) return;
    if (inputController.text.trim().isEmpty) return;

    _state = TranslationState.translating;
    _isListening = false;
    notifyListeners();

    // Small UX delay so the spinner is visible
    await Future.delayed(const Duration(milliseconds: 600));

    _currentResult = _expertSystem.translateToSign(
      inputController.text,
      category: _selectedCategory,
    );

    _suggestions = _expertSystem.getSuggestions(
      inputController.text,
      category: _selectedCategory,
      exclude: _currentResult?.phrase,
      limit: 3,
    );

    _state = TranslationState.playing;
    notifyListeners();
  }

  // ─── Translation: Sign → Text / Voice ────────────────────────────────────

  void toggleCameraRecording() {
    _isCameraRecording = !_isCameraRecording;
    if (!_isCameraRecording) {
      _executeSignToTextTranslation();
    }
    notifyListeners();
  }

  Future<void> _executeSignToTextTranslation() async {
    _state = TranslationState.translating;
    notifyListeners();

    _currentResult = await _expertSystem.processSignVideo('dummy_path.mp4');
    _suggestions = [];

    _state = TranslationState.playing;
    notifyListeners();
  }

  // ─── Output: Text-to-Speech ───────────────────────────────────────────────

  Future<void> speakTranslation() async {
    final text = _currentResult?.phrase.arabicText;
    if (text == null || text.isEmpty) return;

    if (_isTtsSpeaking) {
      await _flutterTts.stop();
    } else {
      await _flutterTts.speak(text);
    }
  }

  // ─── Category Filter ─────────────────────────────────────────────────────

  void selectCategory(PhraseCategory? category) {
    _selectedCategory = _selectedCategory == category ? null : category;
    notifyListeners();
    // Re-run translation if we have input text
    if (inputController.text.trim().isNotEmpty) {
      executeTranslation();
    }
  }

  // ─── Quick-select a Suggestion ────────────────────────────────────────────

  void applySuggestion(MatchResult result) {
    inputController.text = result.phrase.arabicText;
    _currentResult = result;
    _suggestions = [];
    _state = TranslationState.playing;
    notifyListeners();
  }

  // ─── Mode Swap ───────────────────────────────────────────────────────────

  void swapTranslationModes() {
    final temp = _inputType;
    _inputType = _outputType;
    _outputType = temp;
    clearInputs();
  }

  // ─── Utilities ────────────────────────────────────────────────────────────

  void clearInputs() {
    inputController.clear();
    _currentResult = null;
    _suggestions = [];
    _state = TranslationState.idle;
    _isListening = false;
    _isCameraRecording = false;
    notifyListeners();
  }

  @override
  void dispose() {
    inputController.dispose();
    _debounceTimer?.cancel();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }
}
