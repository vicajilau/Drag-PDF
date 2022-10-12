enum SupportedFileType { pdf, png, jpg, unknown }

extension SupportedFileTypeExtension on SupportedFileType {
  String getIconPath() {
    String path = "assets/images/files/";
    switch (this) {
      case SupportedFileType.pdf:
        return "${path}pdf_file.png";
      case SupportedFileType.png:
        return "${path}png_file.png";
      case SupportedFileType.jpg:
        return "${path}jpg_file.png";
      case SupportedFileType.unknown:
        return "${path}doc_file.png";
    }
  }

  static SupportedFileType fromString(String text) =>
      SupportedFileType.values.firstWhere((element) => element.name == text);
}
