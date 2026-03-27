import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

@lazySingleton
class AuthController extends GetxController {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  final loginIsLoading = false.obs;
  final loginError = Rxn<String>();
  final loginObscure = true.obs;

  final signUpIsLoading = false.obs;
  final signUpError = Rxn<String>();
  final signUpObscure = true.obs;

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    super.onClose();
  }

  void toggleLoginObscure() => loginObscure.toggle();
  void toggleSignUpObscure() => signUpObscure.toggle();

  Future<void> login() async {
    loginIsLoading.value = true;
    loginError.value = null;

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
      );

      if (response.session != null) {
        // Always go to shell — shell decides whether to show module selection
        // or the dashboard based on whether modules have been saved locally.
        Get.offAllNamed(AppRoutes.home);
      }
    } on AuthException catch (e) {
      loginError.value = e.message;
    } catch (_) {
      loginError.value = 'Something went wrong. Please try again.';
    } finally {
      loginIsLoading.value = false;
    }
  }

  Future<void> signUp() async {
    signUpIsLoading.value = true;
    signUpError.value = null;

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text,
        data: {'full_name': nameCtrl.text.trim()},
      );

      if (response.user != null) {
        // New user — go pick modules first
        Get.offAllNamed(AppRoutes.moduleSelection);
      } else {
        signUpError.value = 'Sign up failed. Please try again.';
      }
    } on AuthException catch (e) {
      signUpError.value = e.message;
    } catch (_) {
      signUpError.value = 'Something went wrong. Please try again.';
    } finally {
      signUpIsLoading.value = false;
    }
  }

  void forgotPassword() {
    // TODO: implement forgot password flow
  }
}
