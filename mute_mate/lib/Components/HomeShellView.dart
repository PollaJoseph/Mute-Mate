import 'package:flutter/material.dart';
import 'package:mute_mate/Components/NavigationItemData.dart';
import 'package:mute_mate/Model/NavigationItemData.dart';
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
          Positioned.fill(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),

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
                NavigationItemData(
                  activeIconPath: 'assets/icons/home_active.png',
                  inactiveIconPath: 'assets/icons/home_inactive.png',
                  label: "Home",
                ),
                NavigationItemData(
                  activeIconPath: 'assets/icons/sos_active.png',
                  inactiveIconPath: 'assets/icons/sos_inactive.png',
                  label: "Emergency",
                ),
                NavigationItemData(
                  activeIconPath: 'assets/icons/chats_active.png',
                  inactiveIconPath: 'assets/icons/chats_inactive.png',
                  label: "Chats",
                ),
                NavigationItemData(
                  activeIconPath: 'assets/icons/store_active.png',
                  inactiveIconPath: 'assets/icons/store_inactive.png',
                  label: "Store",
                ),
                NavigationItemData(
                  activeIconPath: 'assets/icons/profile_active.png',
                  inactiveIconPath: 'assets/icons/profile_inactive.png',
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
