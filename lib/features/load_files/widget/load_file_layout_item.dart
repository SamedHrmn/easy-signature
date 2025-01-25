import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadFileLayoutItem extends StatelessWidget {
  const LoadFileLayoutItem({
    required this.onTap,
    required this.titleKey,
    required this.backgroundColor,
    required this.child,
    super.key,
  });

  final AsyncCallback onTap;
  final AppLocalizedKeys titleKey;
  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.white),
      ),
      child: InkWell(
        onTap: () async {
          await onTap();
        },
        child: ColoredBox(
          color: backgroundColor,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: child,
              ),
              AppText(titleKey),
              const Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
