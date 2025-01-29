import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

enum AppLocalizedKeys {
  pickYourSign,
  drawYourSign,
  pickFile,
  yourSign,
  createSign,
  signFile,
  tapToPlaceSign,
  fileSavedSuccess,
  save,
  pickOrDrawSignToContinue,
  needPermissionForContinue,
  openSettings,
  easySignature,
  actionMenuPrivacyPolicy,
  actionMenuLicences,
  okay,
  somethingWentWrong,
  goSigning;

  String toLocalized(BuildContext context, {List<String>? args}) {
    switch (this) {
      case AppLocalizedKeys.pickYourSign:
      case AppLocalizedKeys.drawYourSign:
      case AppLocalizedKeys.pickFile:
      case AppLocalizedKeys.goSigning:
      case AppLocalizedKeys.yourSign:
      case AppLocalizedKeys.createSign:
      case AppLocalizedKeys.signFile:
      case AppLocalizedKeys.tapToPlaceSign:
      case AppLocalizedKeys.fileSavedSuccess:
      case AppLocalizedKeys.save:
      case AppLocalizedKeys.pickOrDrawSignToContinue:
      case AppLocalizedKeys.needPermissionForContinue:
      case AppLocalizedKeys.openSettings:
      case AppLocalizedKeys.easySignature:
      case AppLocalizedKeys.okay:
      case AppLocalizedKeys.somethingWentWrong:
        return name.tr(context: context, args: args);
      case AppLocalizedKeys.actionMenuPrivacyPolicy:
        return 'actionMenu.privacyPolicy'.tr(context: context, args: args);
      case AppLocalizedKeys.actionMenuLicences:
        return 'actionMenu.licences'.tr(context: context, args: args);
    }
  }
}
