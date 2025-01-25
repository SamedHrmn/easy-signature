import 'package:easy_signature/core/util/app_sizer.dart';
import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/features/create_sign/create_sign_view_model.dart';
import 'package:easy_signature/features/create_sign/widget/sign_drawing_canvas_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignDrawingCanvas extends StatefulWidget {
  const SignDrawingCanvas({super.key});

  @override
  State<SignDrawingCanvas> createState() => _SignDrawingCanvasState();
}

class _SignDrawingCanvasState extends BaseStatefullWidget<SignDrawingCanvas> {
  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<CreateSignViewModel>().state;

    return GestureDetector(
      onPanUpdate: (details) {
        context.read<CreateSignViewModel>().onAction(
              OnDrawing(point: details.localPosition),
            );
      },
      child: CustomPaint(
        size: Size(
          AppSizer.screenWidth,
          AppSizer.scaleHeight(300),
        ),
        painter: SignDrawingCanvasPainter(
          points: uiState.points,
          color: uiState.selectedColor.color,
          strokeWidth: uiState.strokeWidth,
        ),
      ),
    );
  }
}
