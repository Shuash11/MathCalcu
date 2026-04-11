import 'package:flutter/material.dart';

class FieldDef {
  final TextEditingController ctrl;
  final String label;
  final String hint;

  const FieldDef({
    required this.ctrl,
    required this.label,
    required this.hint,
  });
}
