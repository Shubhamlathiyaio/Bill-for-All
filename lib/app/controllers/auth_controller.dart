import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

@lazySingleton
class AuthController extends GetxController {
  // TextEditingControllers — disposed in onClose()
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  // Login tab
  final loginIsLoading = false.obs;
  final loginError = Rxn<String>();
  final loginObscure = true.obs;

  // Sign up tab
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
        final userId = response.session!.user.id;
        final data = await Supabase.instance.client
            .from('user_workspaces')
            .select('supabase_url')
            .eq('user_id', userId)
            .maybeSingle();

        final supabaseUrl = data?['supabase_url'];
        if (supabaseUrl != null && (supabaseUrl as String).isNotEmpty) {
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.offAllNamed(AppRoutes.waiting);
        }
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
