
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';

class ScanDocument {
  Future<List<PlatformFile>?> scanDocument() async {
    final scannedImage = await CunningDocumentScanner.getPictures();

    if (scannedImage != null) {
      return scannedImage
          .map(
            (element) => PlatformFile(
          path: element,
          name: element.split('/').last,
          size: File(element).lengthSync(),
        ),
      )
          .toList();
    }
    return null;
  }
  Future<void> scanDocumentProcess(Function(FilePickerResult?) onFilesPicked) async {
    List<PlatformFile>? scannedDocument = await scanDocument();
    if (scannedDocument != null) {
      FilePickerResult result = FilePickerResult(scannedDocument);
      return onFilesPicked(result);
    }
  }

}