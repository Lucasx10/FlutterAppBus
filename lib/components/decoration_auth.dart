import "package:flutter/material.dart";

InputDecoration getAuthenticationDecoration(String label) {
  return InputDecoration(
    hintText: label,
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.lightBlue, width: 2)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2)),
  );
}
