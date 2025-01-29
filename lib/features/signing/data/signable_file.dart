import 'dart:typed_data';
import 'dart:ui';

class SignableFile {
  SignableFile({
    this.bytes,
    this.filePath,
    this.defaultSize,
    this.signableFileExtension,
  });
  final Uint8List? bytes;
  final Size? defaultSize;
  final String? filePath;
  final SignableFileExtension? signableFileExtension;

  bool hasData() => bytes != null && filePath != null && signableFileExtension != null;

  SignableFile copyWith({
    Uint8List? bytes,
    String? filePath,
    Size? defaultSize,
    SignableFileExtension? signableFileExtension,
  }) {
    return SignableFile(
      bytes: bytes ?? this.bytes,
      filePath: filePath ?? this.filePath,
      defaultSize: defaultSize ?? this.defaultSize,
      signableFileExtension: signableFileExtension ?? this.signableFileExtension,
    );
  }
}

enum SignableFileExtension {
  png,
  jpg,
  pdf;

  static SignableFileExtension? fromString(String ext) {
    switch (ext) {
      case 'png':
        return SignableFileExtension.png;
      case 'jpg':
        return SignableFileExtension.jpg;
      case 'pdf':
        return SignableFileExtension.pdf;
      default:
        return null;
    }
  }
}
