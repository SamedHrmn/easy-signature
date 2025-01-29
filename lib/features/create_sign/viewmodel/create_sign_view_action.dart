import 'dart:typed_data';

import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_state.dart';
import 'package:flutter/rendering.dart';

sealed class SignDrawingCanvasAction {}

final class OnDrawing extends SignDrawingCanvasAction {
  OnDrawing({required this.point});
  final Offset point;
}

final class OnDrawingStart extends SignDrawingCanvasAction {
  OnDrawingStart({required this.point});
  final Offset point;
}

final class OnChangeColor extends SignDrawingCanvasAction {
  OnChangeColor({required this.color});
  final DrawingSignColorOptions color;
}

final class OnDrawingClear extends SignDrawingCanvasAction {}

final class OnSaveRequest extends SignDrawingCanvasAction {}

final class OnSave extends SignDrawingCanvasAction {
  OnSave({required this.byteDataFuture});

  final Future<ByteData?> byteDataFuture;
}
