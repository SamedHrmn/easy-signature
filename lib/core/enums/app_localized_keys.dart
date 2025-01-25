import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum AppLocalizedKeys {
  pickYourSign,
  drawYourSign,
  pickFile,
  yourSign,
  goSigning;

  String toLocalized(BuildContext context) {
    switch (this) {
      case AppLocalizedKeys.pickYourSign:
      case AppLocalizedKeys.drawYourSign:
      case AppLocalizedKeys.pickFile:
      case AppLocalizedKeys.goSigning:
      case AppLocalizedKeys.yourSign:
        return name.tr(context: context);
    }
  }
}
