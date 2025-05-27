/*
Copyright 2022-2025 Victor Carreras

This file is part of Drag-PDF.

Drag-PDF is free software: you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any
later version.

Drag-PDF is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General
Public License along with Drag-PDF. If not, see
<https://www.gnu.org/licenses/>.
*/
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';

class ScanDocument {
  /// Launches the device’s camera to allow the user to capture an image of a document.
  /// This handles permission requests and initiates the camera interface.
  Future<List<PlatformFile>?> scanDocumentProcess() async {
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

  /// Processes the image captured from the camera, optimizing it for use as a document
  Future<void> scanDocumentCamera(
    Function(FilePickerResult?) onFilesPicked,
  ) async {
    List<PlatformFile>? scannedDocument = await scanDocumentProcess();
    if (scannedDocument != null) {
      FilePickerResult result = FilePickerResult(scannedDocument);
      return onFilesPicked(result);
    }
  }
}
