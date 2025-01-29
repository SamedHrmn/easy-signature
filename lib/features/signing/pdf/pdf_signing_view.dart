import 'package:alh_pdf_view/alh_pdf_view.dart';
import 'package:easy_signature/core/widgets/base_statefull_widget.dart';
import 'package:easy_signature/features/signing/sign_file_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PdfSigningView extends StatefulWidget {
  const PdfSigningView({super.key});

  @override
  State<PdfSigningView> createState() => _PdfSigningViewState();
}

class _PdfSigningViewState extends BaseStatefullWidget<PdfSigningView> {
  final fileWidgetKey = GlobalKey();

  double getPdfCanvasHeight(SignFileViewDataHolder uiState) {
    if (uiState.pickedFile == null) return 0;

    if (uiState.pdfDocument == null) {
      return MediaQuery.sizeOf(context).width * (uiState.pickedFile!.defaultSize!.height / uiState.pickedFile!.defaultSize!.width);
    }
    return MediaQuery.sizeOf(context).width * (uiState.pdfDocument!.pageSize!.height / uiState.pdfDocument!.pageSize!.width);
  }

  @override
  Future<void> onInitAsync() async {
    final targetSize = (fileWidgetKey.currentContext!.findAncestorRenderObjectOfType()! as RenderBox).size;
    await context.read<SignFileViewModel>().initFileCanvas(targetSize);
  }

  @override
  Widget build(BuildContext context) {
    final uiState = context.watch<SignFileViewModel>().state;

    return SizedBox(
      width: double.maxFinite,
      height: getPdfCanvasHeight(uiState),
      child: AlhPdfView(
        key: fileWidgetKey,
        enableDoubleTap: false,
        maxZoom: 1,
        minZoom: 1,
        filePath: uiState.pickedFile!.filePath,
        onPageChanged: (page, total) {
          context.read<SignFileViewModel>().updatePdfSignablePageIndex(page);
        },
      ),
    );
  }
}
