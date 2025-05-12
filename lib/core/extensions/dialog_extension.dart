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
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

extension DialogExtension on BuildContext {
  Future<void> showFilePickerDialog(
    Function(FilePickerResult?) onFilesPicked,
  ) async {
    return showDialog(
      context: this,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.select_files_title_dialog),
          content: Text(
            AppLocalizations.of(context)!.select_files_content_dialog,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                context.showFilePickerWithTypeFileDialog(onFilesPicked);
              },
              child: Text(
                AppLocalizations.of(context)!.select_from_device_button,
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                List<PlatformFile>? scannedDocument = await scanDocument();
                if (scannedDocument != null) {
                  FilePickerResult result = FilePickerResult(scannedDocument);
                  onFilesPicked(result);
                }
              },
              child: Text(
                AppLocalizations.of(context)!.select_from_scanner_button,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel_button),
            ),
          ],
        );
      },
    );
  }

  Future<void> showFilePickerWithTypeFileDialog(
    Function(FilePickerResult?) onFilesPicked,
  ) async {
    return showDialog(
      context: this,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.select_file_type_title_dialog,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: true,
                );
                onFilesPicked(result);
              },
              child: Text(AppLocalizations.of(context)!.images_button),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                  allowMultiple: true,
                );
                onFilesPicked(result);
              },
              child: Text(AppLocalizations.of(context)!.documents_button),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel_button),
            ),
          ],
        );
      },
    );
  }

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
}
