import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../utils/helpers/injectable/injectable.dart';

abstract class GetItHook<T extends GetxController> extends StatefulWidget {
  const GetItHook({super.key, T? controller}) : _controller = controller;

  @override
  State<GetItHook> createState() => _GetItHookState<T>();

  void _onInit() {
    controller.onInit();
    onInit();
  }

  void onInit() {}

  bool get autoDispose;

  Widget build(BuildContext context);

  T get controller => _controller ?? getIt<T>();

  final T? _controller;

  void onDispose() {}

  void _unRegister() {
    if (autoDispose && getIt.isRegistered<T>()) {
      getIt.resetLazySingleton<T>();
    }
  }
}

class _GetItHookState<T extends GetxController> extends State<GetItHook> {
  @override
  Widget build(BuildContext context) => widget.build(context);

  @override
  void initState() {
    super.initState();
    widget._onInit();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
    widget._unRegister();
  }
}

abstract class GetItHookState<T extends GetxController, S extends StatefulWidget>
    extends State<S> {
  T get controller => getIt<T>();

  @override
  void initState() {
    super.initState();
    controller.onInit();
    onInit();
  }

  void onInit() {}

  void _unRegister() {
    if (autoDispose && getIt.isRegistered<T>()) {
      getIt.resetLazySingleton<T>();
    }
  }

  @override
  void dispose() {
    _unRegister();
    super.dispose();
  }

  bool get autoDispose;
}
