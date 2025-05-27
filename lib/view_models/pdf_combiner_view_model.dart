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

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:pdf_combiner/pdf_combiner_delegate.dart';
import 'package:platform_detail/platform_detail.dart';

class PdfCombinerViewModel {
  List<String> selectedFiles = []; // List to store selected PDF file paths
  List<String> outputFiles = []; // Path for the combined output file

  /// Function to pick PDF files from the device (old method)
  Future<void> pickFiles(FilePickerResult? result) async {
    result ??= await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
      allowMultiple: true, // Allow picking multiple files
    );
    if (result != null && result.files.isNotEmpty) {
      for (var element in result.files) {
        debugPrint("${element.name}, ");
      }
      final files =
          result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!))
              .toList();
      _addFiles(files);
    }
  }

  /// Function to pick images from the device
  Future<void> pickImages(FilePickerResult? result) async {
    result ??= await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // Allow picking multiple files
    );
    if (result != null && result.files.isNotEmpty) {
      for (var element in result.files) {
        debugPrint("${element.name}, ");
      }
      final files =
          result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!))
              .toList();
      _addFiles(files);
    }
  }

  /// drag-and-drop functionality for adding files.
  ///
  /// This function allows users to drag files into the designated area,
  /// automatically adding them to the selected file list for further processing.
  ///
  /// @return Void
  Future<void> addFilesDragAndDrop(List<DropItem> files) async {
    selectedFiles += files.map((file) => file.path).toList();
    outputFiles = [];
  }

  /// Checks if the collection is empty.
  ///
  /// This function verifies whether the collection (e.g., list, set, or map) contains any elements.
  /// It returns `true` if the collection is empty, and `false` otherwise.
  ///
  /// @return `true` if the collection is empty, `false` otherwise.
  bool isEmpty() => selectedFiles.isEmpty;

  /// Function to pick PDF files from the device
  Future<void> _addFiles(List<File> files) async {
    selectedFiles += files.map((file) => file.path).toList();
    outputFiles = [];
  }

  /// Function to restart the selected files
  void restart() {
    selectedFiles = [];
    outputFiles = [];
  }

  /// Function to combine selected PDF files into a single output file
  Future<void> combinePdfs(PdfCombinerDelegate delegate) async {
    final directory = await _getOutputDirectory();
    String outputFilePath = '${directory?.path}/combined_output.pdf';

    await PdfCombiner.mergeMultiplePDFs(
      inputPaths: selectedFiles,
      outputPath: outputFilePath,
      delegate: delegate,
    ); // Combine the PDFs
  }

  /// Function to create a PDF file from a list of images
  Future<void> createPDFFromImages(PdfCombinerDelegate delegate) async {
    final directory = await _getOutputDirectory();
    String outputFilePath = '${directory?.path}/combined_output.pdf';
    await PdfCombiner.createPDFFromMultipleImages(
      inputPaths: selectedFiles,
      outputPath: outputFilePath,
      delegate: delegate,
    );
  }

  /// Function to create a PDF file from a list of documents
  Future<void> createPDFFromDocuments(PdfCombinerDelegate delegate) async {
    final directory = await _getOutputDirectory();
    String outputFilePath = '${directory?.path}/combined_output.pdf';
    await PdfCombiner.generatePDFFromDocuments(
      inputPaths: selectedFiles,
      outputPath: outputFilePath,
      delegate: delegate,
    );
  }

  /// Function to create a PDF file from a list of images
  Future<void> createImagesFromPDF(PdfCombinerDelegate delegate) async {
    final directory = await _getOutputDirectory();
    final outputFilePath = '${directory?.path}';
    await PdfCombiner.createImageFromPDF(
      inputPath: selectedFiles.first,
      outputDirPath: outputFilePath,
      delegate: delegate,
    );
  }

  /// Function to get the appropriate directory for saving the output file
  Future<Directory?> _getOutputDirectory() async {
    if (PlatformDetail.isIOS || PlatformDetail.isDesktop) {
      return await getApplicationDocumentsDirectory(); // For iOS & Desktop, return the documents directory
    } else if (PlatformDetail.isAndroid) {
      return await getDownloadsDirectory(); // For Android, return the Downloads directory
    } else if (PlatformDetail.isWeb) {
      return null;
    } else {
      throw UnsupportedError(
        '_getOutputDirectory() in unsupported platform.',
      ); // Throw an error if the platform is unsupported
    }
  }

  /// Function to copy the output file path to the clipboard
  Future<void> copyOutputToClipboard(int index) async {
    if (outputFiles.isNotEmpty) {
      await Clipboard.setData(
        ClipboardData(text: outputFiles[index]),
      ); // Copy output path to clipboard
    }
  }

  /// Function to copy the selected files' paths to the clipboard
  Future<void> copySelectedFilesToClipboard(int index) async {
    if (selectedFiles.isNotEmpty) {
      await Clipboard.setData(
        ClipboardData(text: selectedFiles[index]),
      ); // Copy selected files to clipboard
    }
  }

  /// Function to remove the selected files
  void removeFileAt(int index) {
    selectedFiles.removeAt(index);
  }
}
