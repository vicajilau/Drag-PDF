import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../view_models/pdf_combiner_view_model.dart';
import '../../widgets/input_file_card.dart';
import '../../widgets/output_file_card.dart';
import 'desktop_empty_state.dart';

class DesktopLayout extends StatelessWidget {
  final PdfCombinerViewModel viewModel;
  final bool isDragging;
  final bool pickingFiles;
  final VoidCallback onPickFiles;
  final VoidCallback onRestart;
  final Function(int) onOpenInput;
  final Function(int) onRemoveInput;
  final Function(int, int) onReorder;
  final Function(int) onOpenOutput;
  final Function(int) onCopyOutput;
  final Function(int) onSaveOutput;
  final VoidCallback onCreatePdf;
  final VoidCallback onCreateImages;

  const DesktopLayout({
    super.key,
    required this.viewModel,
    required this.isDragging,
    required this.pickingFiles,
    required this.onPickFiles,
    required this.onRestart,
    required this.onOpenInput,
    required this.onRemoveInput,
    required this.onReorder,
    required this.onOpenOutput,
    required this.onCopyOutput,
    required this.onSaveOutput,
    required this.onCreatePdf,
    required this.onCreateImages,
  });

  int _calculateFlexInputFiles() =>
      viewModel.outputFiles.isEmpty ||
              viewModel.selectedFiles.length <= viewModel.outputFiles.length
          ? 1
          : 2;

  int _calculateFlexOutputFiles() =>
      viewModel.outputFiles.length <= viewModel.selectedFiles.length ? 1 : 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Custom Desktop Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Text(
                'Drag PDF',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              const Spacer(),
              if (!viewModel.isEmpty() && !pickingFiles)
                OutlinedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(AppLocalizations.of(context).restart_app_tooltip),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              viewModel.isEmpty()
                  ? DesktopEmptyState(
                    isDragging: isDragging,
                    onPickFiles: onPickFiles,
                  )
                  : Row(
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
                                right: 20.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(
                                      context,
                                    ).input_files_title,
                                    style: theme.textTheme.headlineMedium,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed:
                                        pickingFiles ? null : onPickFiles,
                                    tooltip:
                                        AppLocalizations.of(
                                          context,
                                        ).add_new_files_tooltip,
                                    color: theme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: _calculateFlexInputFiles(),
                              child: ReorderableListView.builder(
                                buildDefaultDragHandles: false,
                                itemCount: viewModel.selectedFiles.length,
                                onReorderItem: onReorder,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final filePath =
                                      viewModel.selectedFiles[index];
                                  return InputFileCard(
                                    key: ValueKey(filePath),
                                    index: index,
                                    filePath: filePath,
                                    isDesktop: true,
                                    onRemove: () => onRemoveInput(index),
                                    onOpen: () => onOpenInput(index),
                                  );
                                },
                              ),
                            ),
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
                            if (viewModel.outputFiles.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                  top: 20.0,
                                  bottom: 8.0,
                                ),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).output_files_title,
                                  style: theme.textTheme.headlineMedium,
                                ),
                              ),
                              Expanded(
                                flex: _calculateFlexOutputFiles(),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: viewModel.outputFiles.length,
                                  itemBuilder: (context, index) {
                                    final filePath =
                                        viewModel.outputFiles[index];
                                    return OutputFileCard(
                                      index: index,
                                      filePath: filePath,
                                      onOpen: () => onOpenOutput(index),
                                      onCopy: () => onCopyOutput(index),
                                      onSave: () => onSaveOutput(index),
                                    );
                                  },
                                ),
                              ),
                              const Divider(),
                            ] else ...[
                              const Spacer(),
                            ],
                            _buildBottomBarOptions(context),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildBottomBarOptions(BuildContext context) {
    final isNotSinglePdf = viewModel.isNotSinglePdfLoaded();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child:
                isNotSinglePdf
                    ? ElevatedButton.icon(
                      onPressed: onCreatePdf,
                      icon: const Icon(Icons.picture_as_pdf_rounded),
                      label: Text(
                        AppLocalizations.of(context).create_pdf_button,
                      ),
                    )
                    : OutlinedButton.icon(
                      onPressed: onCreateImages,
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
}
