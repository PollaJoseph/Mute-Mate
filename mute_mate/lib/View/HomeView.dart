import 'package:flutter/material.dart';
import 'package:mute_mate/Model/TranslationSession.dart';
import 'package:provider/provider.dart';
import 'package:mute_mate/Constants.dart';
import 'package:mute_mate/ViewModel/HomeViewModel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
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
            // Ambient Environmental Theme Background
            Positioned.fill(
              child: Image.asset(
                Constants.LightBackgroundPath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),

            // Base Background Stethoscope Accent
            Positioned(
              bottom: -20,
              right: -10,
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  Constants.StethoscopePath,
                  width: size.width * 0.6,
                ),
              ),
            ),

            // Main Core Scroll Dashboard Layout
            SafeArea(
              child: Consumer<HomeViewModel>(
                builder: (context, vm, child) {
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
                        const Text(
                          "Sign Translate",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Voice & Text Translator for Deaf & Hard\nof Hearing",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- INTERACTIVE SWAP MODE ROW SEGMENT ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDirectionPill(
                              label:
                                  vm.inputType ==
                                      TranslationInputType.textAndVoice
                                  ? "Text & Voice"
                                  : "Sign Language",
                              icon:
                                  vm.inputType ==
                                      TranslationInputType.textAndVoice
                                  ? Icons.face_retouching_natural
                                  : Icons.back_hand_outlined,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.swap_horiz,
                                  color: Colors.black87,
                                  size: 28,
                                ),
                                onPressed: vm.swapTranslationModes,
                              ),
                            ),
                            _buildDirectionPill(
                              label:
                                  vm.outputType ==
                                      TranslationInputType.signLanguage
                                  ? "Sign Language"
                                  : "Text & Voice",
                              icon:
                                  vm.outputType ==
                                      TranslationInputType.signLanguage
                                  ? Icons.back_hand_outlined
                                  : Icons.face_retouching_natural,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // --- DYNAMIC CONTENT LAYOUT ---
                        if (vm.inputType ==
                            TranslationInputType.textAndVoice) ...[
                          // FLOW 1: Text -> Sign

                          // PART 1: Text Input Panel
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              children: [
                                TextFormField(
                                  controller: vm.inputController,
                                  maxLines: null,

                                  // 1. Link the onChange event to your Debouncer
                                  onChanged: vm.onInputTextChanged,

                                  // 2. Also trigger translation if they press "Done" on the keyboard
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) =>
                                      vm.executeTranslation(),

                                  decoration: InputDecoration(
                                    hintText: vm.isVoiceSelected
                                        ? "Listening..."
                                        : "Type or speak in English...",
                                    hintStyle: TextStyle(
                                      color: Colors.black.withOpacity(0.5),
                                      fontSize: 18,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  child: InkWell(
                                    onTap: () => vm.toggleInputDevice(false),
                                    child: Icon(
                                      Icons.keyboard_alt_outlined,
                                      color: !vm.isVoiceSelected
                                          ? const Color(0xFF2B6B99)
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () => vm.toggleInputDevice(true),
                                    child: Icon(
                                      vm.isVoiceSelected
                                          ? Icons.mic
                                          : Icons.mic_none,
                                      color: vm.isVoiceSelected
                                          ? Colors.red
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // PART 2: Avatar Output Panel
                          Container(
                            width: double.infinity,
                            height: size.height * 0.38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    vm.currentTranslation?.signAssetPath ??
                                        Constants.SignUpAvatar,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (vm.state == TranslationState.translating)
                                  Container(
                                    color: Colors.black.withOpacity(0.5),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // FLOW 2: Sign -> Text

                          // PART 1: Camera Input Panel
                          Container(
                            width: double.infinity,
                            height: size.height * 0.38,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Placeholder for CameraPreview Widget
                                const Center(
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white38,
                                    size: 64,
                                  ),
                                ),
                                Positioned(
                                  bottom: 20,
                                  child: GestureDetector(
                                    onTap: vm.toggleCameraRecording,
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 26,
                                        backgroundColor: vm.isCameraRecording
                                            ? Colors.red
                                            : Colors.transparent,
                                        child: vm.isCameraRecording
                                            ? const Icon(
                                                Icons.stop,
                                                color: Colors.white,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // PART 2: Text & Audio Output Panel
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    vm.state == TranslationState.translating
                                        ? "Analyzing sign language..."
                                        : (vm.currentTranslation?.text ??
                                              "Translation will appear here..."),
                                    style: TextStyle(
                                      color: vm.currentTranslation != null
                                          ? Colors.black
                                          : Colors.black54,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: vm.currentTranslation != null
                                          ? vm.playTranslatedAudio
                                          : null,
                                      icon: Icon(
                                        Icons.volume_up,
                                        color: vm.currentTranslation != null
                                            ? const Color(0xFF2B6B99)
                                            : Colors.black26,
                                        size: 28,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        SizedBox(height: 30),
                        // --- FOOTER FUNCTION ACTION ACTION LAYER BUTTONS ROW ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionBarButton(
                              label: "Clear",
                              icon: Icons.refresh_outlined,
                              onPressed: vm.clearInputs,
                            ),
                            _buildActionBarButton(
                              label: "Translate",
                              icon: Icons.g_translate_outlined,
                              onPressed: vm.executeTranslation,
                              hasBackground: true,
                            ),
                            _buildActionBarButton(
                              label: "Share",
                              icon: Icons.share_outlined,
                              onPressed: () {},
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 100,
                        ), // Pushes layout up from the bottom custom Navigation Bar safely
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

  Widget _buildDirectionPill({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildActionBarButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool hasBackground = false,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        height: 54,
        decoration: BoxDecoration(
          color: hasBackground
              ? Colors.white.withOpacity(0.35)
              : Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: hasBackground
              ? Border.all(color: Colors.white.withOpacity(0.4), width: 1.5)
              : null,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, color: Colors.black87, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
