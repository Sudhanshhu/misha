import 'package:flutter/material.dart';

import '../main.dart';

class AppConst {
  static Color primaryColor = Colors.amber;
}

showsnackBar({Color color = Colors.green, required String title}) {
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).clearSnackBars();

    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        backgroundColor: color,
        content: Text(title)));
  });
}
