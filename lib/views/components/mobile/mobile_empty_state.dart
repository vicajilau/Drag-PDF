import 'package:flutter/material.dart';
import 'package:drag_pdf/core/l10n/app_localizations.dart';

class MobileEmptyState extends StatelessWidget {
  final bool isDragging;
  final VoidCallback onPickGallery;
  final VoidCallback onPickFiles;
  final VoidCallback onPickScanner;

  const MobileEmptyState({
    super.key,
    required this.isDragging,
    required this.onPickGallery,
    required this.onPickFiles,
    required this.onPickScanner,
  });

  @override
  Widget build(BuildContext context) {
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
                    isDragging
                        ? theme.primaryColor
                        : (isDark
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFE2E8F0)),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isDragging
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
                  padding: EdgeInsets.all(isDragging ? 26 : 20),
                  decoration: BoxDecoration(
                    color:
                        isDragging
                            ? theme.primaryColor.withValues(alpha: 0.1)
                            : theme.primaryColor.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDragging
                        ? Icons.downloading_rounded
                        : Icons.drive_folder_upload_rounded,
                    size: 56,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  isDragging
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
                  isDragging
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
                    onPressed: onPickGallery,
                    icon: const Icon(Icons.image_rounded, size: 18),
                    label: Text(
                      AppLocalizations.of(context).select_from_gallery_button,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPickFiles,
                    icon: const Icon(Icons.insert_drive_file_rounded, size: 18),
                    label: Text(
                      AppLocalizations.of(context).select_from_device_button,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onPickScanner,
                    icon: const Icon(Icons.document_scanner_rounded, size: 18),
                    label: Text(
                      AppLocalizations.of(context).select_from_scanner_button,
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
}
