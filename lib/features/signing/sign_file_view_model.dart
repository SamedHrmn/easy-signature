import 'package:easy_signature/common/helpers/app_file_manager.dart';
import 'package:easy_signature/core/widgets/base_cubit.dart';
import 'package:easy_signature/core/widgets/base_data_holder.dart';
import 'package:easy_signature/core/widgets/base_state.dart';
import 'package:easy_signature/core/widgets/png_save_widget.dart';
import 'package:easy_signature/features/signing/data/sign_image.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:easy_signature/features/signing/pdf/app_pdf_document.dart';
import 'package:flutter/material.dart';

class SignFileViewModel extends BaseCubit<SignFileViewDataHolder> {
  SignFileViewModel({required this.appFileManager}) : super(const SignFileViewDataHolder());

  final AppFileManager appFileManager;

  void setSignableFile(SignableFile? file) {
    updateState(state.copyWith(pickedFile: file));
  }

  void updateSignImageOffset(Offset pos) {
    updateState(state.copyWith(signImage: state.signImage?.copyWith(offset: pos)));
  }

  void updatePdfDocWidgetSize(Size widgetSize) {
    updateState(state.copyWith(pdfDocument: state.pdfDocument!.copyWith(widgetSize: widgetSize)));
  }

  void updatePdfSignablePageIndex(int page) {
    updateState(state.copyWith(pdfDocument: state.pdfDocument!.copyWith(currentPageIndex: page)));
  }

  Future<void> initFileCanvas(Size targetSize) async {
    if (state.pickedFile == null) return;

    switch (state.pickedFile!.signableFileExtension!) {
      case SignableFileExtension.pdf:
        final filePath = state.pickedFile!.filePath!;
        final pdfDoc = await appFileManager.readPdfDocument(filePath, targetSize);
        updateState(state.copyWith(pdfDocument: pdfDoc));
      case SignableFileExtension.jpg:
      case SignableFileExtension.png:
      case SignableFileExtension.jpeg:
        return;
    }
  }

  void initSignImage(SignImage? signImage, Size widgetSize) {
    updateState(
      state.copyWith(
        signImage: signImage?.copyWith(widgetSize: widgetSize),
      ),
    );
  }

  void clear() {
    updateState(const SignFileViewDataHolder());
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

  Future<String?> saveFile(GlobalKey<PngSaveWidgetState> fileKey) async {
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
      case SignableFileExtension.jpeg:
        final imageByte = await fileKey.currentState!.capturePng(defaultImageSize: state.pickedFile!.defaultSize);
        final signableFile = SignableFile(
          bytes: imageByte,
          filePath: state.pickedFile!.filePath,
          signableFileExtension: SignableFileExtension.fromString(appFileManager.getFileExtFromPath(state.pickedFile!.filePath!)),
          defaultSize: fileKey.currentState!.widgetSize(),
        );
        final savedFilePath = await appFileManager.saveFile(signableFile);
        emit(state.copyWith(pickedFile: signableFile));
        return savedFilePath;
    }
  }
}

class SignFileViewDataHolder extends BaseState {
  const SignFileViewDataHolder({this.pickedFile, this.pdfDocument, this.signImage}) : super(baseDataHolder: const BaseDataHolder());
  final SignableFile? pickedFile;
  final AppPdfDocument? pdfDocument;
  final SignImage? signImage;

  @override
  SignFileViewDataHolder copyWith({
    BaseDataHolder? baseDataHolder,
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

  @override
  List<Object?> get props => [baseDataHolder, pickedFile, pdfDocument, signImage];
}
