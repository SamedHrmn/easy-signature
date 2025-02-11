import 'dart:typed_data';
import 'dart:ui';

import 'package:equatable/equatable.dart';

class SignImage extends Equatable {
  SignImage({
    required this.bytes,
    required this.widgetSize,
    this.offset = Offset.zero,
    this.isAsset = true,
  });
  final Uint8List? bytes;
  final Size? widgetSize;
  final Offset offset;
  final bool isAsset;

  SignImage copyWith({
    Uint8List? bytes,
    Size? widgetSize,
    Offset? offset,
    bool? isAsset,
  }) {
    return SignImage(
      bytes: bytes ?? this.bytes,
      widgetSize: widgetSize ?? this.widgetSize,
      offset: offset ?? this.offset,
      isAsset: isAsset ?? this.isAsset,
    );
  }

  @override
  List<Object?> get props => [bytes, widgetSize, offset, isAsset];
}
