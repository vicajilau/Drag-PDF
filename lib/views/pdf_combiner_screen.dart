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
import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:drag_pdf/core/extensions/uint8list_extension.dart';
import 'package:drag_pdf/views/widgets/expandable/action_button.dart';
import 'package:drag_pdf/views/widgets/expandable/expandable_fab.dart';
import 'package:drag_pdf/views/widgets/file_type_icon.dart';
import 'package:file_magic_number/file_magic_number.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:pdf_combiner/pdf_combiner_delegate.dart';
import 'package:platform_detail/platform_detail.dart';

import '../core/l10n/app_localizations.dart';
import '../document_utils/scan_document.dart';
import '../view_models/pdf_combiner_view_model.dart';
import 'components/loading.dart';

class PdfCombinerScreen extends StatefulWidget {
  const PdfCombinerScreen({super.key});

  @override
  State<PdfCombinerScreen> createState() => _PdfCombinerScreenState();
}

class _PdfCombinerScreenState extends State<PdfCombinerScreen> {
  final PdfCombinerViewModel _viewModel = PdfCombinerViewModel();
  bool _pickingFiles = false;
  double _progress = 0.0;
  late PdfCombinerDelegate delegate;
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  final ScanDocument scanDocument = ScanDocument();

  @override
  void initState() {
    super.initState();
    initDelegate();
  }

  void _handleTapOutside() {
    _fabKey.currentState?.close();
  }

  void initDelegate() {
    delegate = PdfCombinerDelegate(
      onProgress: (updatedValue) {
        setState(() {
          _progress = updatedValue;
        });
      },
      onError: (error) {
         printToConsole('hay un error en el proceso de combinado de archivos: $error');
        _showSnackbarSafely(error.toString());
      },
      onSuccess: (paths) {
        setState(() {
          printToConsole('El proceso de combinado fue exitoso con estas paths: $paths');
          _viewModel.outputFiles = paths;
        });
        String message = AppLocalizations.of(
          context,
        )!.success_snackbar_single_file(paths.first);
        if (paths.length > 1) {
          message = AppLocalizations.of(
            context,
          )!.success_snackbar_multiple_files(paths.length);
        }
        _showSnackbarSafely(message);
      },
    );
  }

  bool isLoading() => _progress != 0.0 && _progress != 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTapOutside,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.titleAppBar),
          actions: [
            IconButton(
              onPressed:
                  _viewModel.selectedFiles.isEmpty || _pickingFiles
                      ? null
                      : _restart,
              icon: const Icon(Icons.restart_alt),
              tooltip: AppLocalizations.of(context)!.restart_app_tooltip,
            ),
          ],
        ),
        body: SafeArea(
          child:
              isLoading()
                  ? const LoadingScreen()
                  : DropTarget(
                    onDragDone: (details) {
                      setState(() {
                        _viewModel.addFilesDragAndDrop(details.files);
                      });
                    },
                    child:
                        (_viewModel.isEmpty())
                            ? Center(
                              child: Image.asset('assets/files/home.png'),
                            )
                            : Column(
                              spacing: 20,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (_viewModel.outputFiles.isNotEmpty) ...[
                                  // HERE IS THE OUTPUT SECTION
                                  const SizedBox(),
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    )!.output_files_title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  getOutputhFiles(),
                                  const Divider(),
                                ],
                                // HERE IS THE INPUT SECTION
                                const SizedBox(),
                                Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.input_files_title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                getInputFiles(),
                                // Buttons Section
                                getBottomBarOptions(),
                                const SizedBox(height: 20),
                              ],
                            ),
                  ),
        ),
        floatingActionButton: getFloatButton(),
      ),
    );
  }

  /// Calculates the flex size for the input files.
  ///
  /// This function determines the appropriate size or layout parameters for the input files
  /// based on the available space, ensuring they are displayed correctly in a flexible layout.
  ///
  /// @return Integer value representing the flex size for the input files.
  int calculateFlexInputFiles() =>
      _viewModel.outputFiles.isEmpty ||
              _viewModel.selectedFiles.length <= _viewModel.outputFiles.length
          ? 1
          : 2;

  /// Calculates the flex size for the output files.
  ///
  /// This function determines the appropriate size or layout parameters for the output files
  /// based on the available space, ensuring they are displayed correctly in a flexible layout.
  ///
  /// @return Integer value representing the flex size for the output files.
  int calculateFlexOutputFiles() =>
      _viewModel.outputFiles.length <= _viewModel.selectedFiles.length ? 1 : 2;

  /// Generates the output file resulting from the combination of the input files.
  ///
  /// This function takes the selected input files, processes their content,
  /// and creates a new file that merges or transforms them according to the application's logic.
  ///
  /// @return A widget with the combination of input files into one output file
  Widget getOutputhFiles() {
    return Expanded(
      flex: calculateFlexOutputFiles(),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _viewModel.outputFiles.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: FileTypeIcon(filePath: _viewModel.outputFiles[index]),
              title: Text(
                p.basename(_viewModel.outputFiles[index]),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _openOutputFile(index),
              subtitle: FutureBuilder(
                future: FileMagicNumber.getBytesFromPathOrBlob(
                  _viewModel.outputFiles[index],
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      AppLocalizations.of(context)!.loading_size_message,
                    );
                  } else if (snapshot.hasError) {
                    return const Icon(Icons.error);
                  } else {
                    return Text(
                      snapshot.data?.size() ??
                          AppLocalizations.of(context)!.unknown_size_message,
                    );
                  }
                },
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyOutputToClipboard(index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getFloatButton() {
    if (PlatformDetail.isMobile) {
      FilePickerResult? result;
      return ExpandableFab(
        key: _fabKey,
        distance: 100,
        children: [
          Tooltip(
            message: AppLocalizations.of(context)!.select_from_gallery_button,
            child: ActionButton(
              onPressed:
                  () async => {_fabKey.currentState?.close(), _pickFiles()},
              icon: const Icon(Icons.image),
            ),
          ),
          Tooltip(
            message: AppLocalizations.of(context)!.select_from_device_button,
            child: ActionButton(
              onPressed:
                  () async => {
                    _fabKey.currentState?.close(),
                    result = await FilePicker.platform.pickFiles(
                      type: FileType.any,
                      allowMultiple: true,
                    ),
                    _prepareFiles(result: result),
                  },
              icon: const Icon(Icons.insert_drive_file),
            ),
          ),
          Tooltip(
            message: AppLocalizations.of(context)!.select_from_scanner_button,
            child: ActionButton(
              onPressed:
                  () async => {
                    _fabKey.currentState?.close(),
                    scanDocument.scanDocumentCamera((FilePickerResult? result) {
                      if (result != null) {
                        _pickFiles(result: result);
                      } else {
                        _pickFiles();
                      }
                    }),
                  },
              icon: const Icon(Icons.document_scanner),
            ),
          ),
        ],
      );
    } else {
      return FloatingActionButton(
        onPressed: () => _pickingFiles ? null : _pickFiles(),
        tooltip: AppLocalizations.of(context)!.add_new_files_tooltip,
        child: const Icon(Icons.add),
      );
    }
  }

  /// Prepares the files selected by the user using File Picker.
  ///
  /// This function processes the list of files obtained from the file picker,
  /// validates their existence, and converts them into a suitable format for further use.
  ///
  /// @return A widget with a list of the selected files
  Widget getInputFiles() {
    return Expanded(
      flex: calculateFlexInputFiles(),
      child: ReorderableListView.builder(
        itemCount: _viewModel.selectedFiles.length,
        onReorder: _onReorderFiles,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(_viewModel.selectedFiles[index]),
            direction: DismissDirection.horizontal,
            onDismissed: (direction) {
              final path = p.basename(_viewModel.selectedFiles[index]);
              setState(() {
                _viewModel.removeFileAt(index);
              });
              _showSnackbarSafely(
                AppLocalizations.of(context)!.file_removed_message(path),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: FileTypeIcon(
                  filePath: _viewModel.selectedFiles[index],
                ),
                title: Text(
                  p.basename(_viewModel.selectedFiles[index]),
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () async => await _openInputFile(index),
                subtitle: FutureBuilder(
                  future: FileMagicNumber.getBytesFromPathOrBlob(
                    _viewModel.selectedFiles[index],
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        AppLocalizations.of(context)!.loading_size_message,
                      );
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error);
                    } else {
                      return Text(
                        snapshot.data?.size() ??
                            AppLocalizations.of(context)!.unknown_size_message,
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Creates a bottom bar with buttons that perform actions on the input files.
  ///
  /// This function returns a widget representing a bottom bar,
  /// where each button triggers a specific action related to the input files,
  /// such as processing, validating, or modifying them.
  ///
  /// @return A `Widget` representing the bottom bar with action buttons for input files.
  Widget getBottomBarOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [
          const SizedBox(),
          _viewModel.isNotSinglePdfLoaded()
              ? ElevatedButton(
                onPressed: _createPdfFromMix,
                child: Text(AppLocalizations.of(context)!.create_pdf_button),
              )
              : ElevatedButton(
                onPressed: _createImagesFromPDF,
                child: Text(
                  AppLocalizations.of(context)!.create_images_from_pdf_button,
                ),
              ),

          const SizedBox(),
        ],
      ),
    );
  }

  /// Allows the user to select a file or scan an image using the camera (on mobile devices).
  ///
  /// This function opens a file picker dialog with 2 options if the device is mobile,
  /// provides the option to scan an image using the camera or another to pick a file.
  ///
  /// @return Void
  Future<void> _pickFiles({FilePickerResult? result}) async {
    setState(() {
      _pickingFiles = true;
    });
    await _viewModel.pickImages(result);
    setState(() {
      _pickingFiles = false;
    });
  }

  Future<void> _prepareFiles({FilePickerResult? result}) async {
    await _viewModel.prepareFiles(result);
    setState(() {});
  }

  /// Resets the input and output files.
  ///
  /// This function clears any previously selected input files and output files,
  /// returning the application to its initial state, ready for new file selection and processing.
  ///
  /// @return Void
  void _restart() {
    _viewModel.restart();
    setState(() {
      _progress = 0.0;
      _pickingFiles = false;
    });
    _showSnackbarSafely(AppLocalizations.of(context)!.snackbar_app_restart);
  }

  /// Creates a PDF from a mixed set of input files.
  ///
  /// This function processes a combination of various input file types (e.g., text, images, or PDFs)
  /// and generates a new PDF document containing the combined content.
  ///
  /// @return Void
  Future<void> _createPdfFromMix() async {
    await _viewModel.createPDFFromDocuments(delegate);
  }

  /// Extracts images from a PDF and saves them as separate image files.
  ///
  /// This function processes a PDF file, extracts each page as an image,
  /// and saves the images to the specified output location for further use.
  ///
  /// @return Void
  Future<void> _createImagesFromPDF() async {
    await _viewModel.createImagesFromPDF(delegate);
  }

  /// Copies the output data to the clipboard.
  ///
  /// This function takes the generated output (e.g., file paths, text, or results)
  /// and copies it to the clipboard, making it available for pasting into other applications.
  ///
  /// @return Void
  Future<void> _copyOutputToClipboard(int index) async {
    await _viewModel.copyOutputToClipboard(index);
    if (!mounted) return;
    _showSnackbarSafely(
      AppLocalizations.of(context)!.snackbar_copy_output_to_clipboard,
    );
  }

  /// Opens the output file for viewing or further processing.
  ///
  /// This function opens the generated output file (e.g., a PDF, image, or text file)
  /// using the appropriate application on the device, allowing the user to view or interact with it.
  ///
  /// @return Void
  Future<void> _openOutputFile(int index) async {
    if (index < _viewModel.outputFiles.length) {
      final result = await OpenFile.open(_viewModel.outputFiles[index]);
      if (mounted && result.type != ResultType.done) {
        _showSnackbarSafely(
          AppLocalizations.of(context)!.failed_open_file(result.message),
        );
      }
    }
  }

  /// Opens the selected input file for viewing or editing.
  ///
  /// This function opens the specified input file (e.g., a document, image, or text file)
  /// using the appropriate application on the device, allowing the user to view or make changes to it.
  ///
  /// @return Void
  Future<void> _openInputFile(int index) async {
    if (index < _viewModel.selectedFiles.length) {
      final result = await OpenFile.open(_viewModel.selectedFiles[index]);
      if (mounted && result.type != ResultType.done) {
        _showSnackbarSafely(
          AppLocalizations.of(context)!.failed_open_file(result.message),
        );
      }
    }
  }

  /// Handles the reordering of files in the list.
  ///
  /// This function allows the user to reorder the selected files, updating their sequence
  /// as per the new order. The file list is then refreshed to reflect the changes.
  ///
  /// @return Void
  void _onReorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final file = _viewModel.selectedFiles.removeAt(oldIndex);
      _viewModel.selectedFiles.insert(newIndex, file);
    });
  }

  /// Displays a snackbar message safely on the screen.
  ///
  /// This function shows a snackbar with a given message, ensuring that it is displayed correctly
  /// even if the app is in a transient state, such as during navigation or while other UI elements are active.
  ///
  /// @return Void
  void _showSnackbarSafely(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
