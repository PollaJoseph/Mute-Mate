import 'package:mute_mate/Model/SignLanguageDataset.dart';
import 'package:mute_mate/Model/SignPhrase.dart';

/// The Translation Expert System — a rule-based, offline matching engine.
///
/// Scoring tiers:
///   1.0      → exact text match
///   0.85–0.99→ phrase fully contained in input or vice-versa
///   0.60–0.84→ all keywords present in input
///   0.35–0.59→ partial keyword overlap
///   0.10–0.34→ character-level word overlap
///   0.00     → no match
class TranslationExpertSystem {
  static final TranslationExpertSystem _instance =
      TranslationExpertSystem._internal();
  factory TranslationExpertSystem() => _instance;
  TranslationExpertSystem._internal();

  // ─── Arabic text normalisation ─────────────────────────────────────────
  // Removes diacritics (harakat), tatweel, and normalises alef variants so
  // "أحتاج" and "احتاج" both match the same keyword.

  static final _diacriticsRegex =
      RegExp(r'[\u064B-\u065F\u0670\u0640]'); // harakat + shadda + tatweel
  static final _alefRegex = RegExp(r'[أإآ]');

  String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(_diacriticsRegex, '')
        .replaceAll(_alefRegex, 'ا')
        .trim();
  }

  // ─── Scoring ───────────────────────────────────────────────────────────

  double _score(String normalizedInput, SignPhrase phrase) {
    final normalizedPhrase = _normalize(phrase.arabicText);
    final normalizedKeywords = phrase.keywords.map(_normalize).toList();

    // Tier 1: exact match
    if (normalizedInput == normalizedPhrase) return 1.0;

    // Tier 2: containment (e.g. user typed a longer sentence containing the phrase)
    if (normalizedInput.contains(normalizedPhrase) ||
        normalizedPhrase.contains(normalizedInput)) {
      return 0.85 +
          0.14 *
              (normalizedPhrase.length / (normalizedInput.length + 1)).clamp(
                0.0,
                1.0,
              );
    }

    // Tier 3: all keywords present
    final matchedAll =
        normalizedKeywords.every((kw) => normalizedInput.contains(kw));
    if (matchedAll && normalizedKeywords.isNotEmpty) {
      return 0.60 +
          0.24 *
              (normalizedKeywords.length / (normalizedKeywords.length + 1.0))
                  .clamp(0.0, 1.0);
    }

    // Tier 4: partial keyword overlap
    int keywordsMatched = normalizedKeywords
        .where((kw) => normalizedInput.contains(kw))
        .length;
    if (keywordsMatched > 0) {
      return 0.35 +
          0.24 *
              (keywordsMatched / normalizedKeywords.length).clamp(0.0, 1.0);
    }

    // Tier 5: word-level overlap on the phrase text
    final inputWords = normalizedInput
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1)
        .toList();
    final phraseWords = normalizedPhrase
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1)
        .toList();

    int wordOverlap =
        inputWords.where((w) => phraseWords.contains(w)).length;
    if (wordOverlap > 0 && inputWords.isNotEmpty) {
      return 0.10 +
          0.24 *
              (wordOverlap / inputWords.length).clamp(0.0, 1.0);
    }

    return 0.0;
  }

  // ─── Public API ────────────────────────────────────────────────────────

  /// Returns the single best [MatchResult] for a given Arabic [input], optionally
  /// restricted to a [category]. Returns null if no phrase scores above zero.
  MatchResult? translateToSign(
    String input, {
    PhraseCategory? category,
  }) {
    if (input.trim().isEmpty) return null;

    final normalizedInput = _normalize(input);
    final pool = SignLanguageDataset.byCategory(category);

    MatchResult? best;
    for (final phrase in pool) {
      final s = _score(normalizedInput, phrase);
      if (s > 0.0 && (best == null || s > best.confidence)) {
        best = MatchResult(phrase: phrase, confidence: s);
      }
    }
    return best;
  }

  /// Returns the top-[limit] matches above the [minConfidence] threshold,
  /// excluding the [exclude] phrase (typically the best match already shown).
  List<MatchResult> getSuggestions(
    String input, {
    PhraseCategory? category,
    SignPhrase? exclude,
    int limit = 3,
    double minConfidence = 0.20,
  }) {
    if (input.trim().isEmpty) return [];

    final normalizedInput = _normalize(input);
    final pool = SignLanguageDataset.byCategory(category);

    final results = pool
        .where((p) => p.id != exclude?.id)
        .map((p) => MatchResult(phrase: p, confidence: _score(normalizedInput, p)))
        .where((r) => r.confidence >= minConfidence)
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return results.take(limit).toList();
  }

  /// Simulates sign-language-to-text video recognition (mock for Phase 1).
  /// Replace with a real CV model call in Phase 2.
  Future<MatchResult?> processSignVideo(String videoPath) async {
    await Future.delayed(const Duration(seconds: 2));
    // Mock: always returns the first phrase as a placeholder result
    return MatchResult(
      phrase: SignLanguageDataset.allPhrases.first,
      confidence: 0.72,
    );
  }
}
