import 'package:flutter/material.dart';
import 'package:mute_mate/Components/NavigationItemData.dart';
import 'package:mute_mate/View/ChatsView.dart';
import 'package:mute_mate/View/EmergencyView.dart';
import 'package:mute_mate/View/HomeView.dart';
import 'package:mute_mate/View/ProfileView.dart';
import 'package:mute_mate/View/StoreView.dart';

class HomeShellView extends StatefulWidget {
  const HomeShellView({super.key});

  @override
  State<HomeShellView> createState() => _HomeShellViewState();
}

class _HomeShellViewState extends State<HomeShellView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(),
    const EmergencyView(),
    const ChatsView(),
    const StoreView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      body: Stack(
        children: [
          // 1. Core Page Layer Content
          Positioned.fill(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),

          // 2. Custom Navigation Bar component floating on top at the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: CustomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                const NavigationItemData(
                  icon: Icon(Icons.home_outlined),
                  label: "Home",
                ),
                NavigationItemData(
                  icon: Text(
                    "SOS",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: _currentIndex == 1
                          ? const Color(0xFF2B6B99)
                          : Colors.white.withOpacity(0.65),
                    ),
                  ),
                  label: "Emergency",
                ),
                const NavigationItemData(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: "Chats",
                ),
                const NavigationItemData(
                  icon: Icon(Icons.storefront_outlined),
                  label: "Store",
                ),
                const NavigationItemData(
                  icon: Icon(Icons.account_circle_outlined),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
