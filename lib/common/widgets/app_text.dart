import 'package:easy_signature/common/helpers/app_asset_manager.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.localizedKey, {
    this.localizedArg,
    super.key,
    this.size,
    this.fontWeight = FontWeight.w600,
    this.textAlign = TextAlign.start,
    this.color,
  });

  final AppLocalizedKeys localizedKey;
  final List<String>? localizedArg;
  final double? size;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      localizedKey.toLocalized(context, args: localizedArg),
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: AppAssetManager.interFontFamily,
        fontWeight: fontWeight,
        fontSize: size ?? 16,
        color: color,
      ),
    );
  }
}
