/*
Copyright 2022-2026 Victor Carreras

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
import 'package:pdf_combiner/models/merge_input.dart';
import 'package:pdf_combiner/pdf_combiner.dart';
import 'package:platform_detail/platform_detail.dart';

class PdfCombinerViewModel extends ChangeNotifier {
  final List<String> _selectedFiles =
      []; // List to store selected PDF file paths
  final List<String> _outputFiles = []; // Path for the combined output file

  List<String> get selectedFiles => List.unmodifiable(_selectedFiles);
  List<String> get outputFiles => List.unmodifiable(_outputFiles);

  /// Allows the user to pick multiple image files and processes them.
  ///
  /// If a [result] is not provided, this function launches the file picker
  /// to let the user select multiple image files. If a [result] is provided,
  /// it is used directly.
  ///
  /// After picking or receiving the files, their names are printed to the
  /// debug console. Then, the files are passed to [prepareFiles] for further processing.
  ///
  /// - Parameter [result]: Optional [FilePickerResult]. If `null`, the file picker will be shown.
  ///
  /// - Returns: A [Future] that completes when image selection and processing are done.
  Future<void> pickImages(FilePickerResult? result) async {
    result ??= await FilePicker.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      for (var element in result.files) {
        debugPrint("${element.name}, ");
      }
      await prepareFiles(result);
    }
  }

  /// Prepares a list of files from the result of a file picker operation.
  ///
  /// This function processes a [FilePickerResult] by filtering out entries
  /// that don't have a valid file path (`file.path != null`), converting the
  /// valid ones into [File] objects, and passing them to the [_addFiles]
  /// method for further handling.
  ///
  /// If [result] is `null` or contains no valid file paths, the function
  /// does nothing.
  ///
  /// - Parameter [result]: The result returned from a file picker. May be `null`.
  ///
  /// - Returns: A [Future] that completes when file preparation is finished.
  Future<void> prepareFiles(FilePickerResult? result) async {
    final files =
        result?.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
    if (files != null) {
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
    _selectedFiles.addAll(files.map((file) => file.path));
    _outputFiles.clear();
    notifyListeners();
  }

  /// Checks if the collection is empty.
  ///
  /// This function verifies whether the collection (e.g., list, set, or map) contains any elements.
  /// It returns `true` if the collection is empty, and `false` otherwise.
  ///
  /// @return `true` if the collection is empty, `false` otherwise.
  bool isEmpty() => _selectedFiles.isEmpty;

  /// Pick PDF files from the device
  void _addFiles(List<File> files) {
    _selectedFiles.addAll(files.map((file) => file.path));
    _outputFiles.clear();
    notifyListeners();
  }

  /// Restart the selected files
  void restart() {
    _selectedFiles.clear();
    _outputFiles.clear();
    notifyListeners();
  }

  /// Combine selected PDF files into a single output file
  Future<String> combinePdfs() async {
    final directory = await _getOutputDirectory();
    String outputFilePath = '${directory?.path}/combined_output.pdf';

    final result = await PdfCombiner.mergeMultiplePDFs(
      inputs: _selectedFiles.map((path) => MergeInput.path(path)).toList(),
      outputPath: outputFilePath,
    ); // Combine the PDFs

    _outputFiles.clear();
    _outputFiles.add(result);
    notifyListeners();
    return result;
  }

  /// Create a PDF file from a list of images
  Future<String> createPDFFromImages() async {
    final directory = await _getOutputDirectory();
    String outputFilePath = '${directory?.path}/combined_output.pdf';
    final result = await PdfCombiner.createPDFFromMultipleImages(
      inputs: _selectedFiles.map((path) => MergeInput.path(path)).toList(),
      outputPath: outputFilePath,
    );

    _outputFiles.clear();
    _outputFiles.add(result);
    notifyListeners();
    return result;
  }

  /// Create a PDF file from a list of documents
  Future<String> createPDFFromDocuments() async {
    final directory = await _getOutputDirectory();
    String outputFilePath = '${directory?.path}/combined_output.pdf';
    final result = await PdfCombiner.generatePDFFromDocuments(
      inputs: _selectedFiles.map((path) => MergeInput.path(path)).toList(),
      outputPath: outputFilePath,
    );

    _outputFiles.clear();
    _outputFiles.add(result);
    notifyListeners();
    return result;
  }

  /// Create a PDF file from a list of images
  Future<List<String>> createImagesFromPDF() async {
    final directory = await _getOutputDirectory();
    final outputFilePath = '${directory?.path}';
    final results = await PdfCombiner.createImageFromPDF(
      input: MergeInput.path(_selectedFiles.first),
      outputDirPath: outputFilePath,
    );

    _outputFiles.clear();
    _outputFiles.addAll(results);
    notifyListeners();
    return results;
  }

  /// Get the appropriate directory for saving the output file
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

  /// Copy the output file path to the clipboard
  Future<void> copyOutputToClipboard(int index) async {
    if (_outputFiles.isNotEmpty) {
      await Clipboard.setData(
        ClipboardData(text: _outputFiles[index]),
      ); // Copy output path to clipboard
    }
  }

  /// Copy the selected files' paths to the clipboard
  Future<void> copySelectedFilesToClipboard(int index) async {
    if (_selectedFiles.isNotEmpty) {
      await Clipboard.setData(
        ClipboardData(text: _selectedFiles[index]),
      ); // Copy selected files to clipboard
    }
  }

  /// Removes the selected files
  void removeFileAt(int index) {
    _selectedFiles.removeAt(index);
    notifyListeners();
  }

  /// Reorder the selected files list
  void reorderFiles(int oldIndex, int newIndex) {
    final file = _selectedFiles.removeAt(oldIndex);
    _selectedFiles.insert(newIndex, file);
    notifyListeners();
  }

  /// Detects if the selected files are not a single PDF file
  bool isNotSinglePdfLoaded() =>
      _selectedFiles.length != 1 || !_selectedFiles.first.endsWith('.pdf');
}
