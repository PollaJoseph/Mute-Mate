import 'package:flutter/material.dart';

class OnboardingDotIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color activeColor;

  const OnboardingDotIndicator({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    this.activeColor = const Color(0xFF99D874),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 10,
          width: currentIndex == index ? 28 : 10,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? activeColor
                : activeColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
