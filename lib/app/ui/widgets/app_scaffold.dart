import 'package:flutter/material.dart';
import '../../utils/helpers/extensions.dart';

/// AppScaffold — outer shell for every page.
/// Never use Scaffold directly in pages.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.showBackBtn = true,
    this.onTapBackBtn,
    this.action,
    this.showDivider = true,
    this.showAppBar = true,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
    this.paddingTop = true,
    this.showBgLogo = false,
    this.systemUiOverlayStyle,
  });

  final WidgetBuilder body;
  final String? title;
  final Widget? titleWidget;
  final bool showBackBtn;
  final VoidCallback? onTapBackBtn;
  final Widget? action;
  final bool showDivider;
  final bool showAppBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;
  final bool paddingTop;
  final bool showBgLogo;
  final dynamic systemUiOverlayStyle; // ignored — each page uses overlay wrappers

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget scaffold = Scaffold(
      backgroundColor: colors.bg0,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: colors.bg0,
              elevation: 0,
              centerTitle: true,
              automaticallyImplyLeading: false,
              leading: showBackBtn
                  ? InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onTapBackBtn ?? () => Navigator.of(context).pop(),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: colors.textPrimary, size: 20),
                    )
                  : null,
              title: titleWidget ??
                  (title != null
                      ? Text(
                          title!,
                          style: context.styles.s18w700White,
                        )
                      : null),
              actions: [
                if (action != null)
                  SizedBox(width: 45, height: 45, child: action!),
                const SizedBox(width: 8),
              ],
              bottom: showDivider
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child:
                          Divider(height: 1, color: colors.borderColor),
                    )
                  : null,
            )
          : null,
      body: SafeArea(
        top: paddingTop,
        child: body(context),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );

    return scaffold;
  }
}
