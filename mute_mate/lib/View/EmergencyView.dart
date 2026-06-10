import 'package:flutter/material.dart';
import 'package:mute_mate/ViewModel/SOSViewModel.dart';
import 'package:provider/provider.dart';
import 'package:mute_mate/Constants.dart';

class EmergencyView extends StatefulWidget {
  const EmergencyView({super.key});

  @override
  State<EmergencyView> createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView>
    with TickerProviderStateMixin {
  late final EmergencyViewModel _viewModel;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _viewModel = EmergencyViewModel();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Cycle duration
    )..repeat(); // Makes it pulse infinitely

    // 3. Define how the ripple expands from scale 1.0 to 1.35
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.35,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider<EmergencyViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
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
                opacity: 0.7,
                child: Image.asset(
                  Constants.StethoscopePath,
                  width: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Need help?",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      "Press the button below to send an SOS alert.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Consumer<EmergencyViewModel>(
                    builder: (context, vm, child) {
                      return GestureDetector(
                        onTap: vm.sendSosAlert,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    width: 240,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFFFF0000)
                                          .withOpacity(
                                            1.0 - _pulseController.value,
                                          ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: vm.state == SosState.sending
                                    ? const Color(0xFFD32F2F)
                                    : const Color(0xFFFF0000),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.25),
                                    blurRadius: 0,
                                    spreadRadius: 12,
                                  ),
                                  BoxShadow(
                                    color: const Color(
                                      0xFF8E9BB0,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 25,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: vm.state == SosState.sending
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 4,
                                      )
                                    : const Text(
                                        "SOS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 64,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          icon: Icons.chat_bubble_rounded,
                          text:
                              "Messages will be sent to your\nregistered contacts.",
                        ),
                        const SizedBox(height: 14),
                        _buildInfoCard(
                          icon: Icons.location_on,
                          text: "Your current location will be\nshared",
                        ),
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: _viewModel.callEmergencyServices,
                          child: _buildInfoCard(
                            icon: Icons.phone,
                            text: "Call Emergency Services",
                            isAction: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    bool isAction = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF6A8EAE).withOpacity(0.45),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6A8EAE), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
