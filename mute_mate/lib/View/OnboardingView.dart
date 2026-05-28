import 'package:flutter/material.dart';
import 'package:mute_mate/Components/CustomButton.dart';
import 'package:mute_mate/Components/OnboardingDotIndicator.dart';
import 'package:mute_mate/Constants.dart';
import 'package:mute_mate/ViewModel/OnboardingViewModel.dart';
import 'package:provider/provider.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final OnboardingViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = OnboardingViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OnboardingViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        body: Consumer<OnboardingViewModel>(
          builder: (context, vm, child) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    Constants.LightBackgroundPath,
                    fit: BoxFit.cover,
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
                  bottom: false,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: vm.pageController,
                          onPageChanged: vm.updatePageIndex,
                          itemCount: vm.onboardingPages.length,
                          itemBuilder: (context, index) {
                            final pageItem = vm.onboardingPages[index];
                            return Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.42,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(200),
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    pageItem.illustrationPath,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 40),

                                // Title text
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0,
                                  ),
                                  child: Text(
                                    pageItem.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Description body text
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0,
                                  ),
                                  child: Text(
                                    pageItem.description,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black.withOpacity(0.7),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      OnboardingDotIndicator(
                        itemCount: vm.onboardingPages.length,
                        currentIndex: vm.currentPage,
                      ),
                      const SizedBox(height: 40),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: CustomButton(
                          text: vm.isLastPage ? "Get Started" : "Next",
                          onPressed: () => vm.handleNextStep(context),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
