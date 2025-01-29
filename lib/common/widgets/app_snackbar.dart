import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:easy_signature/core/navigation/app_navigator.dart';
import 'package:easy_signature/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppSnackbar {
  static void show({
    Widget? content,
    AppLocalizedKeys? localizedKey,
    AsyncCallback? action,
    AppLocalizedKeys? actionLabel,
  }) {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;
    ScaffoldMessenger.of(globalContext).showSnackBar(
      SnackBar(
        content: content ?? AppText(localizedKey!),
        action: (action != null && actionLabel != null)
            ? SnackBarAction(
                label: actionLabel.toLocalized(globalContext),
                onPressed: () async {
                  await action();
                },
              )
            : null,
      ),
    );
  }
}
