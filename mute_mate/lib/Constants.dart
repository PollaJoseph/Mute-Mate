import 'package:flutter/material.dart';

class Constants {
  // Images
  static const String LightBackgroundPath =
      "lib/Assets/Images/LightBackgroundImage.png";
  static const String DarkBackgroundPath =
      "lib/Assets/Images/DarkBackgroundImage.png";
  static const String LogoPath = "lib/Assets/Images/logo.png";
  static const String StethoscopePath =
      "lib/Assets/Images/StethoscopeImage.png";
  static const String FirstOnboardingImagePath =
      "lib/Assets/Images/FirstOnboardingImage.png";
  static const String SecondOnboardingImagePath =
      "lib/Assets/Images/SecondOnboardingImage.png";
  static const String ThirdOnboardingImagePath =
      "lib/Assets/Images/ThirdOnboardingImage.png";
  static const String SignUpAvatar = "lib/Assets/Images/SignUpAvatar.png";

  // Icons
  static const String GoogleIcon = "lib/Assets/Icons/google.png";
  static const String FacebookIcon = "lib/Assets/Icons/facebook.png";
  static const String AppleIcon = "lib/Assets/Icons/apple.png";

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
