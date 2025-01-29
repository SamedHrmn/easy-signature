import 'package:easy_signature/common/widgets/app_loader_overlay.dart';
import 'package:easy_signature/common/widgets/app_scaffold.dart';
import 'package:easy_signature/common/widgets/app_snackbar.dart';
import 'package:easy_signature/common/widgets/app_text.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:easy_signature/core/enums/route_enum.dart';
import 'package:easy_signature/core/navigation/app_navigator.dart';
import 'package:easy_signature/core/util/app_sizer.dart';
import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/core/widgets/png_save_widget.dart';
import 'package:easy_signature/features/load_files/load_file_view.dart';
import 'package:easy_signature/features/load_files/viewmodel/load_file_view_model.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:easy_signature/features/signing/image/image_signing_view.dart';
import 'package:easy_signature/features/signing/pdf/pdf_signing_view.dart';
import 'package:easy_signature/features/signing/sign_file_view_model.dart';
import 'package:easy_signature/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignFileView extends StatefulWidget {
  const SignFileView({super.key});

  @override
  State<SignFileView> createState() => _SignFileViewState();
}

class _SignFileViewState extends BaseStatefullWidget<SignFileView> {
  late final Size signImageSize;
  final GlobalKey<PngSaveWidgetState> signedFileKey = GlobalKey();

  @override
  void onInit() {
    signImageSize = Size(AppSizer.scaleWidth(120), AppSizer.scaleHeight(50));
  }

  @override
  Future<void> onInitAsync() async {
    final signImage = context.read<LoadFileViewModel>().state.signImage;
    context.read<SignFileViewModel>().initSignImage(signImage, signImageSize);
  }

  final signImageWidgetKey = GlobalKey();

  bool filesReady(SignFileViewDataHolder uiState) {
    switch (uiState.pickedFile?.signableFileExtension) {
      case null:
        return false;
      case SignableFileExtension.pdf:
        return uiState.signImage == null || uiState.pickedFile == null || uiState.pdfDocument == null;
      case SignableFileExtension.png:
      case SignableFileExtension.jpg:
        return uiState.signImage == null || uiState.pickedFile == null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<SignFileViewModel>().state;

    return AppScaffold(
      topbarTitle: AppLocalizedKeys.signFile,
      child: AppLoaderOverlay(
        loading: filesReady(uiState),
        child: Column(
          children: [
            if (uiState.signImage != null && uiState.pickedFile != null) ...{
              Expanded(
                child: PngSaveWidget(
                  key: signedFileKey,
                  child: Stack(
                    children: [
                      Positioned(
                        top: AppSizer.scaleHeight(48),
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTapDown: (details) {
                            if (context.read<SignFileViewModel>().state.signImage?.offset == Offset.zero) {
                              context.read<SignFileViewModel>().updateSignImageOffset(
                                    details.localPosition - Offset(signImageSize.width / 2, signImageSize.height / 2),
                                  );
                            }
                          },
                          onPanUpdate: (details) {
                            final box = signedFileKey.currentContext!.findRenderObject()! as RenderBox;
                            final localPosition = box.globalToLocal(details.globalPosition);

                            final clampedX = localPosition.dx.clamp(0, box.size.width).toDouble();
                            final clampedY = localPosition.dy.clamp(AppSizer.scaleHeight(48), box.size.height);

                            context.read<SignFileViewModel>().updateSignImageOffset(
                                  Offset(clampedX, clampedY) - Offset(signImageSize.width / 2, signImageSize.height / 2),
                                );
                          },
                          child: switch (uiState.pickedFile!.signableFileExtension!) {
                            SignableFileExtension.pdf => const PdfSigningView(),
                            SignableFileExtension.jpg => const ImageSigningView(),
                            SignableFileExtension.png => const ImageSigningView(),
                          },
                        ),
                      ),
                      Positioned(
                        left: uiState.signImage!.offset.dx,
                        top: uiState.signImage!.offset.dy,
                        width: signImageSize.width,
                        height: signImageSize.height,
                        child: IgnorePointer(
                          child: uiState.signImage!.offset != Offset.zero
                              ? SignImageAsset(
                                  bytes: uiState.signImage!.bytes!,
                                  globalKey: signImageWidgetKey,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                      if (uiState.signImage?.offset == Offset.zero) ...{
                        Positioned.fill(
                          top: AppSizer.scaleHeight(16),
                          bottom: AppSizer.scaleHeight(16),
                          child: const IgnorePointer(
                            child: AppText(
                              AppLocalizedKeys.tapToPlaceSign,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      }
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSizer.scaleHeight(24)),
                child: ElevatedButton(
                  onPressed: onSave,
                  child: const AppText(AppLocalizedKeys.save),
                ),
              ),
            },
          ],
        ),
      ),
    );
  }

  Future<void> onSave() async {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;
    final newPath = await globalContext.read<SignFileViewModel>().saveFile(signedFileKey);

    if (globalContext.mounted && newPath != null) {
      AppSnackbar.show(
        content: AppText(
          AppLocalizedKeys.fileSavedSuccess,
          localizedArg: [newPath],
        ),
      );

      globalContext.read<SignFileViewModel>().clear();
      getIt<AppNavigator>().navigateToPopBackAll(RouteEnum.initialView);
    }
  }
}
