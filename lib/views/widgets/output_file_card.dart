import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:file_magic_number/file_magic_number.dart';
import 'package:drag_pdf/core/l10n/app_localizations.dart';
import 'package:drag_pdf/core/extensions/uint8list_extension.dart';

import 'dart:typed_data';

class OutputFileCard extends StatefulWidget {
  final int index;
  final String filePath;
  final VoidCallback onOpen;
  final VoidCallback onCopy;
  final VoidCallback onSave;

  const OutputFileCard({
    super.key,
    required this.index,
    required this.filePath,
    required this.onOpen,
    required this.onCopy,
    required this.onSave,
  });

  @override
  State<OutputFileCard> createState() => _OutputFileCardState();
}

class _OutputFileCardState extends State<OutputFileCard> {
  late Future<Uint8List?> _fileBytesFuture;

  @override
  void initState() {
    super.initState();
    _fileBytesFuture = FileMagicNumber.getBytesFromPathOrBlob(widget.filePath);
  }

  @override
  void didUpdateWidget(OutputFileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _fileBytesFuture = FileMagicNumber.getBytesFromPathOrBlob(
        widget.filePath,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fileName = p.basename(widget.filePath);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
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
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            onTap: widget.onOpen,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                color: theme.primaryColor,
              ),
            ),
            title: Text(
              fileName,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: FutureBuilder<Uint8List?>(
              future: _fileBytesFuture,
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.save_alt_rounded, color: theme.primaryColor),
                  tooltip: AppLocalizations.of(context).save_file_tooltip,
                  onPressed: widget.onSave,
                ),
                IconButton(
                  icon: Icon(Icons.copy_all_rounded, color: theme.primaryColor),
                  tooltip:
                      AppLocalizations.of(
                        context,
                      ).snackbar_copy_output_to_clipboard,
                  onPressed: widget.onCopy,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
