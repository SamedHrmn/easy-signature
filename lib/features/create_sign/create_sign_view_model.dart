import 'package:easy_signature/core/widgets/base_cubit.dart';
import 'package:easy_signature/core/widgets/base_data_holder.dart';
import 'package:easy_signature/core/widgets/base_state.dart';
import 'package:flutter/material.dart';

sealed class SignDrawingCanvasAction {}

final class OnDrawing extends SignDrawingCanvasAction {
  OnDrawing({required this.point});
  final Offset point;
}

final class OnChangeColor extends SignDrawingCanvasAction {
  OnChangeColor({required this.color});
  final DrawingSignColorOptions color;
}

final class OnSave extends SignDrawingCanvasAction {}

class CreateSignViewModel extends BaseCubit<SignDrawingCanvasDataHolder> {
  CreateSignViewModel() : super(const SignDrawingCanvasDataHolder());

  void _addPoints(Offset point) {
    state.points.add(point);
    updateState(state.copyWith(points: state.points.toList()));
  }

  void _updateSelectedColor(DrawingSignColorOptions color) {
    updateState(state.copyWith(selectedColor: color));
  }

  void onAction(SignDrawingCanvasAction action) {
    switch (action) {
      case OnDrawing(point: final point):
        _addPoints(point);

      case OnChangeColor(color: final color):
        _updateSelectedColor(color);

      case OnSave():
        break;
    }
  }
}

final class SignDrawingCanvasDataHolder extends BaseState {
  const SignDrawingCanvasDataHolder({
    super.baseDataHolder = const BaseDataHolder(),
    this.points = const [],
    this.selectedColor = DrawingSignColorOptions.black,
    this.strokeWidth = 4.0,
  });
  final List<Offset> points;
  final DrawingSignColorOptions selectedColor;
  final double strokeWidth;

  @override
  SignDrawingCanvasDataHolder copyWith({
    BaseDataHolder? baseDataHolder,
    List<Offset>? points,
    DrawingSignColorOptions? selectedColor,
    double? strokeWidth,
  }) {
    return SignDrawingCanvasDataHolder(
      baseDataHolder: baseDataHolder ?? this.baseDataHolder,
      points: points ?? this.points,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}

enum DrawingSignColorOptions {
  black(Color.fromARGB(255, 0, 0, 0)),
  red(Color.fromARGB(255, 203, 17, 17)),
  blue(Color.fromARGB(255, 15, 0, 147));

  const DrawingSignColorOptions(this.color);

  final Color color;
}
