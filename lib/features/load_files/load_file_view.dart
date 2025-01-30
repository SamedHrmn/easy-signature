import 'dart:typed_data';
import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:easy_signature/common/helpers/app_asset_manager.dart';
import 'package:easy_signature/common/helpers/app_initializer.dart';
import 'package:easy_signature/common/widgets/app_ads_banner.dart';
import 'package:easy_signature/common/widgets/app_ads_interstitial.dart';
import 'package:easy_signature/common/widgets/app_lottie_asset.dart';
import 'package:easy_signature/common/widgets/app_scaffold.dart';
import 'package:easy_signature/common/widgets/app_snackbar.dart';
import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/core/constant/color_constant.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:easy_signature/core/enums/route_enum.dart';
import 'package:easy_signature/core/navigation/app_navigator.dart';
import 'package:easy_signature/core/util/app_env_manager.dart';
import 'package:easy_signature/core/util/app_sizer.dart';
import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/features/ads/app_ads_manager.dart';

import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_model.dart';
import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_state.dart';
import 'package:easy_signature/features/load_files/viewmodel/load_file_view_action.dart';
import 'package:easy_signature/features/load_files/viewmodel/load_file_view_model.dart';
import 'package:easy_signature/features/load_files/viewmodel/load_file_view_state.dart';
import 'package:easy_signature/features/load_files/widget/load_file_layout_item.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:easy_signature/features/signing/sign_file_view_model.dart';
import 'package:easy_signature/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoadFileView extends StatefulWidget {
  const LoadFileView({super.key});

  @override
  State<LoadFileView> createState() => _LoadFileViewState();
}

class _LoadFileViewState extends BaseStatefullWidget<LoadFileView> {
  late final Size signSize;
  final bannerAdSize = AppBannerAdSize.normal;
  final interstitalWidgetKey = GlobalKey<AppAdsInterstitialState>();

  @override
  void onInit() {
    signSize = Size(AppSizer.scaleWidth(120), AppSizer.scaleHeight(50));
  }

  @override
  Future<void> onInitAsync() async {
    AppInitializer.removeSplash();
    context.read<LoadFileViewModel>().setInterstitalWidgetKey(interstitalWidgetKey);
    await context.read<LoadFileViewModel>().askStoragePermissionIfNeeded();
    return super.onInitAsync();
  }

  bool isPermissionDenied(LoadFileViewDataHolder uiState) => uiState.appStoragePermissionStatus == AppStoragePermissionStatus.requestedAndDenied;

  Future<void> showPermissionNeededSnackbar(LoadFileViewDataHolder uiState) async {
    if (isPermissionDenied(uiState)) {
      AppSnackbar.show(
        localizedKey: AppLocalizedKeys.needPermissionForContinue,
        action: () async {
          await context.read<LoadFileViewModel>().openAppSettingsForPermission();
        },
        actionLabel: AppLocalizedKeys.openSettings,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<LoadFileViewModel>().state;

    return AppScaffold(
      canPop: false,
      topbarTitle: AppLocalizedKeys.appName,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (uiState.pickedFileReady) ...{
                  Expanded(
                    child: pickedFileReadyColumn(context, uiState),
                  ),
                } else ...{
                  Expanded(
                    child: pickedFileLayout(context),
                  ),
                },
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: pickYourSignBuilder(uiState),
                      ),
                      Expanded(
                        child: createSignLayout(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: bannerAdSize.toAdSize().height.truncateToDouble(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AppAdsBanner(
              adUnitId: getIt<AppEnvManager>().getString(AppEnvKey.adsBannerNormal),
              adSize: bannerAdSize,
            ),
          ),
          Positioned.fill(
            child: AppAdsInterstitial(
              key: interstitalWidgetKey,
              adUnitId: getIt<AppEnvManager>().getString(AppEnvKey.adsInterstitial),
            ),
          ),
        ],
      ),
    );
  }

  LoadFileLayoutItem createSignLayout() {
    return LoadFileLayoutItem(
      onTap: () async {
        final uiState = context.read<LoadFileViewModel>().state;
        await showPermissionNeededSnackbar(uiState);
        if (isPermissionDenied(uiState)) return;

        getIt<AppNavigator>().navigateTo(RouteEnum.createSignView);
      },
      backgroundColor: ColorConstant.drawSignBackground,
      titleKey: AppLocalizedKeys.drawYourSign,
      child: const AppLottieAsset(
        AppAssetManager.signLottieAssetPath,
        onErrorKey: AppLocalizedKeys.drawYourSign,
      ),
    );
  }

  LoadFileLayoutItem pickedFileLayout(BuildContext context) {
    return LoadFileLayoutItem(
      onTap: () async {
        await showPermissionNeededSnackbar(context.read<LoadFileViewModel>().state);
        if (context.mounted) {
          await context.read<LoadFileViewModel>().onAction(OnPickFile());
        }
      },
      backgroundColor: ColorConstant.pickFileBackground,
      titleKey: AppLocalizedKeys.pickFile,
      child: const AppLottieAsset(
        AppAssetManager.pickFileAssetPath,
        onErrorKey: AppLocalizedKeys.pickFile,
      ),
    );
  }

  Column pickedFileReadyColumn(BuildContext context, LoadFileViewDataHolder uiState) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await showPermissionNeededSnackbar(context.read<LoadFileViewModel>().state);
              if (context.mounted) {
                await context.read<LoadFileViewModel>().onAction(OnPickFile());
              }
            },
            child: AbsorbPointer(
              child: PickedFilePreview(pickedFile: uiState.pickedFile!),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSizer.scaleHeight(12),
          ),
          child: uiState.signImage != null
              ? TextButton(
                  onPressed: () {
                    context.read<SignFileViewModel>().setSignableFile(context.read<LoadFileViewModel>().state.pickedFile);
                    getIt<AppNavigator>().navigateTo(RouteEnum.signFileView);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText(AppLocalizedKeys.goSigning),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: AppSizer.scaleWidth(24),
                      ),
                    ],
                  ),
                )
              : const AppText(AppLocalizedKeys.pickOrDrawSignToContinue),
        ),
      ],
    );
  }

  Widget pickYourSignBuilder(LoadFileViewDataHolder uiState) {
    return BlocListener<CreateSignViewModel, SignDrawingCanvasDataHolder>(
      listener: (context, state) {
        context.read<LoadFileViewModel>().convertDrawingSignToSignImage(state.lastSavedDrawingSignData);
      },
      listenWhen: (previous, current) => previous.lastSavedDrawingSignData != current.lastSavedDrawingSignData,
      child: LoadFileLayoutItem(
        onTap: () async {
          await showPermissionNeededSnackbar(context.read<LoadFileViewModel>().state);
          if (mounted) {
            await context.read<LoadFileViewModel>().onAction(OnPickSignImage(widgetSize: signSize));
          }
        },
        backgroundColor: ColorConstant.pickSignBackground,
        titleKey: uiState.signImage != null ? AppLocalizedKeys.yourSign : AppLocalizedKeys.pickYourSign,
        child: AnimatedSwitcher(
          duration: Durations.medium1,
          child: uiState.signImage != null
              ? Image.memory(uiState.signImage!.bytes!)
              : AppLottieAsset(
                  AppAssetManager.tapLottieAssetPath,
                  size: Size(double.maxFinite, AppSizer.scaleHeight(120)),
                  onErrorKey: AppLocalizedKeys.pickYourSign,
                ),
        ),
      ),
    );
  }
}

class SignImageAsset extends StatelessWidget {
  const SignImageAsset({required this.bytes, required this.globalKey, super.key});

  final Uint8List bytes;
  final GlobalKey globalKey;
  @override
  Widget build(BuildContext context) {
    return Image.memory(
      key: globalKey,
      fit: BoxFit.cover,
      bytes,
    );
  }
}

class PickedFilePreview extends StatelessWidget {
  const PickedFilePreview({required this.pickedFile, super.key});

  final SignableFile pickedFile;

  @override
  Widget build(BuildContext context) {
    switch (pickedFile.signableFileExtension) {
      case null:
        return const SizedBox.shrink();
      case SignableFileExtension.pdf:
        return AlhPdfView(
          enableDoubleTap: false,
          fitPolicy: FitPolicy.width,
          maxZoom: 1,
          minZoom: 1,
          bytes: pickedFile.bytes,
        );

      case SignableFileExtension.png:
      case SignableFileExtension.jpg:
      case SignableFileExtension.jpeg:
        return Image.memory(pickedFile.bytes!);
    }
  }
}
