import 'dart:io';

import 'package:easy_signature/common/helpers/app_file_manager.dart';
import 'package:easy_signature/common/helpers/app_package_manager.dart';
import 'package:easy_signature/common/helpers/app_permission_manager.dart';
import 'package:easy_signature/core/navigation/app_navigator.dart';
import 'package:easy_signature/core/util/app_env_manager.dart';
import 'package:easy_signature/features/ads/app_ads_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:media_store_plus/media_store_plus.dart';

final getIt = GetIt.instance;

void setupLocator() {
  getIt
    ..registerSingleton<AppEnvManager>(AppEnvManager())
    ..registerSingleton<AppPackageManager>(AppPackageManager())
    ..registerSingleton<AppNavigator>(AppNavigator())
    ..registerSingleton<AppDeviceManager>(AppDeviceManager())
    ..registerSingleton<AppAdsManager>(AppAdsManager())
    ..registerSingleton<AppPermissionManager>(
      AppPermissionManager(appDeviceManager: getIt<AppDeviceManager>()),
    )
    ..registerSingletonAsync<AppFileManager>(
      () async {
        if (Platform.isAndroid) {
          final sdkInt = await getIt<AppDeviceManager>().getAndroidSdkInt();
          if (sdkInt < 33) {
            return AppFileManager(appDeviceManager: getIt<AppDeviceManager>(), mediaStorePlugin: null);
          } else {
            final mediaStore = MediaStore();
            MediaStore.appFolder = 'EasySignature';
            await MediaStore.ensureInitialized();

            return AppFileManager(appDeviceManager: getIt<AppDeviceManager>(), mediaStorePlugin: mediaStore);
          }
        }
        return AppFileManager(appDeviceManager: getIt<AppDeviceManager>(), mediaStorePlugin: null);
      },
    );
}
