import 'dart:ui';

sealed class LoadFileViewAction {}

final class OnPickFile extends LoadFileViewAction {}

final class OnPickSignImage extends LoadFileViewAction {
  OnPickSignImage({required this.widgetSize});
  final Size widgetSize;
}

final class OnCreateSignImage extends LoadFileViewAction {}
