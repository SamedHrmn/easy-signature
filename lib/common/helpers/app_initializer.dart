import 'package:easy_localization/easy_localization.dart';
import 'package:easy_signature/common/helpers/app_package_manager.dart';
import 'package:easy_signature/core/util/app_env_manager.dart';
import 'package:easy_signature/features/ads/app_ads_manager.dart';
import 'package:easy_signature/locator.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class AppInitializer {
  const AppInitializer.__();

  static Future<void> initializeApp() async {
    final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    setupLocator();

    await Future.wait([
      EasyLocalization.ensureInitialized(),
      getIt<AppAdsManager>().initialize(),
      getIt<AppEnvManager>().initialize(),
      getIt<AppPackageManager>().initialize(),
    ]);
  }

  static void removeSplash() {
    FlutterNativeSplash.remove();
  }
}
