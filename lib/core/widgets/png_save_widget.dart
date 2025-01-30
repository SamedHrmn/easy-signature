import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PngSaveWidget extends StatefulWidget {
  const PngSaveWidget({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<PngSaveWidget> createState() => PngSaveWidgetState();
}

class PngSaveWidgetState extends State<PngSaveWidget> {
  final repaintKey = GlobalKey();

  Future<Uint8List> capturePng({required Size? defaultImageSize}) async {
    final boundary = repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    // Get the actual widget size
    final widgetSize = boundary.size;
    final sourceImageSize = defaultImageSize ?? widgetSize;

    // Compute the scaling factor
    final scaleX = sourceImageSize.width / widgetSize.width;
    final scaleY = sourceImageSize.height / widgetSize.height;

    // Use the larger scale to maintain aspect ratio
    final scale = scaleX > scaleY ? scaleX : scaleY;

    final image = await boundary.toImage(pixelRatio: scale);
    final byteData = await image.toByteData(format: ImageByteFormat.png);

    final pngBytes = byteData!.buffer.asUint8List();
    return pngBytes;
  }

  Future<ByteData?> capturePngWithWidget() async {
    final boundary = repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    final image = await boundary.toImage();

    const scaleFactor = 1.0;

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final paint = Paint()..blendMode = BlendMode.clear;
    canvas
      ..drawPaint(paint)
      ..scale(scaleFactor)
      ..drawImage(image, Offset.zero, Paint());

    final picture = recorder.endRecording();

    final scaledImage = await picture.toImage(
      (image.width / scaleFactor).toInt(),
      (image.height / scaleFactor).toInt(),
    );

    return scaledImage.toByteData(format: ImageByteFormat.png);
  }

  Size widgetSize() => (repaintKey.currentContext!.findRenderObject()! as RenderBox).size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: widget.child,
    );
  }
}
