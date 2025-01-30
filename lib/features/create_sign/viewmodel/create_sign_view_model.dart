import 'dart:typed_data';

import 'package:easy_signature/common/helpers/app_file_manager.dart';
import 'package:easy_signature/core/widgets/base_cubit.dart';

import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_action.dart';
import 'package:easy_signature/features/create_sign/viewmodel/create_sign_view_state.dart';
import 'package:flutter/rendering.dart';

class CreateSignViewModel extends BaseCubit<SignDrawingCanvasDataHolder> {
  CreateSignViewModel({required this.fileManager}) : super(const SignDrawingCanvasDataHolder());

  final AppFileManager fileManager;

  void _addPoints(Offset point, SignDrawingCanvasAction action) {
    if (state.paths.isNotEmpty) {
      final copyList = state.paths.toList();
      final currentPath = copyList.removeLast()..lineTo(point.dx, point.dy);
      copyList.add(currentPath);
      updateState(state.copyWith(paths: copyList, lastAction: action));
    }
  }

  void _updateSelectedColor(DrawingSignColorOptions color, SignDrawingCanvasAction action) {
    updateState(state.copyWith(selectedColor: color, lastAction: action));
  }

  void _onSaveRequest(SignDrawingCanvasAction action) {
    updateState(state.copyWith(lastAction: action));
  }

  void _clearCanvas(SignDrawingCanvasAction action) {
    updateState(
      state.copyWith(paths: [], lastAction: action),
    );
  }

  Future<void> _saveWidgetAsPng(Future<ByteData?> byteDataFuture, SignDrawingCanvasAction action) async {
    final byteData = await byteDataFuture;
    if (byteData == null) return;

    final savedPath = await fileManager.saveByteDataToFile(byteData.buffer.asUint8List());
    if (savedPath == null) {
      return;
    }

    updateState(
      state.copyWith(
        lastSavedDrawingSignSuccess: true,
        lastSavedDrawingSignData: byteData.buffer.asUint8List(),
        lastAction: action,
      ),
    );
  }

  void _startNewPath(Offset point, SignDrawingCanvasAction action) {
    final listCopy = state.paths.toList()..add(Path()..moveTo(point.dx, point.dy));
    updateState(state.copyWith(paths: listCopy, lastAction: action));
  }

  Future<void> onAction(SignDrawingCanvasAction action) async {
    switch (action) {
      case OnDrawingStart(point: final point):
        _startNewPath(point, action);
      case OnDrawing(point: final point):
        _addPoints(point, action);

      case OnDrawingClear():
        _clearCanvas(action);

      case OnChangeColor(color: final color):
        _updateSelectedColor(color, action);

      case OnSaveRequest():
        _onSaveRequest(action);
      case OnSave(byteDataFuture: final byteDataFuture):
        await _saveWidgetAsPng(byteDataFuture, action);
    }
  }
}
