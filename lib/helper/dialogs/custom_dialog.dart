import 'package:flutter/material.dart';
import 'package:mell_pdf/helper/firebase_helper.dart';

import '../../common/localization/localization.dart';
import '../utils.dart';

class CustomDialog {
  static void showError(
      {required BuildContext context,
      required Object error,
      required String titleLocalized,
      required String subtitleLocalized,
      required String buttonTextLocalized}) {
    reportError(error, titleLocalized, subtitleLocalized);
    final actions = [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(Localization.of(context).string(buttonTextLocalized)),
      ),
    ];

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(Localization.of(context).string(titleLocalized)),
            content: Text(Localization.of(context).string(subtitleLocalized)),
            actions: actions,
          );
        });
  }

  static Future<void> reportError(
      Object error, String titleLocalized, String subtitleLocalized) async {
    Utils.printInDebug(error);
    await FirebaseHelper.shared
        .logErrorInFirebase(error, titleLocalized, subtitleLocalized);
  }
}
