import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nightout_core/nightout_core.dart';
import 'package:nightout/extensions/context.extension.dart';

class ContentLayout extends StatelessWidget {
  const ContentLayout({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.bottomAction,
    this.onBack,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 16),
  });

  final String? title;
  final List<Widget>? actions;
  final Widget child;
  final Widget? bottomAction;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final showLeading = onBack != null || canPop;
    final brightness = Theme.of(context).brightness;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: colors.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: colors.surface,
          foregroundColor: colors.text,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: colors.background,
            statusBarIconBrightness: brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: brightness == Brightness.dark ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: colors.background,
            systemNavigationBarIconBrightness: brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
          ),
          automaticallyImplyLeading: false,
          titleSpacing: showLeading ? 0 : 16,
          leading: showLeading
              ? IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                )
              : null,
          title: title == null
              ? null
              : Text(
                  title!,
                  style: NightOutText.sans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
          actions: actions,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.maxWidthPadding),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: padding,
                  child: child,
                ),
              ),
              if (bottomAction != null)
                ColoredBox(
                  color: colors.surface,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      child: bottomAction,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
