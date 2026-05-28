import 'package:flutter/material.dart';
import 'package:mute_mate/Components/CustomButton.dart';
import 'package:mute_mate/Components/HomeShellView.dart';
import 'package:mute_mate/ViewModel/SignupViewModel.dart';
import 'package:provider/provider.dart';
import 'package:mute_mate/Constants.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  late final SignupViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignupViewModel();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider<SignupViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        backgroundColor: const Color(0xFF8CB6D9),
        body: SafeArea(
          child: Consumer<SignupViewModel>(
            builder: (context, vm, child) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      Constants.LightBackgroundPath,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),

                  /// Content
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        /// Top Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeShellView(),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Avatar
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 170),
                          child: SizedBox(
                            height: size.height * .22,
                            child: Image.asset(
                              Constants.SignUpAvatar,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),

                        /// Main Card
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
                              /// Stethoscope
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

                              /// Form
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
                                      /// Title
                                      const Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              "Get Started Free",
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              "Writing is clarifying!!",
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

                                      /// First + Last Name
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              label: "First Name",
                                              onSaved: (val) =>
                                                  vm.setFirstName(val ?? ''),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInputField(
                                              label: "Last Name",
                                              onSaved: (val) =>
                                                  vm.setLastName(val ?? ''),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      /// Email
                                      _buildInputField(
                                        label: "E-mail",
                                        onSaved: (val) =>
                                            vm.setEmail(val ?? ''),
                                      ),

                                      const SizedBox(height: 14),

                                      /// Governorates
                                      const Text(
                                        "Governorates",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(.18),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.black12,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value:
                                                vm
                                                    .registrationData
                                                    .governorate
                                                    .isEmpty
                                                ? null
                                                : vm
                                                      .registrationData
                                                      .governorate,
                                            hint: const Text("Select"),
                                            isExpanded: true,
                                            dropdownColor: const Color(
                                              0xFF8CB6D9,
                                            ),
                                            items: vm.governorates.map((gov) {
                                              return DropdownMenuItem(
                                                value: gov,
                                                child: Text(gov),
                                              );
                                            }).toList(),
                                            onChanged: vm.setGovernorate,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 14),

                                      /// Email + Password
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildInputField(
                                              label: "Email",
                                              hintText: "User@Example.com",
                                              prefixIcon: Icons.person_outline,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildInputField(
                                              label: "Password",
                                              hintText: "••••••••",
                                              obscureText: true,
                                              prefixIcon: Icons.key_outlined,
                                              onChanged: vm.setPassword,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      /// Mobile
                                      _buildInputField(
                                        label: "Mobile No.",
                                        hintText: "+20 1208980211",
                                        keyboardType: TextInputType.phone,
                                        onSaved: (val) =>
                                            vm.setMobileNumber(val ?? ''),
                                      ),

                                      const SizedBox(height: 28),

                                      /// Button
                                      vm.state == SignupState.loading
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : Container(
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
                                                text: "Sign up",
                                                onPressed: () =>
                                                    vm.submitSignup(context),
                                              ),
                                            ),

                                      const SizedBox(height: 18),

                                      /// Divider text
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
                                              "Or sign up with",
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

                                      const SizedBox(height: 20),

                                      /// Social Buttons
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

                                      const SizedBox(height: 20),
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
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
    FormFieldSetter<String>? onSaved,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.black87,
          ),
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
