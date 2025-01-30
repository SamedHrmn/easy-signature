import 'package:easy_signature/common/helpers/app_asset_manager.dart';
import 'package:easy_signature/common/widgets/app_ads_banner.dart';
import 'package:easy_signature/common/widgets/app_lottie_asset.dart';
import 'package:easy_signature/common/widgets/app_scaffold.dart';
import 'package:easy_signature/core/enums/app_localized_keys.dart';
import 'package:easy_signature/core/navigation/app_navigator.dart';
import 'package:easy_signature/core/util/app_env_manager.dart';
import 'package:easy_signature/core/util/app_sizer.dart';
import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/features/ads/app_ads_manager.dart';
import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_action.dart';
import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_model.dart';
import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_state.dart';
import 'package:easy_signature/features/create_sign/widget/sign_drawing_canvas.dart';
import 'package:easy_signature/features/load_files/viewmodel/load_file_view_model.dart';
import 'package:easy_signature/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateSignView extends StatefulWidget {
  const CreateSignView({super.key});

  @override
  State<CreateSignView> createState() => _CreateSignViewState();
}

class _CreateSignViewState extends BaseStatefullWidget<CreateSignView> {
  final canvasKey = GlobalKey();

  void showInterstitialAd() {
    final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;
    globalContext.read<LoadFileViewModel>().showInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<CreateSignViewModel>().state;

    return AppScaffold(
      onBack: () {
        showInterstitialAd();
        getIt<AppNavigator>().goBack(context);
      },
      topbarTitle: AppLocalizedKeys.createSign,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 12,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                signDrawCanvasBuilder(uiState),
                colorOptionsRow(context, uiState),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppAdsBanner(
              adUnitId: getIt<AppEnvManager>().getString(AppEnvKey.adsBannerLarge),
              adSize: AppBannerAdSize.large,
            ),
          ),
        ],
      ),
    );
  }

  Row colorOptionsRow(BuildContext context, SignDrawingCanvasDataHolder uiState) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: DrawingSignColorOptions.values
                .map(
                  (option) => GestureDetector(
                    onTap: () {
                      context.read<CreateSignViewModel>().onAction(OnChangeColor(color: option));
                    },
                    child: AnimatedContainer(
                      duration: Durations.medium3,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: option == uiState.selectedColor ? Colors.black : Colors.transparent,
                        ),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: option.color,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actionRow(context),
      ],
    );
  }

  Row actionRow(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        IconButton.outlined(
          onPressed: () {
            context.read<CreateSignViewModel>().onAction(OnDrawingClear());
          },
          icon: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              AppAssetManager.clearIcon,
              width: AppSizer.scaleWidth(32),
            ),
          ),
        ),
        IconButton.outlined(
          onPressed: () {
            final globalContext = getIt<AppNavigator>().navigatorKey.currentContext!;
            showInterstitialAd();

            globalContext.read<CreateSignViewModel>().onAction(OnSaveRequest());
            getIt<AppNavigator>().goBack(globalContext);
          },
          icon: Padding(
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              AppAssetManager.saveIcon,
              width: AppSizer.scaleWidth(32),
            ),
          ),
        ),
      ],
    );
  }

  Container signDrawCanvasBuilder(SignDrawingCanvasDataHolder uiState) {
    return Container(
      key: canvasKey,
      decoration: BoxDecoration(border: Border.all()),
      height: AppSizer.scaleHeight(280),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onPanStart: (details) {
              context.read<CreateSignViewModel>().onAction(OnDrawingStart(point: details.localPosition));
            },
            onPanUpdate: (details) {
              final box = canvasKey.currentContext!.findRenderObject()! as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);

              final clampedX = localPosition.dx.clamp(0, box.size.width).toDouble();
              final clampedY = localPosition.dy.clamp(0, box.size.height).toDouble();

              context.read<CreateSignViewModel>().onAction(
                    OnDrawing(point: Offset(clampedX, clampedY)),
                  );
            },
            child: AnimatedSwitcher(
              duration: Durations.medium1,
              child: uiState.paths.isEmpty
                  ? const AppLottieAsset(
                      AppAssetManager.signLottieAssetPath,
                      onErrorKey: AppLocalizedKeys.drawYourSign,
                    )
                  : SignDrawingCanvas(
                      canvasSize: constraints.biggest,
                    ),
            ),
          );
        },
      ),
    );
  }
}
