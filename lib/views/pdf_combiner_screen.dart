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

  Color _getFileColor(String path) {
    final ext = p.extension(path).toLowerCase();
    if (ext == '.pdf') return const Color(0xFFEF4444); // Red for PDF
    if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
      return const Color(0xFF0EA5E9); // Sky/Teal for Images
    }
    if (ext == '.doc' || ext == '.docx') {
      return const Color(0xFF3B82F6); // Blue for Word Docs
    }
    return const Color(0xFF64748B); // Slate/Grey for others
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        return GestureDetector(
          onTap: _handleTapOutside,
          behavior: HitTestBehavior.translucent,
          child: Scaffold(
            appBar: AppBar(
              title: Text(AppLocalizations.of(context).titleAppBar),
              actions: [
                IconButton(
                  onPressed:
                      _viewModel.selectedFiles.isEmpty || _pickingFiles
                          ? null
                          : _restart,
                  icon: const Icon(Icons.restart_alt),
                  tooltip: AppLocalizations.of(context).restart_app_tooltip,
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
                              (_viewModel.isEmpty())
                                  ? _buildEmptyState()
                                  : _buildMainContent(),
                        ),
                      ),
            ),
            floatingActionButton: getFloatButton(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 380,
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    _isDragging
                        ? theme.primaryColor
                        : (isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFE2E8F0)),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      _isDragging
                          ? theme.primaryColor.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dynamic drag icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(_isDragging ? 26 : 20),
                  decoration: BoxDecoration(
                    color:
                        _isDragging
                            ? theme.primaryColor.withValues(alpha: 0.1)
                            : theme.primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isDragging
                        ? Icons.downloading_rounded
                        : Icons.drive_folder_upload_rounded,
                    size: 56,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _isDragging
                      ? "Drop files here!"
                      : AppLocalizations.of(context).select_files_title_dialog,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _isDragging
                      ? "Release to load your documents and images."
                      : "Drag and drop your PDFs, images, or documents here, or browse files on your device.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _pickFiles(),
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: Text(
                      AppLocalizations.of(context).select_from_device_button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Inputs)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    top: 20.0,
                    bottom: 8.0,
                  ),
                  child: Text(
                    AppLocalizations.of(context).input_files_title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                getInputFiles(),
              ],
            ),
          ),
          // Vertical divider
          const VerticalDivider(width: 1),
          // Right Column (Outputs & Actions)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_viewModel.outputFiles.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      top: 20.0,
                      bottom: 8.0,
                    ),
                    child: Text(
                      AppLocalizations.of(context).output_files_title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  getOutputhFiles(),
                  const Divider(),
                ] else ...[
                  const Spacer(),
                ],
                getBottomBarOptions(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      );
    } else {
      // Mobile Layout: Column
      return Column(
        children: [
          const SizedBox(height: 8),
          if (_viewModel.outputFiles.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context).output_files_title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            getOutputhFiles(),
            const Divider(),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).input_files_title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          getInputFiles(),
          getBottomBarOptions(),
          const SizedBox(height: 16),
        ],
      );
    }
  }

  int calculateFlexInputFiles() =>
      _viewModel.outputFiles.isEmpty ||
              _viewModel.selectedFiles.length <= _viewModel.outputFiles.length
          ? 1
          : 2;

  int calculateFlexOutputFiles() =>
      _viewModel.outputFiles.length <= _viewModel.selectedFiles.length ? 1 : 2;

  Widget getOutputhFiles() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      flex: calculateFlexOutputFiles(),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: _viewModel.outputFiles.length,
        itemBuilder: (context, index) {
          final filePath = _viewModel.outputFiles[index];
          final fileName = p.basename(filePath);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: FileTypeIcon(filePath: filePath),
              title: Text(
                fileName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _openOutputFile(index),
              subtitle: FutureBuilder(
                future: FileMagicNumber.getBytesFromPathOrBlob(filePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      AppLocalizations.of(context).loading_size_message,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    );
                  } else if (snapshot.hasError) {
                    return const Icon(
                      Icons.error_outline,
                      size: 14,
                      color: Colors.red,
                    );
                  } else {
                    return Text(
                      snapshot.data?.size() ??
                          AppLocalizations.of(context).unknown_size_message,
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                    );
                  }
                },
              ),
              trailing: IconButton(
                icon: Icon(Icons.copy_all_rounded, color: theme.primaryColor),
                tooltip:
                    AppLocalizations.of(
                      context,
                    ).snackbar_copy_output_to_clipboard,
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
              onPressed:
                  () async => {
                    _fabKey.currentState?.close(),
                    result = await FilePicker.pickFiles(type: FileType.any),
                    _prepareFiles(result: result),
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
        onPressed: () => _pickingFiles ? null : _pickFiles(),
        tooltip: AppLocalizations.of(context).add_new_files_tooltip,
        child: const Icon(Icons.add),
      );
    }
  }

  Widget getInputFiles() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      flex: calculateFlexInputFiles(),
      child: ReorderableListView.builder(
        itemCount: _viewModel.selectedFiles.length,
        onReorderItem: _onReorderFiles,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final filePath = _viewModel.selectedFiles[index];
          final fileName = p.basename(filePath);
          final fileColor = _getFileColor(filePath);

          return Dismissible(
            key: ValueKey(filePath),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _viewModel.removeFileAt(index);
              _showSnackbarSafely(
                AppLocalizations.of(context).file_removed_message(fileName),
              );
            },
            background: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 6.0,
                horizontal: 16.0,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF111827) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark
                          ? const Color(0xFF1F2937)
                          : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Row(
                  children: [
                    // Type-colored left border accent
                    Container(width: 6, height: 72, color: fileColor),
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: FileTypeIcon(filePath: filePath),
                        title: Text(
                          fileName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: FutureBuilder(
                          future: FileMagicNumber.getBytesFromPathOrBlob(
                            filePath,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text(
                                AppLocalizations.of(
                                  context,
                                ).loading_size_message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return const Icon(
                                Icons.error_outline,
                                size: 14,
                                color: Colors.red,
                              );
                            } else {
                              return Text(
                                snapshot.data?.size() ??
                                    AppLocalizations.of(
                                      context,
                                    ).unknown_size_message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                ),
                              );
                            }
                          },
                        ),
                        trailing: Icon(
                          Icons.drag_indicator_rounded,
                          color:
                              isDark
                                  ? const Color(0xFF4B5563)
                                  : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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

  Future<void> _prepareFiles({FilePickerResult? result}) async {
    await _viewModel.prepareFiles(result);
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
