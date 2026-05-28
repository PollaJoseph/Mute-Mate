import 'package:flutter/material.dart';
import 'package:mute_mate/View/OnboardingView.dart';
import 'package:mute_mate/ViewModel/SplashViewModel.dart';
import 'package:mute_mate/Constants.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late final SplashViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SplashViewModel();
    _viewModel.initializeApp();
    _viewModel.addListener(_handleNavigation);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_handleNavigation);
    _viewModel.dispose();
    super.dispose();
  }

  void _handleNavigation() {
    if (_viewModel.state == SplashNavigationState.navigateToNextScreen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Constants.LightBackgroundPath,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
          Center(child: Image.asset(Constants.LogoPath)),
          Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),
    );
  }
}
