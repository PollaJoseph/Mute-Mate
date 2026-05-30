import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mute_mate/Constants.dart';
import 'package:mute_mate/Components/CustomButton.dart';
import 'package:mute_mate/Components/HomeShellView.dart';
import 'package:mute_mate/ViewModel/LoginViewModel.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider<LoginViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFF8CB6D9),
        body: SafeArea(
          child: Consumer<LoginViewModel>(
            builder: (context, vm, child) {
              return Stack(
                children: [
                  // Background
                  Positioned.fill(
                    child: Image.asset(
                      Constants.LightBackgroundPath,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  // Main Scroll Window Flow
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: IconButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HomeShellView(),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 28,
                                ),
                              ),
                            ),
                            SizedBox(
                              child: Image.asset(
                                Constants.LoginAvatar,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.22),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(40),
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(.15),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -20,
                                bottom: -20,
                                child: Opacity(
                                  opacity: .85,
                                  child: Image.asset(
                                    Constants.StethoscopePath,
                                    width: size.width * .45,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 28,
                                ),
                                child: Form(
                                  key: vm.formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// Screen Narrative Texts
                                      const Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              "Welcome Back!",
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Documenting is Organizing!!",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 26),

                                      /// E-mail Input Field
                                      _buildInputField(
                                        label: "E-mail",
                                        hintText: "E-mail",
                                        prefixIcon: Icons.person_outline,
                                        onSaved: (val) =>
                                            vm.setEmail(val ?? ''),
                                      ),

                                      const SizedBox(height: 14),

                                      /// Password Input Field with Interactive Visibility Toggle Switch Eye Accent
                                      _buildInputField(
                                        label: "Password",
                                        hintText: "••••••••",
                                        obscureText: vm.isPasswordObscured,
                                        prefixIcon: Icons.key_outlined,
                                        onSaved: (val) =>
                                            vm.setPassword(val ?? ''),
                                        suffixIcon: IconButton(
                                          onPressed:
                                              vm.togglePasswordVisibility,
                                          icon: Icon(
                                            vm.isPasswordObscured
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 18,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      /// Forgot Password Link Block Text Elements Row
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            // TODO: Implement password reset flow sequence request
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Forgot Password?",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black
                                                      .withOpacity(.6),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.info_outline,
                                                size: 14,
                                                color: Colors.black.withOpacity(
                                                  .5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      /// Form Action Execution Button Module
                                      vm.state == LoginState.loading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF8ED26A),
                                                    Color(0xFF1E7ED8),
                                                  ],
                                                ),
                                              ),
                                              child: CustomButton(
                                                text: "Sign in",
                                                onPressed: () =>
                                                    vm.submitLogin(context),
                                              ),
                                            ),

                                      const SizedBox(height: 22),

                                      /// Secondary Alternative Connection Channels Separator Segment
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.black.withOpacity(
                                                .2,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              "Or continue with",
                                              style: TextStyle(
                                                color: Colors.black.withOpacity(
                                                  .6,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.black.withOpacity(
                                                .2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 22),

                                      /// Integrated Social Ecosystem Gateway Node Access Buttons Array
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _buildSocialIconButton(
                                            Constants.GoogleIcon,
                                          ),
                                          const SizedBox(width: 18),
                                          _buildSocialIconButton(
                                            Constants.AppleIcon,
                                          ),
                                          const SizedBox(width: 18),
                                          _buildSocialIconButton(
                                            Constants.FacebookIcon,
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 45),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    String? hintText,
    bool obscureText = false,
    IconData? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    FormFieldSetter<String>? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            Icon(
              Icons.info_outline,
              size: 16,
              color: Colors.black.withOpacity(.35),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onSaved: onSaved,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(.35),
              fontSize: 13,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: Colors.black54)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white.withOpacity(.16),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black.withOpacity(.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black26, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIconButton(String iconAssetPath) {
    return Container(
      width: 58,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(.15)),
      ),
      child: Center(
        child: Image.asset(
          iconAssetPath,
          width: 24,
          height: 24,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_not_supported_outlined);
          },
        ),
      ),
    );
  }
}
