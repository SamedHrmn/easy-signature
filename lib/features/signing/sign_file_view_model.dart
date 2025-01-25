import 'package:easy_signature/common/helpers/app_file_manager.dart';
import 'package:easy_signature/features/signing/data/sign_image.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:easy_signature/features/signing/pdf/app_pdf_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignFileViewModel extends Cubit<SignFileViewDataHolder> {
  SignFileViewModel({required this.appFileManager}) : super(SignFileViewDataHolder());

  final AppFileManager appFileManager;

  void setSignableFile(SignableFile? file) {
    emit(state.copyWith(pickedFile: file));
  }

  void updateSignImageOffset(Offset pos) {
    emit(state.copyWith(signImage: state.signImage?.copyWith(offset: pos)));
  }

  void updatePdfDocWidgetSize(Size widgetSize) {
    emit(state.copyWith(pdfDocument: state.pdfDocument!.copyWith(widgetSize: widgetSize)));
  }

  void updatePdfSignablePageIndex(int page) {
    emit(state.copyWith(pdfDocument: state.pdfDocument!.copyWith(currentPageIndex: page)));
  }

  Future<void> initFileCanvas(Size targetSize) async {
    if (state.pickedFile == null) return;

    switch (state.pickedFile!.signableFileExtension!) {
      case SignableFileExtension.pdf:
        final filePath = state.pickedFile!.filePath!;
        final pdfDoc = await appFileManager.readPdfDocument(filePath, targetSize);
        emit(state.copyWith(pdfDocument: pdfDoc));
      default:
    }
  }

  Future<void> initSignImage(String path, Size widgetSize, BuildContext context, {bool isAsset = true}) async {
    if (isAsset) {
      final byteData = await DefaultAssetBundle.of(context).load(path);
      final signImage = SignImage(bytes: byteData.buffer.asUint8List(), widgetSize: widgetSize);
      emit(state.copyWith(signImage: signImage));
      return;
    }
    throw UnimplementedError('Non asset sign image does not implemented');
  }

  Future<void> _drawSignatureOverPdf() async {
    if (state.pdfDocument == null || state.signImage == null) return;

    await appFileManager.drawImageOverPdf(
      pdfDocument: state.pdfDocument!,
      imageByte: state.signImage!.bytes!,
      imageSize: state.signImage!.widgetSize!,
      imageOffset: state.signImage!.offset,
      pdfDocSize: state.pdfDocument!.pageSize!,
      pdfWidgetSize: state.pdfDocument!.widgetSize!,
    );
  }

  Future<String?> saveFile() async {
    if (state.pickedFile == null) {
      throw Exception('pickedFile cannot be null');
    }

    switch (state.pickedFile!.signableFileExtension!) {
      case SignableFileExtension.pdf:
        if (state.pdfDocument == null) return null;

        await _drawSignatureOverPdf();

        final pdfDoc = state.pdfDocument!;
        final signableFile = await pdfDoc.toSignableFile();

        final savedFilePath = await appFileManager.saveFile(signableFile);
        emit(state.copyWith(pickedFile: signableFile));
        return savedFilePath;
      case SignableFileExtension.png:
      case SignableFileExtension.jpg:
        throw UnimplementedError('png and jpg files not supported');
    }
  }
}

class SignFileViewDataHolder {
  SignFileViewDataHolder({this.pickedFile, this.pdfDocument, this.signImage});
  final SignableFile? pickedFile;
  final AppPdfDocument? pdfDocument;
  final SignImage? signImage;

  SignFileViewDataHolder copyWith({
    SignableFile? pickedFile,
    AppPdfDocument? pdfDocument,
    SignImage? signImage,
  }) {
    return SignFileViewDataHolder(
      pickedFile: pickedFile ?? this.pickedFile,
      pdfDocument: pdfDocument ?? this.pdfDocument,
      signImage: signImage ?? this.signImage,
    );
  }
}
