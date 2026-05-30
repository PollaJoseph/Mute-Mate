import 'package:flutter/material.dart';
import 'package:mute_mate/Constants.dart';

class StoreView extends StatelessWidget {
  const StoreView({super.key});

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
        ],
      ),
    );
  }
}
