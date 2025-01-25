import 'package:easy_signature/common/helpers/app_asset_manager.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.localizedKey, {
    super.key,
    this.size,
    this.fontWeight = FontWeight.w600,
  });

  final AppLocalizedKeys localizedKey;
  final double? size;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return Text(
      localizedKey.toLocalized(context),
      style: TextStyle(
        fontFamily: AppAssetManager.interFontFamily,
        fontWeight: fontWeight,
        fontSize: size ?? 16,
      ),
    );
  }
}
