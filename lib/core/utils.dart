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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:platform_detail/platform_detail.dart';

class Utils {
  static bool checkEnvFile() {
    String platform = PlatformDetail.currentPlatform.name.toUpperCase();
    final apiKey = dotenv.env['${platform}_API_KEY'];
    final appId = dotenv.env['${platform}_APP_ID'];
    final messagingSenderId = dotenv.env['${platform}_MESSAGING_SENDER_ID'];
    final projectId = dotenv.env['${platform}_PROJECT_ID'];

    return [
      apiKey,
      appId,
      messagingSenderId,
      projectId,
    ].every((e) => e?.isNotEmpty == true);
  }
}
