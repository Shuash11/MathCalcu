import 'package:material_ui/material_ui.dart';

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
