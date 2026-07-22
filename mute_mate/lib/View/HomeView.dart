import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mute_mate/Constants.dart';
import 'package:mute_mate/Model/SignPhrase.dart';
import 'package:mute_mate/Model/TranslationSession.dart';
import 'package:mute_mate/ViewModel/HomeViewModel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late final HomeViewModel _viewModel;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();

    // Pulsing animation for the mic button while listening
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider<HomeViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // ── Background ─────────────────────────────────────────────
            Positioned.fill(
              child: Image.asset(
                Constants.LightBackgroundPath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            Positioned(
              bottom: -20,
              right: -10,
              child: Opacity(
                opacity: 0.35,
                child: Image.asset(
                  Constants.StethoscopePath,
                  width: size.width * 0.6,
                ),
              ),
            ),

            // ── Main Layout ────────────────────────────────────────────
            SafeArea(
              child: Consumer<HomeViewModel>(
                builder: (context, vm, _) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),

                        // ── Header ───────────────────────────────────
                        const Text(
                          'ميت ميت',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ترجمة لغة الإشارة للصم وضعاف السمع',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // ── Mode Switcher ─────────────────────────────
                        _buildModeSwitcher(vm),
                        const SizedBox(height: 18),

                        // ── Dynamic Content ───────────────────────────
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.06),
                                end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                          ),
                          child: vm.inputType ==
                                  TranslationInputType.textAndVoice
                              ? _buildTextToSignFlow(vm, size)
                              : _buildSignToTextFlow(vm, size),
                        ),

                        const SizedBox(height: 28),

                        // ── Action Bar ────────────────────────────────
                        _buildActionBar(vm),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 1: Text / Voice → Sign Language
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTextToSignFlow(HomeViewModel vm, Size size) {
    return Column(
      key: const ValueKey('flow_text_to_sign'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Input panel ──────────────────────────────────────────────────
        _buildInputPanel(vm),
        const SizedBox(height: 14),

        // 2. Category chips ────────────────────────────────────────────────
        _buildCategoryChips(vm),
        const SizedBox(height: 16),

        // 3. Avatar / Sign output panel ────────────────────────────────────
        _buildAvatarPanel(vm, size),

        // 4. Suggestion chips (shown when confidence < 80 %) ───────────────
        if (vm.suggestions.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildSuggestions(vm),
        ],
      ],
    );
  }

  Widget _buildInputPanel(HomeViewModel vm) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text field (RTL for Arabic)
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextFormField(
              controller: vm.inputController,
              maxLines: null,
              onChanged: vm.onInputTextChanged,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => vm.executeTranslation(),
              decoration: InputDecoration(
                hintText: vm.isListening
                    ? 'جارٍ الاستماع...'
                    : 'اكتب أو تحدث بالعربية...',
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.45),
                  fontSize: 17,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Toolbar row: keyboard | status | mic
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Keyboard toggle
              GestureDetector(
                onTap: () {
                  if (vm.isListening) vm.toggleVoiceListening();
                },
                child: Icon(
                  Icons.keyboard_alt_outlined,
                  color: !vm.isListening
                      ? const Color(0xFF2B6B99)
                      : Colors.black38,
                  size: 22,
                ),
              ),

              // Listening status text
              if (vm.isListening)
                Text(
                  'جارٍ الاستماع...',
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (!vm.isSpeechAvailable)
                Text(
                  'الميكروفون غير متاح',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                  ),
                ),

              // Mic button with pulse animation
              GestureDetector(
                onTap: vm.isSpeechAvailable ? vm.toggleVoiceListening : null,
                child: vm.isListening
                    ? AnimatedBuilder(
                        animation: _pulseAnim,
                        builder: (_, __) => Transform.scale(
                          scale: _pulseAnim.value,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.red,
                              size: 26,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.mic_none,
                        color: vm.isSpeechAvailable
                            ? Colors.black54
                            : Colors.black26,
                        size: 26,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(HomeViewModel vm) {
    final categories = PhraseCategory.values;
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          _buildCategoryChip(
            label: 'الكل',
            emoji: '🌐',
            isSelected: vm.selectedCategory == null,
            onTap: () => vm.selectCategory(null),
          ),
          ...categories.map((cat) => _buildCategoryChip(
                label: cat.arabicLabel,
                emoji: cat.emoji,
                isSelected: vm.selectedCategory == cat,
                onTap: () => vm.selectCategory(cat),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2B6B99).withOpacity(0.85)
              : Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.4), width: 1.2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPanel(HomeViewModel vm, Size size) {
    return Stack(
      children: [
        // Sign language display container
        Container(
          width: double.infinity,
          height: size.height * 0.38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Sign GIF / fallback avatar
              Positioned.fill(
                child: Image.asset(
                  vm.currentPhrase?.signAssetPath ?? Constants.SignUpAvatar,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          Constants.SignUpAvatar,
                          height: size.height * 0.22,
                          fit: BoxFit.contain,
                        ),
                        if (vm.currentPhrase != null) ...[
                          const SizedBox(height: 12),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              vm.currentPhrase!.arabicText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Translating overlay
              if (vm.state == TranslationState.translating)
                Container(
                  color: Colors.black.withOpacity(0.45),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                ),

              // Phrase Arabic text overlay at bottom when result exists
              if (vm.currentPhrase != null &&
                  vm.state != TranslationState.translating)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      vm.currentPhrase!.arabicText,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Confidence badge (top-right)
        if (vm.matchConfidencePercent != null)
          Positioned(
            top: 12,
            right: 12,
            child: _buildConfidenceBadge(vm.matchConfidencePercent!),
          ),

        // Category badge (top-left)
        if (vm.currentPhrase != null)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${vm.currentPhrase!.category.emoji} ${vm.currentPhrase!.category.arabicLabel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConfidenceBadge(int percent) {
    final Color badgeColor = percent >= 80
        ? const Color(0xFF2ECC71)
        : percent >= 50
            ? const Color(0xFFF39C12)
            : const Color(0xFFE74C3C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$percent٪ تطابق',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSuggestions(HomeViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            '💡 اقتراحات مشابهة',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Colors.black.withOpacity(0.65),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: vm.suggestions
              .map((result) => GestureDetector(
                    onTap: () => vm.applySuggestion(result),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            result.phrase.arabicText,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${result.confidencePercent}٪',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FLOW 2: Sign Language → Text / Voice
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSignToTextFlow(HomeViewModel vm, Size size) {
    return Column(
      key: const ValueKey('flow_sign_to_text'),
      children: [
        // 1. Camera input panel ────────────────────────────────────────────
        Container(
          width: double.infinity,
          height: size.height * 0.40,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Camera placeholder
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white.withOpacity(0.3),
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'وجّه الكاميرا نحو لغة الإشارة',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Translating overlay
              if (vm.state == TranslationState.translating)
                Container(
                  color: Colors.black.withOpacity(0.55),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'جارٍ تحليل لغة الإشارة...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Record button
              Positioned(
                bottom: 22,
                child: GestureDetector(
                  onTap: vm.toggleCameraRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: vm.isCameraRecording
                          ? Colors.red
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: (vm.isCameraRecording
                                  ? Colors.red
                                  : Colors.white)
                              .withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      vm.isCameraRecording ? Icons.stop : Icons.videocam,
                      color: vm.isCameraRecording
                          ? Colors.white
                          : Colors.black87,
                      size: 30,
                    ),
                  ),
                ),
              ),

              // Recording indicator
              if (vm.isCameraRecording)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            color: Colors.white, size: 10),
                        SizedBox(width: 4),
                        Text(
                          'تسجيل',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Text & Audio output panel ──────────────────────────────────────
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 140),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.28),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Output text (RTL Arabic)
              Directionality(
                textDirection: TextDirection.rtl,
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    vm.state == TranslationState.translating
                        ? 'جارٍ التحليل...'
                        : (vm.currentPhrase?.arabicText ??
                            'ستظهر الترجمة هنا...'),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: vm.currentPhrase != null
                          ? Colors.black
                          : Colors.black45,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                ),
              ),

              // English subtitle (secondary)
              if (vm.currentPhrase != null) ...[
                const SizedBox(height: 6),
                Text(
                  vm.currentPhrase!.englishText,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Action row: confidence + TTS button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (vm.matchConfidencePercent != null)
                    _buildConfidenceBadge(vm.matchConfidencePercent!),
                  const Spacer(),
                  // Speak button
                  GestureDetector(
                    onTap: vm.currentPhrase != null
                        ? vm.speakTranslation
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: vm.currentPhrase != null
                            ? const Color(0xFF2B6B99).withOpacity(0.85)
                            : Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: vm.currentPhrase != null
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2B6B99)
                                      .withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            vm.isTtsSpeaking
                                ? Icons.stop_rounded
                                : Icons.volume_up_rounded,
                            color: vm.currentPhrase != null
                                ? Colors.white
                                : Colors.black26,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            vm.isTtsSpeaking ? 'إيقاف' : 'تشغيل صوت',
                            style: TextStyle(
                              color: vm.currentPhrase != null
                                  ? Colors.white
                                  : Colors.black26,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED: Mode switcher & Action bar
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildModeSwitcher(HomeViewModel vm) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModePill(
          label: vm.inputType == TranslationInputType.textAndVoice
              ? 'نص وصوت'
              : 'لغة الإشارة',
          icon: vm.inputType == TranslationInputType.textAndVoice
              ? Icons.record_voice_over_outlined
              : Icons.back_hand_outlined,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: vm.swapTranslationModes,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                color: Colors.black87,
                size: 26,
              ),
            ),
          ),
        ),
        _buildModePill(
          label: vm.outputType == TranslationInputType.signLanguage
              ? 'لغة الإشارة'
              : 'نص وصوت',
          icon: vm.outputType == TranslationInputType.signLanguage
              ? Icons.back_hand_outlined
              : Icons.record_voice_over_outlined,
        ),
      ],
    );
  }

  Widget _buildModePill({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(HomeViewModel vm) {
    return Row(
      children: [
        _buildActionButton(
          label: 'مسح',
          icon: Icons.refresh_outlined,
          onPressed: vm.clearInputs,
        ),
        _buildActionButton(
          label: 'ترجمة',
          icon: Icons.g_translate_outlined,
          onPressed: vm.executeTranslation,
          isHighlighted: true,
        ),
        _buildActionButton(
          label: 'مشاركة',
          icon: Icons.share_outlined,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isHighlighted = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 54,
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFF2B6B99).withOpacity(0.8)
              : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFF2B6B99).withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: const Color(0xFF2B6B99).withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isHighlighted ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                icon,
                color: isHighlighted ? Colors.white : Colors.black54,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
