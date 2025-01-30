import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:easy_signature/core/util/app_sizer.dart';
import 'package:flutter/material.dart';

class AppTopbar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopbar({required this.title, this.onBack, this.canPop = true, this.actions, super.key});

  final AppLocalizedKeys title;
  final bool canPop;
  final VoidCallback? onBack;
  final List<AppTopBarActionButton>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: canPop,
      leading: canPop
          ? InkWell(
              onTap: onBack,
              child: const Icon(Icons.arrow_back_ios_new),
            )
          : null,
      title: AppText(
        title,
        size: AppSizer.scaleWidth(20),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppTopBarActionButton extends StatelessWidget {
  const AppTopBarActionButton({required this.child, this.onPressed, this.onTapDown, super.key});

  final Widget child;
  final VoidCallback? onPressed;
  final void Function(TapDownDetails details)? onTapDown;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: onTapDown,
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: SizedBox.square(
        dimension: kMinInteractiveDimension,
        child: child,
      ),
    );
  }
}
