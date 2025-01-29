import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/core/widgets/png_save_widget.dart';
import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_action.dart';
import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_model.dart';
import 'package:easy_signature/features/create_sign/widget/sign_drawing_canvas_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignDrawingCanvas extends StatefulWidget {
  const SignDrawingCanvas({required this.canvasSize, super.key});

  final Size canvasSize;

  @override
  State<SignDrawingCanvas> createState() => _SignDrawingCanvasState();
}

class _SignDrawingCanvasState extends BaseStatefullWidget<SignDrawingCanvas> {
  final boundaryKey = GlobalKey<PngSaveWidgetState>();

  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<CreateSignViewModel>().state;

    if (uiState.lastAction is OnSaveRequest) {
      context.read<CreateSignViewModel>().onAction(
            OnSave(byteDataFuture: boundaryKey.currentState!.capturePngWithWidget()),
          );
    }

    return PngSaveWidget(
      key: boundaryKey,
      child: CustomPaint(
        size: widget.canvasSize,
        painter: SignDrawingCanvasPainter(
          paths: uiState.paths,
          color: uiState.selectedColor.color,
          strokeWidth: uiState.strokeWidth,
        ),
      ),
    );
  }
}
