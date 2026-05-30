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
  static const String LoginAvatar = "lib/Assets/Images/LoginAvatar.png";

  // Icons
  static const String GoogleIcon = "lib/Assets/Icons/google.png";
  static const String FacebookIcon = "lib/Assets/Icons/facebook.png";
  static const String AppleIcon = "lib/Assets/Icons/apple.png";

  static const String SelectedHomeIcon =
      "lib/Assets/Icons/SelectedHomeIcon.png";
  static const String SelectedSOSIcon = "lib/Assets/Icons/SelectedSOSIcon.png";
  static const String SelectedChatIcon =
      "lib/Assets/Icons/SelectedChatIcon.png";
  static const String SelectedStoreIcon =
      "lib/Assets/Icons/SelectedStoreIcon.png";
  static const String SelectedProfileIcon =
      "lib/Assets/Icons/SelectedProfileIcon.png";

  static const String UnselectedHomeIcon =
      "lib/Assets/Icons/UnselectedHomeIcon.png";
  static const String UnselectedSOSIcon =
      "lib/Assets/Icons/UnselectedSOSIcon.png";
  static const String UnselectedChatIcon =
      "lib/Assets/Icons/UnslectedChatIcon.png";
  static const String UnselectedStoreIcon =
      "lib/Assets/Icons/UnselectedStoreIcon.png";
  static const String UnselectedProfileIcon =
      "lib/Assets/Icons/UnselectedProfileIcon.png";

  // Dimensions
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
