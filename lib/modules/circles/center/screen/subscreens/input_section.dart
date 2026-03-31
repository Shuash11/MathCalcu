// lib/Screens/SubScreens/input_section.dart
import 'package:calculus_system/modules/circles/center/Theme/centertheme.dart';
import 'package:calculus_system/modules/circles/center/controller/centercontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CenterInputSection extends StatelessWidget {
  final CenterController controller;

  const CenterInputSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PointCard(
          label: 'Point A  —  Endpoint 1',
          subtitle: '(x₁, y₁)',
          color: FindingCenterTheme.indigo,
          xCtrl: controller.x1Ctrl,
          yCtrl: controller.y1Ctrl,
          xHint: 'e.g. −2',
          yHint: 'e.g. 3',
        ),
        const SizedBox(height: 16),
        _PointCard(
          label: 'Point B  —  Endpoint 2',
          subtitle: '(x₂, y₂)',
          color: FindingCenterTheme.purple,
          xCtrl: controller.x2Ctrl,
          yCtrl: controller.y2Ctrl,
          xHint: 'e.g. 4',
          yHint: 'e.g. 5',
        ),
        const SizedBox(height: 32),
        _ActionButtons(
          onClear: controller.clear,
          onCalculate: controller.calculate,
        ),
      ],
    );
  }
}

class _PointCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final TextEditingController xCtrl;
  final TextEditingController yCtrl;
  final String xHint;
  final String yHint;

  const _PointCard({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.xCtrl,
    required this.yCtrl,
    required this.xHint,
    required this.yHint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: FindingCenterTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.circle, color: color, size: 10),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: xCtrl,
                  label: 'x',
                  hint: xHint,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                  controller: yCtrl,
                  label: 'y',
                  hint: yHint,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Now stateful to support the slash button ──────────────────────────────────
class _Field extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color color;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.color,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
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

    final newText = text.replaceRange(start, end, char);

    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + char.length),
    );
  }

  Widget _quickKey(String char) {
    return GestureDetector(
      onTap: () => _insertCharacter(char),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Text(
          char,
          style: TextStyle(
            color: widget.color,
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
        // Label row — shows quick-key buttons when focused
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: FindingCenterTheme.textSecondary,
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
            color: FindingCenterTheme.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: FindingCenterTheme.textSecondary.withValues(alpha: 0.4),
            ),
            filled: true,
            fillColor: FindingCenterTheme.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.color, width: 1.5),
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

class _ActionButtons extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onCalculate;

  const _ActionButtons({required this.onClear, required this.onCalculate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onClear,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: FindingCenterTheme.indigo.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: FindingCenterTheme.indigo.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: Text(
                  'Clear',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: FindingCenterTheme.indigo,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: onCalculate,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    FindingCenterTheme.indigo,
                    FindingCenterTheme.purple
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: FindingCenterTheme.indigo.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Find Center',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
