import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:file_magic_number/file_magic_number.dart';
import 'package:drag_pdf/views/widgets/file_type_icon.dart';
import 'package:drag_pdf/core/l10n/app_localizations.dart';
import 'package:drag_pdf/core/extensions/uint8list_extension.dart';

import 'dart:typed_data';

class InputFileCard extends StatefulWidget {
  final int index;
  final String filePath;
  final bool isDesktop;
  final VoidCallback onRemove;
  final VoidCallback onOpen;

  const InputFileCard({
    super.key,
    required this.index,
    required this.filePath,
    required this.isDesktop,
    required this.onRemove,
    required this.onOpen,
  });

  static Color getFileColor(String path) {
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
  State<InputFileCard> createState() => _InputFileCardState();
}

class _InputFileCardState extends State<InputFileCard> {
  bool _isHovered = false;
  late Future<Uint8List?> _fileBytesFuture;
  late Color _resolvedColor;

  @override
  void initState() {
    super.initState();
    _fileBytesFuture = FileMagicNumber.getBytesFromPathOrBlob(widget.filePath);
    _resolveFileColor();
  }

  void _resolveFileColor() {
    _resolvedColor = InputFileCard.getFileColor(widget.filePath);
    if (_resolvedColor == const Color(0xFF64748B)) {
      FileMagicNumber.detectFileTypeFromPathOrBlob(widget.filePath)
          .then((type) {
            if (mounted) {
              setState(() {
                if (type == FileMagicNumberType.pdf) {
                  _resolvedColor = const Color(0xFFEF4444);
                } else if (type == FileMagicNumberType.png ||
                    type == FileMagicNumberType.jpg) {
                  _resolvedColor = const Color(0xFF0EA5E9);
                }
              });
            }
          })
          .catchError((_) {});
    }
  }

  @override
  void didUpdateWidget(InputFileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _fileBytesFuture = FileMagicNumber.getBytesFromPathOrBlob(
        widget.filePath,
      );
      _resolveFileColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fileName = p.basename(widget.filePath);

    final dragHandle = ReorderableDragStartListener(
      index: widget.index,
      child: Icon(
        Icons.drag_indicator_rounded,
        color: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
      ),
    );

    Widget trailingActions;
    if (widget.isDesktop && _isHovered) {
      trailingActions = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              Icons.visibility_outlined,
              color: theme.primaryColor,
              size: 20,
            ),
            onPressed: widget.onOpen,
            tooltip: 'Open',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
              size: 20,
            ),
            onPressed: widget.onRemove,
            tooltip: 'Remove',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          const SizedBox(width: 8),
          dragHandle,
        ],
      );
    } else {
      trailingActions = dragHandle;
    }

    final cardContent = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
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
          child: Row(
            children: [
              // Type-colored left border accent
              Container(width: 6, height: 72, color: _resolvedColor),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: FileTypeIcon(filePath: widget.filePath),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            AppLocalizations.of(context).loading_size_message,
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
                    trailing: trailingActions,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isDesktop) {
      return KeyedSubtree(key: ValueKey(widget.filePath), child: cardContent);
    } else {
      return Dismissible(
        key: ValueKey(widget.filePath),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => widget.onRemove(),
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
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
        child: cardContent,
      );
    }
  }
}
