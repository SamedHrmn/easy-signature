import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_signature/locator.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

final class AppPermissionManager {
  AppPermissionManager({required this.appDeviceManager});
  final AppDeviceManager appDeviceManager;

  Future<void> askStoragePermission({
    AsyncCallback? onGranted,
    AsyncCallback? onDenied,
    AsyncCallback? aboveSdk33,
  }) async {
    if (Platform.isAndroid) {
      final sdkIntAndroid = await appDeviceManager.getAndroidSdkInt();
      if (sdkIntAndroid < 33) {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          await onGranted?.call();
        } else {
          await onDenied?.call();
        }
      } else {
        await aboveSdk33?.call();
      }
    }
  }

  static Future<bool> storagePermissionIsGrantedBelowSdk33() async {
    if (Platform.isAndroid) {
      final sdkIntAndroid = await getIt<AppDeviceManager>().getAndroidSdkInt();
      if (sdkIntAndroid < 33) {
        return Permission.storage.isGranted;
      }
      return false;
    } else if (Platform.isIOS) {
      return Permission.storage.isGranted;
    }
    return false;
  }
}

final class AppDeviceManager {
  Future<int> getAndroidSdkInt() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  Future<T> platformOperationHandler<T>({
    required Future<T> Function()? belowSDK33,
    required Future<T> Function()? aboveSDK33,
    required Future<T> Function()? onIOS,
    required Future<T> Function()? noneOfThem,
  }) async {
    if (Platform.isAndroid) {
      final sdkInt = await getAndroidSdkInt();
      if (sdkInt < 33) {
        if (belowSDK33 != null) return belowSDK33();
      } else {
        if (aboveSDK33 != null) return aboveSDK33();
      }
    } else if (Platform.isIOS) {
      if (onIOS != null) return onIOS();
    } else {
      if (noneOfThem != null) return noneOfThem();
    }

    throw UnsupportedError('Platform or operation not supported.');
  }
}
