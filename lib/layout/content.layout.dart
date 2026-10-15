import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nightout/extensions/context.extension.dart';
import 'package:nightout/style/app.color.dart';
import 'package:nightout/style/app.theme.dart';

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
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final showLeading = onBack != null || canPop;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: AppColor.background,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: AppColor.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColor.white,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: true,
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
                  style: AppTextStyle.semiBold(AppTextStyle.heading18).copyWith(
                    color: AppColor.white,
                  ),
                ),
          actions: actions,
        ),
        body: ColoredBox(
          color: AppColor.primary,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.maxWidthPadding),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColor.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
                      color: AppColor.white,
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
        ),
      ),
    );
  }
}
