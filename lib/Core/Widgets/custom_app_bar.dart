import 'package:flutter/material.dart';
import 'package:medic/core/constants/app_colors.dart';
import 'package:medic/core/constants/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool forceShowBack;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? titleColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.showBackButton = true,
    this.forceShowBack = false,
    this.onBackPressed,
    this.backgroundColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final showBack =
        showBackButton && (forceShowBack || Navigator.of(context).canPop());

    return AppBar(
      iconTheme: IconThemeData(color: titleColor ?? Colors.white),
      backgroundColor: backgroundColor ?? AppColors.primary,
      titleSpacing: showBack ? 0 : 16,
      elevation: 0,
      leadingWidth: showBack ? 40 : 0,
      leading: showBack
          ? SizedBox(
              width: 40,
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: titleColor ?? Colors.white,
                  size: 20,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              ),
            )
          : null,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: AppTextStyles.h3.copyWith(
                    color: titleColor ?? Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
