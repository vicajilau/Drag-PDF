import 'package:flutter/material.dart';
import 'package:platform_detail/platform_detail.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../view_models/pdf_combiner_view_model.dart';
import '../../widgets/input_file_card.dart';
import '../../widgets/output_file_card.dart';
import '../desktop/desktop_empty_state.dart';
import 'mobile_empty_state.dart';

class MobileLayout extends StatelessWidget {
  final PdfCombinerViewModel viewModel;
  final bool isDragging;
  final bool pickingFiles;
  final VoidCallback onPickGallery;
  final VoidCallback onPickFiles;
  final VoidCallback onPickScanner;
  final Function(int) onOpenInput;
  final Function(int) onRemoveInput;
  final Function(int, int) onReorder;
  final Function(int) onOpenOutput;
  final Function(int) onCopyOutput;
  final Function(int) onSaveOutput;

  const MobileLayout({
    super.key,
    required this.viewModel,
    required this.isDragging,
    required this.pickingFiles,
    required this.onPickGallery,
    required this.onPickFiles,
    required this.onPickScanner,
    required this.onOpenInput,
    required this.onRemoveInput,
    required this.onReorder,
    required this.onOpenOutput,
    required this.onCopyOutput,
    required this.onSaveOutput,
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

    if (viewModel.isEmpty()) {
      if (PlatformDetail.isMobile) {
        return MobileEmptyState(
          isDragging: isDragging,
          onPickGallery: onPickGallery,
          onPickFiles: onPickFiles,
          onPickScanner: onPickScanner,
        );
      } else {
        return DesktopEmptyState(
          isDragging: isDragging,
          onPickFiles: onPickFiles,
        );
      }
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        if (viewModel.outputFiles.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context).output_files_title,
                style: theme.textTheme.headlineMedium,
              ),
            ),
          ),
          Expanded(
            flex: _calculateFlexOutputFiles(),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: viewModel.outputFiles.length,
              itemBuilder: (context, index) {
                final filePath = viewModel.outputFiles[index];
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
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context).input_files_title,
              style: theme.textTheme.headlineMedium,
            ),
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
              final filePath = viewModel.selectedFiles[index];
              return InputFileCard(
                key: ValueKey(filePath),
                index: index,
                filePath: filePath,
                isDesktop: !PlatformDetail.isMobile,
                onRemove: () => onRemoveInput(index),
                onOpen: () => onOpenInput(index),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
