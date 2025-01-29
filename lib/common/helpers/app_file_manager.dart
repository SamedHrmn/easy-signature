import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:downloadsfolder/downloadsfolder.dart';
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
    return FilePicker.platform.pickFiles(compressionQuality: 80, type: FileType.custom, allowedExtensions: ['jpg', 'png']);
  }

  String getFileExtFromPath(String path) => path.split('.').last;

  String getFileNameFromPath(String path) => path.substring(path.lastIndexOf('/') + 1);

  Future<String> _createDestinationPath(String originalPath, String ext, {String? fileName}) async {
    var editedPath = getFileNameFromPath(originalPath);

    switch (ext) {
      case 'pdf':
        editedPath = editedPath.replaceFirst(RegExp(r'\.pdf$', caseSensitive: false), fileName ?? '_signed.pdf');
      case 'png':
        editedPath = editedPath.replaceFirst(RegExp(r'\.png$', caseSensitive: false), fileName ?? '_signed.png');
      case 'jpg':
        editedPath = editedPath.replaceFirst(RegExp(r'\.jpg$', caseSensitive: false), fileName ?? '_signed.jpg');
    }

    final docDir = await getApplicationDocumentsDirectory();
    return '${docDir.path}/$editedPath';
  }

  Future<String?> saveByteDataToFile(Uint8List bytes, {String? fileName}) async {
    final formattedFileName = '${fileName ?? '${DateTime.now().millisecondsSinceEpoch}'}.png';

    final docDir = await getApplicationDocumentsDirectory();

    final fullPath = '${docDir.path}/$formattedFileName';

    final file = File(fullPath);
    await file.writeAsBytes(bytes);

    await copyFileIntoDownloads(
      destinationPath: fullPath,
      fileName: getFileNameFromPath(fullPath),
      ext: getFileExtFromPath(fullPath),
    );
    await file.delete();

    return file.path;
  }

  Future<String?> saveFile(SignableFile signableFile) async {
    if (!signableFile.hasData()) {
      throw Exception('SignableFile has no data $signableFile');
    }

    final destinationPath = await _createDestinationPath(signableFile.filePath!, signableFile.signableFileExtension!.name);
    final savedFile = File(destinationPath);
    await savedFile.writeAsBytes(signableFile.bytes!);

    final isSuccess = await copyFileIntoDownloads(
      destinationPath: savedFile.path,
      fileName: getFileNameFromPath(savedFile.path),
      ext: signableFile.signableFileExtension!.name,
    );

    await savedFile.delete();

    return isSuccess ? destinationPath : null;
  }

  Future<bool> copyFileIntoDownloads({
    required String destinationPath,
    required String fileName,
    required String ext,
  }) async {
    final isSuccess = (await copyFileIntoDownloadFolder(destinationPath, fileName, desiredExtension: ext)) ?? false;
    return isSuccess;
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
