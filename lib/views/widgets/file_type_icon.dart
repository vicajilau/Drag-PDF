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
import 'package:file_magic_number/file_magic_number.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class FileTypeIcon extends StatelessWidget {
  final String filePath;
  const FileTypeIcon({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () => OpenFile.open(filePath),
        child: FutureBuilder(
            future: FileMagicNumber.detectFileTypeFromPathOrBlob(filePath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return const Icon(Icons.error);
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
            }));
  }
}
