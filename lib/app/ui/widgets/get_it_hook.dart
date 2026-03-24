import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/helpers/injectable/injectable.dart';

/// Base class for every page widget.
/// Extends StatefulWidget — hooks into lifecycle to optionally
/// reset the lazySingleton on page pop (autoDispose: true).
abstract class GetItHook<T extends GetxController> extends StatefulWidget {
  const GetItHook({super.key});

  /// Set to true for screen-scoped controllers (reset on pop).
  /// Set to false for root/persistent controllers (tabs, bottom nav).
  bool get autoDispose;

  Widget build(BuildContext context);

  T get controller => getIt<T>();

  @override
  State<GetItHook<T>> createState() => _GetItHookState<T>();
}

class _GetItHookState<T extends GetxController> extends State<GetItHook<T>> {
  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  void dispose() {
    super.dispose();
    if (widget.autoDispose && getIt.isRegistered<T>()) {
      getIt.resetLazySingleton<T>();
    }
  }
}
