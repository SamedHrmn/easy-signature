import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:easy_signature/common/helpers/app_permission_manager.dart';
import 'package:easy_signature/features/signing/data/signable_file.dart';
import 'package:easy_signature/features/signing/pdf/app_pdf_document.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

final class AppFileManager {
  AppFileManager({
    required this.appDeviceManager,
    required this.mediaStorePlugin,
  });
  final AppDeviceManager appDeviceManager;
  final MediaStore? mediaStorePlugin;

  Future<FilePickerResult?> pickSignableFile() async {
    return FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'jpg', 'png']);
  }

  Future<FilePickerResult?> pickSignImage() async {
    return FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['jpg', 'png']);
  }

  Future<String> _createDestinationPath(String originalPath, String ext) async {
    var editedPath = originalPath.substring(originalPath.lastIndexOf('/') + 1);

    switch (ext) {
      case 'pdf':
        editedPath = editedPath.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), '_signed.pdf');
      case 'png':
        editedPath = editedPath.replaceFirst(RegExp(r'\.png$', caseSensitive: false), '_signed.png');
      case 'jpg':
        editedPath = editedPath.replaceFirst(RegExp(r'\.jpg$', caseSensitive: false), '_signed.jpg');
    }

    return appDeviceManager.platformOperationHandler<String>(
      belowSDK33: () async {
        final externalFileDir = await getExternalStorageDirectory();

        return '${externalFileDir!.path}/$editedPath';
      },
      aboveSDK33: () async {
        return editedPath;
      },
      onIOS: () async {
        final docFileDir = await getApplicationDocumentsDirectory();
        return '${docFileDir.path}/$editedPath';
      },
      noneOfThem: () async {
        return editedPath;
      },
    );
  }

  Future<String> saveFile(SignableFile signableFile) async {
    if (!signableFile.hasData()) {
      throw Exception('SignableFile has no data $signableFile');
    }

    final destinationPath = await _createDestinationPath(signableFile.filePath!, signableFile.signableFileExtension!.name);
    final savedFile = await File(destinationPath).writeAsBytes(signableFile.bytes!);
    return savedFile.path;
  }

  Future<AppPdfDocument> readPdfDocument(String path, Size targetPageSize) async {
    final pdfFileBytes = await File(path).readAsBytes();
    final originalPdfDoc = PdfDocument(inputBytes: pdfFileBytes);
    final signablePdfDoc = PdfDocument();
    final pageCount = originalPdfDoc.pages.count;

    if (originalPdfDoc.pages.count == 0) {
      throw Exception('Invalid pdf file');
    }

    signablePdfDoc.pageSettings.setMargins(0);
    signablePdfDoc.pageSettings.size = targetPageSize;

    for (var i = 0; i < pageCount; i++) {
      final originalPage = originalPdfDoc.pages[i];

      final pdfTemplate = originalPage.createTemplate();
      final page = signablePdfDoc.pages.add();

      final scaleX = targetPageSize.width / originalPage.size.width;
      final scaleY = targetPageSize.height / originalPage.size.height;
      final scale = scaleX < scaleY ? scaleX : scaleY;
      page.graphics.drawPdfTemplate(pdfTemplate, Offset.zero, Size(originalPage.size.width * scale, originalPage.size.height * scale));
    }

    return AppPdfDocument(
      pdfDocument: signablePdfDoc,
      path: path,
      sourcePdfPageize: originalPdfDoc.pageSettings.size,
      totalPage: pageCount,
      pageSize: signablePdfDoc.pageSettings.size,
      widgetSize: targetPageSize,
      signedPageIndex: 0,
      pages: signablePdfDoc.pages,
    );
  }

  Future<Size> getPdfSize(String path) async {
    final pdfFileBytes = await File(path).readAsBytes();
    final originalPdfDoc = PdfDocument(inputBytes: pdfFileBytes);
    return originalPdfDoc.pages.count == 0 ? Size.zero : originalPdfDoc.pages[0].size;
  }

  Future<void> drawImageOverPdf({
    required AppPdfDocument pdfDocument,
    required Uint8List imageByte,
    required Size imageSize,
    required Offset imageOffset,
    required Size pdfDocSize,
    required Size pdfWidgetSize,
  }) async {
    final scaleX = (pdfDocSize.width) / (pdfWidgetSize.width);
    final scaleY = (pdfDocSize.height) / (pdfWidgetSize.height);

    final pdfX = (imageOffset.dx) * scaleX;
    final pdfY = (imageOffset.dy) * scaleY - imageSize.height / 2;

    final allPages = pdfDocument.pages;
    final drawingPage = allPages[pdfDocument.currentPageIndex];

    drawingPage.graphics.drawImage(
      PdfBitmap(imageByte),
      Rect.fromLTWH(pdfX, pdfY, imageSize.width, imageSize.height),
    );
  }
}
