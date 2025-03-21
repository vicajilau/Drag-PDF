import 'package:drag_pdf/helper/helpers.dart';
import 'package:drag_pdf/model/models.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../common/service_locator.dart';

class Utils {
  static const nameOfFinalFile = 'Generated by DragPDF.pdf';

  static void printInDebug(Object? object) {
    if (kDebugMode) {
      print(object);
    }
  }

  static bool thereIsSignatureStored() {
    return false;
  }

  static String printableSizeOfFile(int size) {
    if (size / 1000000000 > 1) {
      // GB
      double result = size / 1000000000;
      return "${result.toStringAsFixed(2)} GB";
    } else if (size / 1000000 > 1) {
      // MB
      double result = size / 1000000;
      return "${result.toStringAsFixed(2)} MB";
    } else if (size / 1000 > 1) {
      // KB
      double result = size / 1000;
      return "${result.toStringAsFixed(2)} KB";
    }
    return 0.toString();
  }

  static bool isImage(FileRead file) {
    switch (file.getExtensionType()) {
      case SupportedFileType.pdf:
        return false;
      case SupportedFileType.png:
        return true;
      case SupportedFileType.jpg:
        return true;
      case SupportedFileType.jpeg:
        return true;
    }
  }

  static bool isPdf(FileRead file) =>
      file.getExtensionType() == SupportedFileType.pdf;

  static int getHeightOfImageFile(FileRead fileRead) {
    final image = AppSession.singleton.fileHelper.getImageOfImageFile(fileRead);
    return image?.height ?? 0;
  }

  static int getWidthOfImageFile(FileRead fileRead) {
    final image = AppSession.singleton.fileHelper.getImageOfImageFile(fileRead);
    return image?.width ?? 0;
  }

  static bool isFinalFile(FileRead file) =>
      Utils.nameOfFinalFile.contains(file.getName());

  static void openFileProperly(BuildContext context, FileRead file) {
    switch (file.getExtensionType()) {
      case SupportedFileType.pdf:
        Utils.printInDebug("Opened PDF file: ${file.getFile().path}");
        ServiceLocator.instance.registerFile(file);
        isFinalFile(file)
            ? context.push("/preview_document_screen")
            : context.push("/pdf_viewer_screen");
        break;
      case SupportedFileType.png:
        _openImage(context, file);
        break;
      case SupportedFileType.jpg:
        _openImage(context, file);
        break;
      case SupportedFileType.jpeg:
        _openImage(context, file);
        break;
    }
  }

  static void _openImage(BuildContext context, FileRead file) {
    final imageProvider = Image.file(
      file.getFile(),
    ).image;
    showImageViewer(context, imageProvider, doubleTapZoomable: true,
        onViewerDismissed: () {
      Utils.printInDebug("Dismissed Image: ${file.getFile().path}");
    });
  }
}
