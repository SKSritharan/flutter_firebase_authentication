import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
  info,
}

class CustomScaffoldSnackbar {
  CustomScaffoldSnackbar(this._context);

  factory CustomScaffoldSnackbar.of(BuildContext context) {
    return CustomScaffoldSnackbar(context);
  }

  final BuildContext _context;

  void show(String message, SnackBarType type) {
    Color backgroundColor;
    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red;
        break;
      case SnackBarType.info:
        backgroundColor = Colors.blue;
        break;
    }

    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          showCloseIcon: true,
          closeIconColor: Colors.white,
        ),
      );
  }
}
