import 'dart:typed_data';
import 'dart:ui';

import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AppPdfDocument {
  AppPdfDocument({
    required this.pdfDocument,
    required this.path,
    required this.pageSize,
    required this.totalPage,
    required this.pages,
    this.signedPageIndex,
    this.sourcePdfPageize,
    this.widgetSize,
    this.currentPageIndex = 0,
  });
  final String? path;
  final int? signedPageIndex;
  final int currentPageIndex;
  final int? totalPage;
  final Size? pageSize;
  final Size? widgetSize;
  final Size? sourcePdfPageize;
  final PdfPageCollection pages;
  final PdfDocument? pdfDocument;

  PdfPage getSignablePage() {
    if (signedPageIndex == null) {
      throw Exception('Signable page index is null');
    }

    return pages[signedPageIndex!];
  }

  Future<SignableFile> toSignableFile() async {
    return SignableFile(
      bytes: Uint8List.fromList(await pdfDocument!.save()),
      filePath: path,
      signableFileExtension: SignableFileExtension.pdf,
    );
  }

  AppPdfDocument copyWith({
    List<int>? bytes,
    PdfDocument? pdfDocument,
    String? path,
    int? signedPageIndex,
    int? currentPageIndex,
    int? totalPage,
    Size? pageSize,
    Size? widgetSize,
    Size? sourcePdfPageize,
    PdfPageCollection? pages,
  }) {
    return AppPdfDocument(
      pdfDocument: pdfDocument ?? this.pdfDocument,
      path: path ?? this.path,
      signedPageIndex: signedPageIndex ?? this.signedPageIndex,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      totalPage: totalPage ?? this.totalPage,
      pageSize: pageSize ?? this.pageSize,
      sourcePdfPageize: sourcePdfPageize ?? this.sourcePdfPageize,
      widgetSize: widgetSize ?? this.widgetSize,
      pages: pages ?? this.pages,
    );
  }
}
