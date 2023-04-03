import 'package:flutter/material.dart';

/// Enum to define the type of snackbar.
enum SnackBarType {
  success,
  error,
  info,
}

/// Helper class to show a snackbar using the passed context.
class CustomScaffoldSnackbar {
  // ignore: public_member_api_docs
  CustomScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory CustomScaffoldSnackbar.of(BuildContext context) {
    return CustomScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar with the given type and message.
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
