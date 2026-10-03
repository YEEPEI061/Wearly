import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/pages/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _createAccount() {
    // Backend registration will be connected later.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account creation will be connected later.'),
      ),
    );
  }

  void _signIn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    bool password = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall),

          const SizedBox(height: 4),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ),

              if (password)
                GestureDetector(
                  onTap: onTogglePassword,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              else if (icon != null)
                Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );
  }
  // ============================================================
  // PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
              child: Column(
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 41, 55, 72),
                            borderRadius: BorderRadius.circular(
                              AppRadius.medium,
                            ),
                          ),
                          padding: const EdgeInsets.all(7),
                          child: Image.asset(
                            'assets/images/wearly_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text('Wearly', style: AppTextStyles.headlineLarge),

                        const SizedBox(height: 4),

                        Text(
                          'CREATE YOUR AI WARDROBE',
                          style: AppTextStyles.labelSmall.copyWith(
                            // color: AppColors.secondary,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // FORM CARD
                  // ==================================================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 384),
                      child: Column(
                        children: [
                          // Full Name
                          _buildField(
                            label: 'FULL NAME',
                            hint: 'Elena Vance',
                            controller: nameController,
                            icon: Icons.person_outline,
                          ),

                          const SizedBox(height: 20),

                          // Email
                          _buildField(
                            label: 'EMAIL ADDRESS',
                            hint: 'hello@wearly.com',
                            controller: emailController,
                            icon: Icons.mail_outline,
                          ),

                          const SizedBox(height: 20),

                          // Password
                          _buildField(
                            label: 'PASSWORD',
                            hint: '••••••••••••',
                            controller: passwordController,
                            password: true,
                            obscureText: _obscurePassword,
                            onTogglePassword: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // Confirm Password
                          _buildField(
                            label: 'CONFIRM PASSWORD',
                            hint: '••••••••••••',
                            controller: confirmPasswordController,
                            password: true,
                            obscureText: _obscureConfirmPassword,
                            onTogglePassword: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),

                          const SizedBox(height: 12),

                          // ==================================================
                          // TERMS
                          // ==================================================
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _agreeToTerms = !_agreeToTerms;
                                  });
                                },
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    color: _agreeToTerms
                                        ? AppColors.primary
                                        : AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: _agreeToTerms
                                      ? const Icon(
                                          Icons.check,
                                          size: 13,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.bodySmall.copyWith(
                                      height: 1.35,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'Terms of Service',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: ' and '),
                                      TextSpan(
                                        text: 'Privacy Policy',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      const TextSpan(text: '.'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 34),

                          // ==================================================
                          // CREATE ACCOUNT BUTTON
                          // ==================================================
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _createAccount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.medium,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'CREATE ACCOUNT',
                                    style: AppTextStyles.labelMedium.copyWith(
                                      color: Colors.white,
                                      letterSpacing: 1.8,
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // ==================================================
                          // SIGN IN
                          // ==================================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: AppTextStyles.bodySmall,
                              ),

                              const SizedBox(width: 6),

                              GestureDetector(
                                onTap: _signIn,
                                child: Text(
                                  'SIGN IN',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
