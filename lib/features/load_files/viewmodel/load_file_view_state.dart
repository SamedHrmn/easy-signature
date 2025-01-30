import 'package:easy_signature/common/widgets/app_ads_interstitial.dart';
import 'package:easy_signature/core/widgets/base_data_holder.dart';
import 'package:easy_signature/core/widgets/base_state.dart';
import 'package:easy_signature/features/signing/data/sign_image.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:easy_signature/features/signing/pdf/app_pdf_document.dart';
import 'package:flutter/material.dart';

class LoadFileViewDataHolder extends BaseState {
  const LoadFileViewDataHolder({
    this.appStoragePermissionStatus = AppStoragePermissionStatus.notRequestedYet,
    this.pickedFile,
    this.pickedFileReady = false,
    this.pdfDocument,
    this.signImage,
    this.interstitalWidgetKey,
  }) : super(baseDataHolder: const BaseDataHolder());
  final AppStoragePermissionStatus appStoragePermissionStatus;
  final SignableFile? pickedFile;
  final AppPdfDocument? pdfDocument;
  final SignImage? signImage;
  final bool pickedFileReady;
  final GlobalKey<AppAdsInterstitialState>? interstitalWidgetKey;

  @override
  LoadFileViewDataHolder copyWith({
    BaseDataHolder? baseDataHolder,
    AppStoragePermissionStatus? appStoragePermissionStatus,
    SignableFile? pickedFile,
    bool? pickedFileReady,
    AppPdfDocument? appPdfDocument,
    SignImage? signImage,
    GlobalKey<AppAdsInterstitialState>? interstitalWidgetKey,
  }) {
    return LoadFileViewDataHolder(
      appStoragePermissionStatus: appStoragePermissionStatus ?? this.appStoragePermissionStatus,
      pickedFile: pickedFile ?? this.pickedFile,
      pickedFileReady: pickedFileReady ?? this.pickedFileReady,
      pdfDocument: appPdfDocument ?? pdfDocument,
      signImage: signImage ?? this.signImage,
      interstitalWidgetKey: interstitalWidgetKey ?? this.interstitalWidgetKey,
    );
  }

  @override
  List<Object?> get props => [
        baseDataHolder,
        appStoragePermissionStatus,
        pickedFile,
        pickedFileReady,
        pdfDocument,
        signImage,
        interstitalWidgetKey,
      ];
}

enum AppStoragePermissionStatus {
  notRequestedYet,
  requestedAndGranted,
  requestedAndDenied,
  implicitlyGranted,
}
