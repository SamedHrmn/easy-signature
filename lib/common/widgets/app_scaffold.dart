import 'package:easy_signature/common/helpers/app_package_manager.dart';
import 'package:easy_signature/common/widgets/app_privacy_policy_sheet.dart';
import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/common/widgets/app_topbar.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:easy_signature/core/navigation/app_navigator.dart';
import 'package:easy_signature/core/util/app_sizer.dart';
import 'package:easy_signature/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.topbarTitle,
    this.canPop = true,
    this.onBack,
    super.key,
    this.child,
  });
  final Widget? child;
  final AppLocalizedKeys topbarTitle;
  final bool canPop;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: Scaffold(
        appBar: AppTopbar(
          title: topbarTitle,
          onBack: onBack,
          canPop: canPop,
          actions: [
            AppTopBarActionButton(
              child: const Icon(Icons.more_vert),
              onTapDown: (details) async {
                final offset = details.globalPosition;

                await showMenu<void>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    offset.dx,
                    offset.dy,
                    AppSizer.screenWidth - offset.dx,
                    AppSizer.screenHeight - offset.dy,
                  ),
                  items: AppTopBarActions.values
                      .map(
                        (e) => PopupMenuItem<void>(
                          onTap: () async {
                            final actionFunc = e.action();
                            await actionFunc();
                          },
                          child: AppText(
                            e.toLocalizedKey(),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
        body: SafeArea(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}

enum AppTopBarActions {
  privacyPolicy,
  licences;

  AppLocalizedKeys toLocalizedKey() {
    switch (this) {
      case AppTopBarActions.privacyPolicy:
        return AppLocalizedKeys.actionMenuPrivacyPolicy;

      case AppTopBarActions.licences:
        return AppLocalizedKeys.actionMenuLicences;
    }
  }

  AsyncCallback action() {
    switch (this) {
      case AppTopBarActions.privacyPolicy:
        return () async {
          final context = getIt<AppNavigator>().navigatorKey.currentContext!;

          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return const AppPrivacyPolicySheet();
            },
          );
        };

      case AppTopBarActions.licences:
        return () async {
          final appVer = await getIt<AppPackageManager>().getAppVersion();
          final appName = await getIt<AppPackageManager>().getAppName();
          final context = getIt<AppNavigator>().navigatorKey.currentContext!;

          if (!context.mounted) return;

          showLicensePage(
            context: context,
            applicationName: appName,
            applicationVersion: appVer,
          );
        };
    }
  }
}
