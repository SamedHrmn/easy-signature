import 'dart:typed_data';
import 'dart:ui';

import 'package:easy_signature/core/widgets/base_data_holder.dart';
import 'package:easy_signature/core/widgets/base_state.dart';
import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_action.dart';

class SignDrawingCanvasDataHolder extends BaseState {
  const SignDrawingCanvasDataHolder({
    super.baseDataHolder = const BaseDataHolder(),
    this.paths = const [],
    this.lastSavedDrawingSignSuccess = false,
    this.lastSavedDrawingSignData,
    this.lastAction,
    this.selectedColor = DrawingSignColorOptions.black,
    this.strokeWidth = 4.0,
  });
  final List<Path> paths;
  final SignDrawingCanvasAction? lastAction;
  final DrawingSignColorOptions selectedColor;
  final double strokeWidth;

  final bool lastSavedDrawingSignSuccess;
  final Uint8List? lastSavedDrawingSignData;

  @override
  SignDrawingCanvasDataHolder copyWith({
    BaseDataHolder? baseDataHolder,
    SignDrawingCanvasAction? lastAction,
    bool? lastSavedDrawingSignSuccess,
    Uint8List? lastSavedDrawingSignData,
    List<Path>? paths,
    DrawingSignColorOptions? selectedColor,
    double? strokeWidth,
  }) {
    return SignDrawingCanvasDataHolder(
      baseDataHolder: baseDataHolder ?? this.baseDataHolder,
      paths: paths ?? this.paths,
      lastSavedDrawingSignSuccess: lastSavedDrawingSignSuccess ?? this.lastSavedDrawingSignSuccess,
      lastSavedDrawingSignData: lastSavedDrawingSignData ?? this.lastSavedDrawingSignData,
      lastAction: lastAction ?? this.lastAction,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  List<Object?> get props => [
        baseDataHolder,
        lastAction,
        lastSavedDrawingSignSuccess,
        lastSavedDrawingSignData,
        paths,
        selectedColor,
        strokeWidth,
      ];
}

enum DrawingSignColorOptions {
  black(Color.fromARGB(255, 0, 0, 0)),
  red(Color.fromARGB(255, 203, 17, 17)),
  blue(Color.fromARGB(255, 15, 0, 147));

  const DrawingSignColorOptions(this.color);

  final Color color;
}
