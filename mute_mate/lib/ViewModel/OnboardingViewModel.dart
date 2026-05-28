import 'package:flutter/material.dart';
import 'package:mute_mate/Constants.dart';
import 'package:mute_mate/Model/OnboardingModel.dart';
import 'package:mute_mate/View/SignUpView.dart';

class OnboardingViewModel extends ChangeNotifier {
  final PageController pageController = PageController();

  int _currentPage = 0;
  int get currentPage => _currentPage;

  final List<OnboardingModel> onboardingPages = [
    const OnboardingModel(
      title: "Real-time Sign Translation",
      description:
          "Our advanced AI captures your sign language gestures seamlessly and translates them into instant medical insights.",
      illustrationPath: Constants.FirstOnboardingImagePath,
    ),
    const OnboardingModel(
      title: "Real-time Sign Translation",
      description:
          "Our advanced AI captures your sign language gestures seamlessly and translates them into instant medical insights.",
      illustrationPath: Constants.SecondOnboardingImagePath,
    ),
    const OnboardingModel(
      title: "Expressive 3D Avatars",
      description:
          "Healthcare instructions are converted back to fluid sign language animations, keeping you perfectly informed.",
      illustrationPath: Constants.ThirdOnboardingImagePath,
    ),
  ];

  bool get isLastPage => _currentPage == onboardingPages.length - 1;

  void updatePageIndex(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void handleNextStep(BuildContext context) {
    if (isLastPage) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUpView()),
      );
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
