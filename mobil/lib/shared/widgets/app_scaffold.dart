// Shared [Scaffold] with app bar, back behavior, and optional bottom bar.

import 'package:flutter/material.dart';

import '../../app/router/app_router.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    this.titlePadding,
    this.titleAlignment,
    this.leading,
    required this.body,
    this.actions,
    this.showBack = true,
    this.showAppBarDivider = false,
    this.centerTitle,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final String? title;
  final Widget? titleWidget;
  final EdgeInsetsGeometry? titlePadding;
  final AlignmentGeometry? titleAlignment;
  final Widget? leading;
  final Widget body;
  final List<Widget>? actions;
  final bool showBack;
  final bool showAppBarDivider;
  final bool? centerTitle;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final isHomeTab =
        ModalRoute.of(context)?.settings.name == AppRoutes.companyDashboard;

    // Show back button if we can pop OR if we're on a replacement tab (like Chat) that needs to go to Dashboard
    final showLeading = showBack && (canPop || !isHomeTab);

    final hasActions = actions != null && actions!.isNotEmpty;
    final hasTitle = title != null || titleWidget != null;
    final effectiveCenterTitle =
        centerTitle ?? (title != null || titleWidget != null);
    final effectiveTitleWidget = titleWidget ??
        (title == null
            ? null
            : Align(
                alignment: titleAlignment ?? Alignment.center,
                child: Padding(
                  padding: titlePadding ?? EdgeInsets.zero,
                  child: Text(title!),
                ),
              ));
    final safeBottomNavigationBar = bottomNavigationBar == null
        ? null
        : SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: bottomNavigationBar!,
          );

    final hasBottomNav = safeBottomNavigationBar != null;

    Widget scaffold = Scaffold(
      appBar: (!hasTitle && !showLeading && !hasActions)
          ? null
          : AppBar(
              automaticallyImplyLeading: showLeading,
              leading: showLeading ? null : leading,
              centerTitle: effectiveCenterTitle,
              title: effectiveTitleWidget,
              actions: actions,
              bottom: showAppBarDivider
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(1),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.2),
                      ),
                    )
                  : null,
            ),
      body: SafeArea(
        bottom: !hasBottomNav,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxBodyWidth = constraints.maxWidth < 1200
                ? constraints.maxWidth
                : 1200.0;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBodyWidth),
                child: body,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: safeBottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );

    if (hasBottomNav) {
      return PopScope(
        canPop: false, // Intercept to handle redirection manually
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (!isHomeTab) {
            Navigator.of(context)
                .pushReplacementNamed(AppRoutes.companyDashboard);
          }
        },
        child: scaffold,
      );
    }

    return scaffold;
  }
}
