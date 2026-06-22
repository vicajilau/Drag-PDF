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
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:drag_pdf/views/widgets/expandable/action_button.dart';
import 'package:drag_pdf/views/widgets/expandable/expandable_fab.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:platform_detail/platform_detail.dart';

import '../core/l10n/app_localizations.dart';
import '../document_utils/scan_document.dart';
import '../view_models/pdf_combiner_view_model.dart';
import 'components/desktop/desktop_layout.dart';
import 'components/loading.dart';
import 'components/mobile/mobile_layout.dart';

class PdfCombinerScreen extends StatefulWidget {
  const PdfCombinerScreen({super.key});

  @override
  State<PdfCombinerScreen> createState() => _PdfCombinerScreenState();
}

class _PdfCombinerScreenState extends State<PdfCombinerScreen> {
  final PdfCombinerViewModel _viewModel = PdfCombinerViewModel();
  bool _pickingFiles = false;
  double _progress = 0.0;
  bool _isDragging = false;
  final GlobalKey<ExpandableFabState> _fabKey = GlobalKey<ExpandableFabState>();
  final ScanDocument scanDocument = ScanDocument();

  @override
  void initState() {
    super.initState();
  }

  void _handleTapOutside() {
    _fabKey.currentState?.close();
  }

  bool isLoading() => _progress != 0.0 && _progress != 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return GestureDetector(
          onTap: _handleTapOutside,
          behavior: HitTestBehavior.translucent,
          child: Scaffold(
            appBar:
                !PlatformDetail.isMobile || isDesktop
                    ? null
                    : AppBar(
                      title: Text(AppLocalizations.of(context).titleAppBar),
                      actions: [
                        IconButton(
                          onPressed:
                              _viewModel.selectedFiles.isEmpty || _pickingFiles
                                  ? null
                                  : _restart,
                          icon: const Icon(Icons.restart_alt),
                          tooltip:
                              AppLocalizations.of(context).restart_app_tooltip,
                        ),
                      ],
                    ),
            body: SafeArea(
              child:
                  isLoading()
                      ? const LoadingScreen()
                      : DropTarget(
                        onDragEntered:
                            (details) => setState(() => _isDragging = true),
                        onDragExited:
                            (details) => setState(() => _isDragging = false),
                        onDragDone: (details) {
                          setState(() {
                            _isDragging = false;
                          });
                          _viewModel.addFilesDragAndDrop(details.files);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          color:
                              _isDragging
                                  ? theme.primaryColor.withValues(alpha: 0.04)
                                  : Colors.transparent,
                          child:
                              isDesktop
                                  ? DesktopLayout(
                                    viewModel: _viewModel,
                                    isDragging: _isDragging,
                                    pickingFiles: _pickingFiles,
                                    onPickFiles: _pickAnyFiles,
                                    onRestart: _restart,
                                    onOpenInput: _openInputFile,
                                    onRemoveInput: (index) {
                                      final fileName = p.basename(
                                        _viewModel.selectedFiles[index],
                                      );
                                      _viewModel.removeFileAt(index);
                                      _showSnackbarSafely(
                                        AppLocalizations.of(
                                          context,
                                        ).file_removed_message(fileName),
                                      );
                                    },
                                    onReorder: _onReorderFiles,
                                    onOpenOutput: _openOutputFile,
                                    onCopyOutput: _copyOutputToClipboard,
                                    onSaveOutput: _saveOutputFile,
                                    onCreatePdf: _createPdfFromMix,
                                    onCreateImages: _createImagesFromPDF,
                                  )
                                  : MobileLayout(
                                    viewModel: _viewModel,
                                    isDragging: _isDragging,
                                    pickingFiles: _pickingFiles,
                                    onPickGallery: _pickFiles,
                                    onPickFiles: _pickAnyFiles,
                                    onPickScanner: () {
                                      scanDocument.scanDocumentCamera((
                                        FilePickerResult? result,
                                      ) {
                                        if (result != null) {
                                          _pickFiles(result: result);
                                        } else {
                                          _pickFiles();
                                        }
                                      });
                                    },
                                    onOpenInput: _openInputFile,
                                    onRemoveInput: (index) {
                                      final fileName = p.basename(
                                        _viewModel.selectedFiles[index],
                                      );
                                      _viewModel.removeFileAt(index);
                                      _showSnackbarSafely(
                                        AppLocalizations.of(
                                          context,
                                        ).file_removed_message(fileName),
                                      );
                                    },
                                    onReorder: _onReorderFiles,
                                    onOpenOutput: _openOutputFile,
                                    onCopyOutput: _copyOutputToClipboard,
                                    onSaveOutput: _saveOutputFile,
                                  ),
                        ),
                      ),
            ),
            bottomNavigationBar:
                !isDesktop && _viewModel.selectedFiles.isNotEmpty
                    ? getBottomBarOptions()
                    : null,
            floatingActionButton:
                !PlatformDetail.isMobile || isDesktop || _viewModel.isEmpty()
                    ? null
                    : getFloatButton(),
          ),
        );
      },
    );
  }

  Widget? getFloatButton() {
    if (_viewModel.outputFiles.isNotEmpty) {
      return null;
    }
    if (PlatformDetail.isMobile) {
      return ExpandableFab(
        key: _fabKey,
        distance: 100,
        children: [
          Tooltip(
            message: AppLocalizations.of(context).select_from_gallery_button,
            child: ActionButton(
              onPressed:
                  () async => {_fabKey.currentState?.close(), _pickFiles()},
              icon: const Icon(Icons.image),
            ),
          ),
          Tooltip(
            message: AppLocalizations.of(context).select_from_device_button,
            child: ActionButton(
              onPressed: () {
                _fabKey.currentState?.close();
                _pickAnyFiles();
              },
              icon: const Icon(Icons.insert_drive_file),
            ),
          ),
          Tooltip(
            message: AppLocalizations.of(context).select_from_scanner_button,
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
        onPressed: () => _pickingFiles ? null : _pickAnyFiles(),
        tooltip: AppLocalizations.of(context).add_new_files_tooltip,
        child: const Icon(Icons.add),
      );
    }
  }

  Widget getBottomBarOptions() {
    final isNotSinglePdf = _viewModel.isNotSinglePdfLoaded();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child:
                isNotSinglePdf
                    ? ElevatedButton.icon(
                      onPressed: _createPdfFromMix,
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: Text(
                        AppLocalizations.of(context).create_pdf_button,
                      ),
                    )
                    : OutlinedButton.icon(
                      onPressed: _createImagesFromPDF,
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        AppLocalizations.of(
                          context,
                        ).create_images_from_pdf_button,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFiles({FilePickerResult? result}) async {
    setState(() {
      _pickingFiles = true;
    });
    await _viewModel.pickImages(result);
    setState(() {
      _pickingFiles = false;
    });
  }

  Future<void> _pickAnyFiles() async {
    setState(() {
      _pickingFiles = true;
    });
    final result = await FilePicker.pickFiles(type: FileType.any);
    if (result != null) {
      await _viewModel.prepareFiles(result);
    }
    setState(() {
      _pickingFiles = false;
    });
  }

  Future<void> _saveOutputFile(int index) async {
    if (index < _viewModel.outputFiles.length) {
      final filePath = _viewModel.outputFiles[index];
      final fileName = p.basename(filePath);

      try {
        final file = XFile(filePath);
        final bytes = await file.readAsBytes();

        final outputPath = await FilePicker.saveFile(
          fileName: fileName,
          type: FileType.any,
          bytes: bytes,
        );

        if (outputPath != null && mounted) {
          _showSnackbarSafely(AppLocalizations.of(context).success_save_file);
        }
      } catch (e) {
        _showSnackbarSafely(e.toString());
      }
    }
  }

  void _restart() {
    _viewModel.restart();
    setState(() {
      _progress = 0.0;
      _pickingFiles = false;
      _isDragging = false;
    });
    _showSnackbarSafely(AppLocalizations.of(context).snackbar_app_restart);
  }

  Future<void> _createPdfFromMix() async {
    setState(() {
      _progress = 0.5;
    });
    try {
      final outputPath = await _viewModel.createPDFFromDocuments();
      setState(() {
        _progress = 1.0;
      });
      if (mounted) {
        final message = AppLocalizations.of(
          context,
        ).success_snackbar_single_file(outputPath);
        _showSnackbarSafely(message);
      }
    } catch (e) {
      setState(() {
        _progress = 0.0;
      });
      _showSnackbarSafely(e.toString());
    }
  }

  Future<void> _createImagesFromPDF() async {
    setState(() {
      _progress = 0.5;
    });
    try {
      final outputPaths = await _viewModel.createImagesFromPDF();
      setState(() {
        _progress = 1.0;
      });
      if (mounted) {
        String message = AppLocalizations.of(
          context,
        ).success_snackbar_single_file(outputPaths.first);
        if (outputPaths.length > 1) {
          message = AppLocalizations.of(
            context,
          ).success_snackbar_multiple_files(outputPaths.length);
        }
        _showSnackbarSafely(message);
      }
    } catch (e) {
      setState(() {
        _progress = 0.0;
      });
      _showSnackbarSafely(e.toString());
    }
  }

  Future<void> _copyOutputToClipboard(int index) async {
    await _viewModel.copyOutputToClipboard(index);
    if (!mounted) return;
    _showSnackbarSafely(
      AppLocalizations.of(context).snackbar_copy_output_to_clipboard,
    );
  }

  Future<void> _openOutputFile(int index) async {
    if (index < _viewModel.outputFiles.length) {
      final result = await OpenFile.open(_viewModel.outputFiles[index]);
      if (mounted && result.type != ResultType.done) {
        _showSnackbarSafely(
          AppLocalizations.of(context).failed_open_file(result.message),
        );
      }
    }
  }

  Future<void> _openInputFile(int index) async {
    if (index < _viewModel.selectedFiles.length) {
      final result = await OpenFile.open(_viewModel.selectedFiles[index]);
      if (mounted && result.type != ResultType.done) {
        _showSnackbarSafely(
          AppLocalizations.of(context).failed_open_file(result.message),
        );
      }
    }
  }

  void _onReorderFiles(int oldIndex, int newIndex) {
    _viewModel.reorderFiles(oldIndex, newIndex);
  }

  void _showSnackbarSafely(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
