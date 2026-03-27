import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/language_controller.dart';
import '../../../utils/constants/app_strings.dart';
import '../../../utils/helpers/extensions.dart';
import '../../widgets/app_button.dart';
import '../../widgets/get_it_hook.dart';
import '../../widgets/system_ui_overlay.dart';

class LanguageSelectionPage extends GetItHook<LanguageController> {
  const LanguageSelectionPage({super.key});

  @override
  bool get autoDispose => true;

  @override
  Widget build(BuildContext context) {
    return OnboardingSystemUiOverlayStyle(child: _LanguageBody(controller: controller));
  }
}

class _LanguageBody extends StatefulWidget {
  const _LanguageBody({required this.controller});
  final LanguageController controller;

  @override
  State<_LanguageBody> createState() => _LanguageBodyState();
}

class _LanguageBodyState extends State<_LanguageBody> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  static const _languages = [
    _Language('en', 'English', 'English', '🇬🇧'),
    _Language('hi', 'हिन्दी', 'Hindi', '🇮🇳'),
    _Language('gu', 'ગુજરાતી', 'Gujarati', '🇮🇳'),
    _Language('mr', 'मराठी', 'Marathi', '🇮🇳'),
    _Language('ar', 'العربية', 'Arabic', '🇸🇦'),
    _Language('fr', 'Français', 'French', '🇫🇷'),
    _Language('es', 'Español', 'Spanish', '🇪🇸'),
    _Language('de', 'Deutsch', 'German', '🇩🇪'),
    _Language('zh', '中文', 'Chinese', '🇨🇳'),
    _Language('ja', '日本語', 'Japanese', '🇯🇵'),
  ];

  LanguageController get ctrl => widget.controller;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_animController);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return Scaffold(
      backgroundColor: colors.bg0,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // Header icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: colors.primary.changeOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.language_rounded, color: colors.primary, size: 26),
                  ),
                  const SizedBox(height: 20),
                  Text(AppStrings.chooseLanguage, style: styles.s30w700White),
                  const SizedBox(height: 8),
                  Text(AppStrings.chooseLanguageSub, style: styles.s14w400Muted),
                  const SizedBox(height: 32),
                  // Language list
                  Expanded(
                    child: Obx(
                      () {
                        final currentSelectedCode = ctrl.selectedCode.value;
                        return ListView.separated(
                          itemCount: _languages.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final lang = _languages[i];
                            final isSelected = lang.code == currentSelectedCode;
                            return _LanguageTile(language: lang, isSelected: isSelected, onTap: () => ctrl.selectLanguage(lang.code));
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 32),
                    child: AppButton(title: AppStrings.continueBtn, onPressed: ctrl.onContinue),
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

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.language, required this.isSelected, required this.onTap});

  final _Language language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.styles;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isSelected ? colors.primary.changeOpacity(0.14) : colors.bg1,
        border: Border.all(color: isSelected ? colors.primary : colors.textPrimary.changeOpacity(0.06), width: isSelected ? 1.5 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(language.flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(language.nativeName, style: styles.s15w600White.copyWith(color: isSelected ? colors.textPrimary : colors.textPrimary.changeOpacity(0.85))),
                    Text(language.englishName, style: styles.s12w400Muted),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: colors.primaryGradientDiagonal),
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Language {
  const _Language(this.code, this.nativeName, this.englishName, this.flag);
  final String code;
  final String nativeName;
  final String englishName;
  final String flag;
}
