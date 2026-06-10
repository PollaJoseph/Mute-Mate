class MedicalPhrase {
  final String text;
  final String signAssetPath;
  final String audioAssetPath;

  const MedicalPhrase({
    required this.text,
    required this.signAssetPath,
    required this.audioAssetPath,
  });
}

class TranslationExpertSystem {
  static final TranslationExpertSystem _instance =
      TranslationExpertSystem._internal();
  factory TranslationExpertSystem() => _instance;
  TranslationExpertSystem._internal();

  final List<MedicalPhrase> _database = [
    const MedicalPhrase(
      text: "I need a doctor",
      signAssetPath: "assets/animations/need_doctor.gif",
      audioAssetPath: "assets/audio/need_doctor.mp3",
    ),
    const MedicalPhrase(
      text: "Where is the emergency room?",
      signAssetPath: "assets/animations/where_er.gif",
      audioAssetPath: "assets/audio/where_er.mp3",
    ),
    const MedicalPhrase(
      text: "I am in pain",
      signAssetPath: "assets/animations/in_pain.gif",
      audioAssetPath: "assets/audio/in_pain.mp3",
    ),
  ];

  final MedicalPhrase _fallback = const MedicalPhrase(
    text: "Translating...",
    signAssetPath: "assets/images/signup_character.png",
    audioAssetPath: "",
  );

  MedicalPhrase translateToSign(String input) {
    if (input.trim().isEmpty) return _fallback;

    final lowerInput = input.toLowerCase();

    for (var phrase in _database) {
      if (lowerInput.contains(phrase.text.toLowerCase()) ||
          phrase.text.toLowerCase().contains(lowerInput)) {
        return phrase;
      }
    }
    return _fallback; // Return default if no match found
  }

  /// Here, we mock the video recognition result.
  Future<MedicalPhrase> processSignVideo(String videoPath) async {
    // Simulate AI Computer Vision processing time
    await Future.delayed(const Duration(seconds: 3));

    // Mock result: returning a predefined translation
    return _database.first; // Returns "I need a doctor" as a test
  }
}
