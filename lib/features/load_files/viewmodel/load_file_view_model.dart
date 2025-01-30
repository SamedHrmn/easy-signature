import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:easy_signature/common/helpers/app_file_manager.dart';
import 'package:easy_signature/common/helpers/app_permission_manager.dart';
import 'package:easy_signature/common/widgets/app_ads_interstitial.dart';
import 'package:easy_signature/core/widgets/base_cubit.dart';

import 'package:easy_signature/features/load_files/viewmodel/load_file_view_action.dart';
import 'package:easy_signature/features/load_files/viewmodel/load_file_view_state.dart';
import 'package:easy_signature/features/signing/data/sign_image.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LoadFileViewModel extends BaseCubit<LoadFileViewDataHolder> {
  LoadFileViewModel({
    required this.appPermissionManager,
    required this.appFileManager,
  }) : super(const LoadFileViewDataHolder());

  final AppPermissionManager appPermissionManager;
  final AppFileManager appFileManager;

  void updatePermissionStatus(AppStoragePermissionStatus newStatus) {
    updateState(state.copyWith(appStoragePermissionStatus: newStatus));
  }

  void setInterstitalWidgetKey(GlobalKey<AppAdsInterstitialState> interstitalWidgetKey) {
    updateState(state.copyWith(interstitalWidgetKey: interstitalWidgetKey));
  }

  void showInterstitialAd() {
    state.interstitalWidgetKey?.currentState?.showInterstitialAd();
  }

  Future<void> onAction(LoadFileViewAction action) async {
    switch (action) {
      case OnPickFile():
        await _pickSignableFile();
      case OnPickSignImage(widgetSize: final widgetSize):
        await _pickSignImage(widgetSize: widgetSize);
      default:
    }
  }

  Future<void> askStoragePermissionIfNeeded() async {
    await appPermissionManager.askStoragePermission(
      onGranted: () async {
        updateState(state.copyWith(appStoragePermissionStatus: AppStoragePermissionStatus.requestedAndGranted));
      },
      onDenied: () async {
        updateState(state.copyWith(appStoragePermissionStatus: AppStoragePermissionStatus.requestedAndDenied));
      },
      aboveSdk33: () async {
        updateState(state.copyWith(appStoragePermissionStatus: AppStoragePermissionStatus.implicitlyGranted));
      },
    );
  }

  void convertDrawingSignToSignImage(Uint8List? bytes) {
    if (bytes == null) {
      return;
    }

    final signImage = SignImage(bytes: bytes, widgetSize: null);
    updateState(state.copyWith(signImage: signImage));
  }

  Future<void> _pickSignableFile() async {
    if (state.appStoragePermissionStatus == AppStoragePermissionStatus.requestedAndDenied) return;

    updateState(state.copyWith(pickedFileReady: false));

    final result = await appFileManager.pickSignableFile();
    if (result == null || result.files.isEmpty) return;

    final platformFile = result.files.first;

    Size? defaultSize;

    final fileExtString = appFileManager.getFileExtFromPath(platformFile.path!);
    final fileExt = SignableFileExtension.fromString(fileExtString);

    if (fileExt == null) return;

    final imageBytes = await File(platformFile.path!).readAsBytes();

    switch (fileExt) {
      case SignableFileExtension.pdf:
        defaultSize = await appFileManager.getPdfSize(platformFile.path!);
      case SignableFileExtension.png:
      case SignableFileExtension.jpg:
      case SignableFileExtension.jpeg:
        final codec = await instantiateImageCodec(imageBytes);
        final frameInfo = await codec.getNextFrame();
        defaultSize = Size(frameInfo.image.width.truncateToDouble(), frameInfo.image.height.truncateToDouble());
    }

    final pickedFile = SignableFile(
      bytes: imageBytes,
      filePath: platformFile.path,
      defaultSize: defaultSize,
      signableFileExtension: fileExt,
    );

    updateState(state.copyWith(pickedFile: pickedFile, pickedFileReady: true));
  }

  Future<void> _pickSignImage({required Size widgetSize}) async {
    if (state.appStoragePermissionStatus == AppStoragePermissionStatus.requestedAndDenied) return;

    final result = await appFileManager.pickSignImage();
    if (result == null || result.files.isEmpty) return;

    final platformFile = result.files.first;

    final bytes = await platformFile.xFile.readAsBytes();

    final signImage = SignImage(bytes: bytes, widgetSize: widgetSize, isAsset: false);

    updateState(state.copyWith(signImage: signImage));
  }

  Future<void> openAppSettingsForPermission() async {
    await openAppSettings();
  }
}
