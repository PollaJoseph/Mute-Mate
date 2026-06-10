/// Core domain model for a Sign Language phrase entry.
/// Arabic is the primary language; English is a secondary reference.
enum PhraseCategory { medical, greeting, emergency, daily, emotion }

extension PhraseCategoryExtension on PhraseCategory {
  String get arabicLabel {
    switch (this) {
      case PhraseCategory.medical:
        return 'طبي';
      case PhraseCategory.greeting:
        return 'تحيات';
      case PhraseCategory.emergency:
        return 'طوارئ';
      case PhraseCategory.daily:
        return 'يومي';
      case PhraseCategory.emotion:
        return 'مشاعر';
    }
  }

  String get emoji {
    switch (this) {
      case PhraseCategory.medical:
        return '🏥';
      case PhraseCategory.greeting:
        return '👋';
      case PhraseCategory.emergency:
        return '🚨';
      case PhraseCategory.daily:
        return '💬';
      case PhraseCategory.emotion:
        return '😊';
    }
  }
}

/// A single bilingual phrase entry in the sign language knowledge base.
class SignPhrase {
  /// Unique identifier used to reference assets (e.g., "need_doctor")
  final String id;

  /// Primary Arabic text
  final String arabicText;

  /// Secondary English translation
  final String englishText;

  /// Arabic keywords used by the expert system for fuzzy matching
  final List<String> keywords;

  /// Path to the sign language animation (GIF / video asset)
  final String signAssetPath;

  /// Path to the corresponding audio asset (MP3)
  final String audioAssetPath;

  /// Semantic category of this phrase
  final PhraseCategory category;

  const SignPhrase({
    required this.id,
    required this.arabicText,
    required this.englishText,
    required this.keywords,
    required this.signAssetPath,
    required this.audioAssetPath,
    required this.category,
  });
}

/// Wraps a [SignPhrase] with a confidence score produced by the expert system.
class MatchResult {
  final SignPhrase phrase;

  /// Confidence in range [0.0, 1.0] where 1.0 is a perfect match
  final double confidence;

  const MatchResult({required this.phrase, required this.confidence});

  /// Confidence as an integer percentage (0–100)
  int get confidencePercent => (confidence * 100).round();

  bool get isHighConfidence => confidence >= 0.8;
  bool get isMediumConfidence => confidence >= 0.5 && confidence < 0.8;
  bool get isLowConfidence => confidence < 0.5;
}
