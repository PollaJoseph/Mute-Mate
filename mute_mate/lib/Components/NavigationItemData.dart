import 'package:flutter/material.dart';

class NavigationItemData {
  final Widget icon;
  final String label;

  const NavigationItemData({required this.icon, required this.label});
}

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationItemData> items;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        // The distinct linear green-to-blue gradient background from image_28c743.png
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7CB661), // Vibrant Green top-left
            Color(0xFF2B6B99), // Deep Blue bottom-right
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final item = items[index];

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 18 : 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                // Selected item turns into the bright solid white capsule
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon Layer (Thematic tint adjustment based on active selection)
                  Theme(
                    data: ThemeData(
                      iconTheme: IconThemeData(
                        color: isSelected
                            ? const Color(0xFF2B6B99)
                            : Colors.white.withOpacity(0.65),
                        size: 24,
                      ),
                    ),
                    child: item.icon,
                  ),

                  // Text Label expands / collapses conditionally with a smooth clip animation
                  AnimatedCrossFade(
                    firstChild: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: Color(
                              0xFF2B6B99,
                            ), // Matching text color label from mockup
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: isSelected
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
