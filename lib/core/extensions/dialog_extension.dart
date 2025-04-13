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
