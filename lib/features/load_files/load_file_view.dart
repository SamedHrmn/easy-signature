import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:easy_signature/common/helpers/app_asset_manager.dart';
import 'package:easy_signature/common/widgets/app_lottie_asset.dart';
import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/core/constant/color_constant.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:easy_signature/core/enums/route_enum.dart';
import 'package:easy_signature/core/navigation/app_navigator.dart';
import 'package:easy_signature/core/util/app_sizer.dart';
import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/features/load_files/load_file_view_model.dart';
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

  @override
  void onInit() {
    signSize = Size(AppSizer.scaleWidth(120), AppSizer.scaleHeight(50));
  }

  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<LoadFileViewModel>().state;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (uiState.pickedFileReady) ...{
                Expanded(
                  child: Column(
                    spacing: AppSizer.scaleHeight(12),
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await context.read<LoadFileViewModel>().onAction(OnPickFile());
                          },
                          child: AbsorbPointer(
                            child: PickedFilePreview(pickedFile: uiState.pickedFile!),
                          ),
                        ),
                      ),
                      TextButton(
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
                      ),
                    ],
                  ),
                ),
              } else ...{
                Expanded(
                  child: LoadFileLayoutItem(
                    onTap: () async {
                      await context.read<LoadFileViewModel>().onAction(OnPickFile());
                    },
                    backgroundColor: ColorConstant.pickFileBackground,
                    titleKey: AppLocalizedKeys.pickFile,
                    child: const AppLottieAsset(
                      AppAssetManager.pickFileAssetPath,
                      onErrorKey: AppLocalizedKeys.pickFile,
                    ),
                  ),
                ),
              },
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: pickYourSignBuilder(uiState),
                    ),
                    Expanded(
                      child: LoadFileLayoutItem(
                        onTap: () async {
                          getIt<AppNavigator>().navigateTo(RouteEnum.createSignView);
                        },
                        backgroundColor: ColorConstant.drawSignBackground,
                        titleKey: AppLocalizedKeys.drawYourSign,
                        child: AppLottieAsset(
                          size: Size(
                            double.maxFinite,
                            AppSizer.scaleHeight(120),
                          ),
                          AppAssetManager.signLottieAssetPath,
                          onErrorKey: AppLocalizedKeys.drawYourSign,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LoadFileLayoutItem pickYourSignBuilder(LoadFileViewDataHolder uiState) {
    return LoadFileLayoutItem(
      onTap: () async {
        await context.read<LoadFileViewModel>().onAction(OnPickSignImage(widgetSize: signSize));
      },
      backgroundColor: ColorConstant.pickSignBackground,
      titleKey: uiState.signImage != null ? AppLocalizedKeys.yourSign : AppLocalizedKeys.pickYourSign,
      child: AnimatedSwitcher(
        duration: Durations.medium1,
        child: uiState.signImage != null
            ? Image.memory(uiState.signImage!.bytes!)
            : const AppLottieAsset(
                AppAssetManager.tapLottieAssetPath,
                onErrorKey: AppLocalizedKeys.pickYourSign,
              ),
      ),
    );
  }
}

class SignImageAsset extends StatelessWidget {
  const SignImageAsset({required this.path, required this.globalKey, super.key});

  final String path;
  final GlobalKey globalKey;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      key: globalKey,
      fit: BoxFit.cover,
      path,
    );
  }
}

class PickedFilePreview extends StatelessWidget {
  const PickedFilePreview({required this.pickedFile, super.key});

  final SignableFile pickedFile;

  @override
  Widget build(BuildContext context) {
    switch (pickedFile.signableFileExtension) {
      case SignableFileExtension.pdf:
        return AlhPdfView(
          enableDoubleTap: false,
          fitPolicy: FitPolicy.width,
          maxZoom: 1,
          minZoom: 1,
          bytes: pickedFile.bytes,
        );

      default:
    }

    return const SizedBox.shrink();
  }
}
