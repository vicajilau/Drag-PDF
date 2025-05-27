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
import 'dart:typed_data';

extension Uint8ListExtension on Uint8List {
  String size() {
    final size = lengthInBytes;

    if (size >= 1e9) {
      return "${(size / 1e9).toStringAsFixed(2)} GB";
    } else if (size >= 1e6) {
      return "${(size / 1e6).toStringAsFixed(2)} MB";
    } else if (size >= 1e3) {
      return "${(size / 1e3).toStringAsFixed(2)} KB";
    }
    return "$size B";
  }
}
