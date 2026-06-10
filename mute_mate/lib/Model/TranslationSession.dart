enum TranslationInputType { textAndVoice, signLanguage }

class TranslationSession {
  final String inputContent;
  final String videoOrGifAssetPath;
  final double playbackSpeed;

  const TranslationSession({
    required this.inputContent,
    required this.videoOrGifAssetPath,
    this.playbackSpeed = 1.0,
  });
}
