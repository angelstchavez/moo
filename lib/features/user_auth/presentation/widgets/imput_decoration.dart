import 'package:flutter/material.dart';

class InputDecorations {
  static InputDecoration inputDecotation(
      {required String hintext,
      required String labeltext,
      required Icon icono}) {
    return InputDecoration(
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.white),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.black),
      ),
      hintText: hintext,
      labelText: labeltext,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.normal,
        color: Colors.white,
      ),
      prefixIcon: Icon(
        icono.icon,
        color: Colors.white,
      ),
      hintStyle: TextStyle(
        color: Colors.red.shade900,
      ),
    );
  }
}
