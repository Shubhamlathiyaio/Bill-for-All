import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';
import '../../widgets/app_button.dart';
import '../../../utils/helpers/extensions.dart';
import '../../../utils/constants/app_strings.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends GetItHookState<AuthController, AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  bool get autoDispose => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return OnboardingSystemUiOverlayStyle(
      child: Scaffold(
        backgroundColor: colors.bg0,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Logo
                Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: colors.primaryGradientDiagonal,
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.changeOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.bolt_rounded,
                          color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 16),
                    Text(AppStrings.welcomeTo, style: styles.s24w700White),
                    const SizedBox(height: 6),
                    Text(AppStrings.signInOrCreate,
                        style: styles.s14w400Muted),
                  ],
                ),
                const SizedBox(height: 36),
                // Tab bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: colors.bg1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: colors.primaryGradient,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: colors.white,
                    unselectedLabelColor:
                        colors.textPrimary.changeOpacity(0.38),
                    labelStyle: styles.s14w700White,
                    tabs: const [
                      Tab(text: 'Log In'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 420,
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _LoginForm(ctrl: controller),
                      _SignUpForm(ctrl: controller),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Login Form ──────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({required this.ctrl});
  final AuthController ctrl;

  @override
  Widget build(BuildContext context) {
    final styles = context.styles;
    final colors = context.colors;

    return Column(
      children: [
        _AuthField(
          controller: ctrl.emailCtrl,
          label: AppStrings.email,
          hint: AppStrings.emailHint,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        Obx(() => _AuthField(
              controller: ctrl.passCtrl,
              label: AppStrings.password,
              hint: AppStrings.passwordHint,
              icon: Icons.lock_outline_rounded,
              obscureText: ctrl.loginObscure.value,
              suffixIcon: IconButton(
                icon: Icon(
                  ctrl.loginObscure.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: colors.textPrimary.changeOpacity(0.38),
                  size: 20,
                ),
                onPressed: ctrl.toggleLoginObscure,
              ),
            )),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: ctrl.forgotPassword,
            child: Text(
              AppStrings.forgotPassword,
              style: styles.s13w500Primary
                  .copyWith(color: colors.primary.changeOpacity(0.85)),
            ),
          ),
        ),
        Obx(() {
          final err = ctrl.loginError.value;
          if (err == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ErrorBanner(message: err),
          );
        }),
        const SizedBox(height: 20),
        Obx(() => AppButton(
              title: AppStrings.loginBtn,
              isLoading: ctrl.loginIsLoading.value,
              onPressed: ctrl.login,
            )),
      ],
    );
  }
}

// ─── Sign Up Form ─────────────────────────────────────────────────────────────

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({required this.ctrl});
  final AuthController ctrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        _AuthField(
          controller: ctrl.nameCtrl,
          label: AppStrings.fullName,
          hint: AppStrings.fullNameHint,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),
        _AuthField(
          controller: ctrl.emailCtrl,
          label: AppStrings.email,
          hint: AppStrings.emailHint,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        Obx(() => _AuthField(
              controller: ctrl.passCtrl,
              label: AppStrings.password,
              hint: AppStrings.passwordHint,
              icon: Icons.lock_outline_rounded,
              obscureText: ctrl.signUpObscure.value,
              suffixIcon: IconButton(
                icon: Icon(
                  ctrl.signUpObscure.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: colors.textPrimary.changeOpacity(0.38),
                  size: 20,
                ),
                onPressed: ctrl.toggleSignUpObscure,
              ),
            )),
        Obx(() {
          final err = ctrl.signUpError.value;
          if (err == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: _ErrorBanner(message: err),
          );
        }),
        const SizedBox(height: 24),
        Obx(() => AppButton(
              title: AppStrings.createAccount,
              isLoading: ctrl.signUpIsLoading.value,
              onPressed: ctrl.signUp,
            )),
      ],
    );
  }
}

// ─── Shared Field ─────────────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: styles.s15w400White,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: styles.s13w400Muted,
        hintStyle:
            styles.s14w400Muted.copyWith(color: colors.textPrimary.changeOpacity(0.22)),
        prefixIcon: Icon(icon, color: colors.textPrimary.changeOpacity(0.38), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.fieldColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colors.textPrimary.changeOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colors.textPrimary.changeOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: colors.error, width: 1.5),
        ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.error.changeOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.error.changeOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: styles.s13w400Error),
          ),
        ],
      ),
    );
  }
}
