import 'package:flutter/material.dart';

class NfcWidget extends StatelessWidget {
  final VoidCallback onScan;

  const NfcWidget({super.key, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onScan,
      child: Text("Vincular Tag NFC"),
    );
  }
}
