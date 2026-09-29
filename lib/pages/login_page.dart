import 'package:flutter/material.dart';
import 'package:frontend/theme/app_colors.dart';
import 'package:frontend/theme/app_text_styles.dart';
import 'package:frontend/theme/app_radius.dart';
import 'package:frontend/pages/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN ACTION
  // ============================================================

  void _signIn() {
    // Backend authentication will be connected later.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Welcome back to the atelier.')),
    );
  }

  void _createAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  void _forgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password recovery will be connected later.'),
      ),
    );
  }

  // ============================================================
  // LOGIN FIELD
  // ============================================================

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool password = false,
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
                  obscureText: password && _obscurePassword,
                  keyboardType: label == 'EMAIL ADDRESS'
                      ? TextInputType.emailAddress
                      : TextInputType.text,
                  style: AppTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: hint,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFFC4C6CD),
                    ),
                  ),
                ),
              ),

              if (password)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                )
              else if (label == 'EMAIL ADDRESS')
                const Icon(
                  Icons.mail_outline,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // ==================================================
                  // BRANDING
                  // ==================================================
                  Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 41, 55, 72),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'assets/images/wearly_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Wearly', style: AppTextStyles.headlineLarge),

                      const SizedBox(height: 4),

                      Text(
                        'AI PERSONAL WARDROBE',
                        style: AppTextStyles.labelSmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 42),

                  // ==================================================
                  // LOGIN FORM
                  // ==================================================
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 384),

                    child: Column(
                      children: [
                        _buildField(
                          label: 'EMAIL ADDRESS',
                          hint: 'hello@wearly.com',
                          controller: emailController,
                        ),

                        const SizedBox(height: 16),

                        _buildField(
                          label: 'PASSWORD',
                          hint: '••••••••••••',
                          controller: passwordController,
                          password: true,
                        ),

                        const SizedBox(height: 12),

                        // ==================================================
                        // FORGOT
                        // ==================================================
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _forgotPassword,
                            child: Text(
                              'Forgot?',
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ),

                        const SizedBox(height: 42),

                        // ==================================================
                        // SIGN IN BUTTON
                        // ==================================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _signIn,
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
                                  'SIGN IN',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),

                                const SizedBox(width: 8),

                                const Icon(Icons.arrow_forward, size: 16),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ==================================================
                        // CREATE ACCOUNT
                        // ==================================================
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _createAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainerHigh,
                              foregroundColor: AppColors.onSurface,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.medium,
                                ),
                              ),
                            ),
                            child: Text(
                              'CREATE WEARLY ACCOUNT',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.onSurface,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
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
