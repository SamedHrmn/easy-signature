import 'dart:io';

import 'package:easy_signature/common/helpers/app_file_manager.dart';
import 'package:easy_signature/common/helpers/app_permission_manager.dart';
import 'package:easy_signature/features/signing/data/sign_image.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:easy_signature/features/signing/pdf/app_pdf_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadFileViewModel extends Cubit<LoadFileViewDataHolder> {
  LoadFileViewModel({
    required this.appPermissionManager,
    required this.appFileManager,
  }) : super(const LoadFileViewDataHolder());

  final AppPermissionManager appPermissionManager;
  final AppFileManager appFileManager;

  void updatePermissionStatus(AppStoragePermissionStatus newStatus) {
    emit(state.copyWith(appStoragePermissionStatus: newStatus));
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
        emit(state.copyWith(appStoragePermissionStatus: AppStoragePermissionStatus.requestedAndGranted));
      },
      onDenied: () async {
        emit(state.copyWith(appStoragePermissionStatus: AppStoragePermissionStatus.requestedAndDenied));
      },
      aboveSdk33: () async {
        emit(state.copyWith(appStoragePermissionStatus: AppStoragePermissionStatus.implicitlyGranted));
      },
    );
  }

  Future<void> _pickSignableFile() async {
    if (state.appStoragePermissionStatus == AppStoragePermissionStatus.requestedAndDenied) return;

    emit(state.copyWith(pickedFileReady: false));

    final result = await appFileManager.pickSignableFile();
    if (result == null || result.files.isEmpty) return;

    final platformFile = result.files.first;

    Size? defaultSize;

    switch (SignableFileExtension.getSignableFileExtension(platformFile.path)) {
      case SignableFileExtension.pdf:
        defaultSize = await appFileManager.getPdfSize(platformFile.path!);
      default:
    }

    final pickedFile = SignableFile(
      bytes: await File(platformFile.path!).readAsBytes(),
      filePath: platformFile.path,
      defaultSize: defaultSize,
      signableFileExtension: SignableFileExtension.getSignableFileExtension(platformFile.path),
    );

    emit(state.copyWith(pickedFile: pickedFile, pickedFileReady: true));
  }

  Future<void> _pickSignImage({required Size widgetSize}) async {
    if (state.appStoragePermissionStatus == AppStoragePermissionStatus.requestedAndDenied) return;

    final result = await appFileManager.pickSignImage();
    if (result == null || result.files.isEmpty) return;

    final platformFile = result.files.first;

    final bytes = await platformFile.xFile.readAsBytes();

    final signImage = SignImage(bytes: bytes, widgetSize: widgetSize, isAsset: false);

    emit(state.copyWith(signImage: signImage));
  }
}

sealed class LoadFileViewAction {}

final class OnPickFile extends LoadFileViewAction {}

final class OnPickSignImage extends LoadFileViewAction {
  OnPickSignImage({required this.widgetSize});
  final Size widgetSize;
}

final class OnCreateSignImage extends LoadFileViewAction {}

class LoadFileViewDataHolder {
  const LoadFileViewDataHolder({
    this.appStoragePermissionStatus = AppStoragePermissionStatus.notRequestedYet,
    this.pickedFile,
    this.pickedFileReady = false,
    this.pdfDocument,
    this.signImage,
  });
  final AppStoragePermissionStatus appStoragePermissionStatus;
  final SignableFile? pickedFile;
  final AppPdfDocument? pdfDocument;
  final SignImage? signImage;
  final bool pickedFileReady;

  LoadFileViewDataHolder copyWith({
    AppStoragePermissionStatus? appStoragePermissionStatus,
    SignableFile? pickedFile,
    bool? pickedFileReady,
    AppPdfDocument? appPdfDocument,
    SignImage? signImage,
  }) {
    return LoadFileViewDataHolder(
      appStoragePermissionStatus: appStoragePermissionStatus ?? this.appStoragePermissionStatus,
      pickedFile: pickedFile ?? this.pickedFile,
      pickedFileReady: pickedFileReady ?? this.pickedFileReady,
      pdfDocument: appPdfDocument ?? pdfDocument,
      signImage: signImage ?? this.signImage,
    );
  }
}

enum AppStoragePermissionStatus {
  notRequestedYet,
  requestedAndGranted,
  requestedAndDenied,
  implicitlyGranted,
}
