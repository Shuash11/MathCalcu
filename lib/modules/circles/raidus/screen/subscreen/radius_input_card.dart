import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../Theme/radiustheme.dart';

/// A single labelled text field for numeric input.
class RadiusInputField extends StatefulWidget {
  const RadiusInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  State<RadiusInputField> createState() => _RadiusInputFieldState();
}

class _RadiusInputFieldState extends State<RadiusInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _insertCharacter(String char) {
    final ctrl = widget.controller;
    final sel = ctrl.selection;
    final text = ctrl.text;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;
    ctrl.value = TextEditingValue(
      text: text.replaceRange(start, end, char),
      selection: TextSelection.collapsed(offset: start + char.length),
    );
  }

  Widget _quickKey(String char) {
    return GestureDetector(
      onTap: () => _insertCharacter(char),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: FindingRadiusTheme.cyan.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: FindingRadiusTheme.cyan.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Text(
          char,
          style: const TextStyle(
            color: FindingRadiusTheme.cyan,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FindingRadiusTheme.textSecondary,
              ),
            ),
            if (_isFocused) ...[
              const Spacer(),
              _quickKey('/'),
              const SizedBox(width: 6),
              _quickKey('-'),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[-0-9./]')),
          ],
          style: const TextStyle(
            color: FindingRadiusTheme.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: FindingRadiusTheme.textSecondary.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: FindingRadiusTheme.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: FindingRadiusTheme.cyan,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

/// A card grouping two [RadiusInputField]s under a titled section.
class RadiusInputCard extends StatelessWidget {
  const RadiusInputCard({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.leftController,
    required this.leftLabel,
    required this.leftHint,
    required this.rightController,
    required this.rightLabel,
    required this.rightHint,
  });

  final String label;
  final Color color;
  final IconData icon;

  final TextEditingController leftController;
  final String leftLabel;
  final String leftHint;

  final TextEditingController rightController;
  final String rightLabel;
  final String rightHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: FindingRadiusTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title row
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Two side-by-side fields
          Row(
            children: [
              Expanded(
                child: RadiusInputField(
                  controller: leftController,
                  label: leftLabel,
                  hint: leftHint,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RadiusInputField(
                  controller: rightController,
                  label: rightLabel,
                  hint: rightHint,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}