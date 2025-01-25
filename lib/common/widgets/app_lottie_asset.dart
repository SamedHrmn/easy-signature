import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLottieAsset extends StatelessWidget {
  const AppLottieAsset(
    this.path, {
    super.key,
    required this.onErrorKey,
    this.size,
  });

  final String path;
  final AppLocalizedKeys onErrorKey;
  final Size? size;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      path,
      width: size?.width,
      height: size?.height,
      errorBuilder: (context, error, stackTrace) {
        return AppText(onErrorKey);
      },
    );
  }
}
