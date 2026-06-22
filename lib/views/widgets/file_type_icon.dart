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

class FileTypeIcon extends StatelessWidget {
  final String filePath;
  const FileTypeIcon({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    final extension = p.extension(filePath).toLowerCase();

    // Fast-path: Check file extension first to avoid unnecessary async delays for common types
    if (extension == '.pdf') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.asset("assets/files/pdf_file.png"),
      );
    } else if (extension == '.png') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.asset("assets/files/png_file.png"),
      );
    } else if (extension == '.jpg' || extension == '.jpeg') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.asset("assets/files/jpg_file.png"),
      );
    } else if (extension == '.doc' || extension == '.docx') {
      return SizedBox(
        width: 40,
        height: 40,
        child: Image.asset("assets/files/doc_file.png"),
      );
    }

    // Fallback: If extension is not definitive, detect via Magic Number bytes
    return SizedBox(
      width: 40,
      height: 40,
      child: FutureBuilder(
        future: FileMagicNumber.detectFileTypeFromPathOrBlob(filePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Image.asset(
              "assets/files/unknown_file.png",
              opacity: const AlwaysStoppedAnimation(0.5),
            );
          } else if (snapshot.hasError) {
            return const Icon(Icons.error_outline, color: Colors.red);
          } else {
            switch (snapshot.data) {
              case FileMagicNumberType.png:
                return Image.asset("assets/files/png_file.png");
              case FileMagicNumberType.jpg:
                return Image.asset("assets/files/jpg_file.png");
              case FileMagicNumberType.pdf:
                return Image.asset("assets/files/pdf_file.png");
              default:
                return Image.asset("assets/files/unknown_file.png");
            }
          }
        },
      ),
    );
  }
}
