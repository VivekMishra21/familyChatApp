import 'package:flutter/material.dart';

class Dialogs {
  //here we define on member in static

  static void snapBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.blue.withOpacity(.9),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static void showCirclecularBar(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()));
  }
}
