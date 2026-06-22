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
import 'package:file_magic_number/file_magic_number.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class FileTypeIcon extends StatefulWidget {
  final String filePath;
  const FileTypeIcon({super.key, required this.filePath});

  @override
  State<FileTypeIcon> createState() => _FileTypeIconState();
}

class _FileTypeIconState extends State<FileTypeIcon> {
  late Future<FileMagicNumberType> _detectFuture;

  @override
  void initState() {
    super.initState();
    _detectFuture = FileMagicNumber.detectFileTypeFromPathOrBlob(
      widget.filePath,
    );
  }

  @override
  void didUpdateWidget(FileTypeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _detectFuture = FileMagicNumber.detectFileTypeFromPathOrBlob(
        widget.filePath,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final extension = p.extension(widget.filePath).toLowerCase();

    // Fast-path: Check file extension first to avoid unnecessary async delays for common types
    if (extension == '.pdf') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.asset("assets/files/pdf_file.png", width: 40, height: 40),
      );
    } else if (extension == '.png') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.asset("assets/files/png_file.png", width: 40, height: 40),
      );
    } else if (extension == '.jpg' || extension == '.jpeg') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.asset("assets/files/jpg_file.png", width: 40, height: 40),
      );
    } else if (extension == '.doc' || extension == '.docx') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.asset("assets/files/doc_file.png", width: 40, height: 40),
      );
    }

    // Fallback: If extension is not definitive, detect via Magic Number bytes
    return SizedBox(
      width: 40,
      height: 40,
      child: FutureBuilder<FileMagicNumberType>(
        future: _detectFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Image.asset(
              "assets/files/unknown_file.png",
              width: 40,
              height: 40,
              opacity: const AlwaysStoppedAnimation(0.5),
            );
          } else if (snapshot.hasError) {
            return const Icon(Icons.error_outline, color: Colors.red);
          } else {
            switch (snapshot.data) {
              case FileMagicNumberType.png:
                return Image.asset(
                  "assets/files/png_file.png",
                  width: 40,
                  height: 40,
                );
              case FileMagicNumberType.jpg:
                return Image.asset(
                  "assets/files/jpg_file.png",
                  width: 40,
                  height: 40,
                );
              case FileMagicNumberType.pdf:
                return Image.asset(
                  "assets/files/pdf_file.png",
                  width: 40,
                  height: 40,
                );
              default:
                return Image.asset(
                  "assets/files/unknown_file.png",
                  width: 40,
                  height: 40,
                );
            }
          }
        },
      ),
    );
  }
}
