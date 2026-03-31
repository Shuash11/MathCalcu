import 'package:calculus_system/modules/circles/center_raidus_form/Theme/center_radius_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── FieldDef ─────────────────────────────────────────────────────────────────

class FieldDef {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  const FieldDef({required this.ctrl, required this.label, required this.hint});
}

// ── InputCard (Standard → General) ───────────────────────────────────────────

class InputCard extends StatelessWidget {
  final String title;
  final String formula;
  final Color color;
  final List<FieldDef> fields;
  final String buttonLabel;
  final VoidCallback onTap;

  const InputCard({
    super.key,
    required this.title,
    required this.formula,
    required this.color,
    required this.fields,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: FindingCenterRadiusTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FindingCenterRadiusTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  formula,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: fields
                .map(
                  (f) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: f == fields.last ? 0 : 10,
                      ),
                      child: _InputField(f: f, color: color),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          _ComputeButton(
            label: buttonLabel,
            color: color,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

// ── EquationInputCard (General → Standard) ────────────────────────────────────

class EquationInputCard extends StatefulWidget {
  final TextEditingController ctrl;
  final Color color;
  final String buttonLabel;
  final VoidCallback onTap;

  const EquationInputCard({
    super.key,
    required this.ctrl,
    required this.color,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  State<EquationInputCard> createState() => _EquationInputCardState();
}

class _EquationInputCardState extends State<EquationInputCard> {
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

  void _insertChar(String char) {
    final ctrl = widget.ctrl;
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
      onTap: () => _insertChar(char),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: widget.color.withValues(alpha: 0.35)),
        ),
        child: Text(
          char,
          style: TextStyle(
            color: widget.color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: FindingCenterRadiusTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Enter General Equation',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: FindingCenterRadiusTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: widget.color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'x² + y² + Dx + Ey + F = 0',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Quick keys ───────────────────────────────────────────────────
          if (_isFocused) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: ['x²', 'y²', 'x', 'y', '+', '-', '=', '0']
                  .map(_quickKey)
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          // ── Text field ───────────────────────────────────────────────────
          TextField(
            controller: widget.ctrl,
            focusNode: _focusNode,
            style: const TextStyle(
              color: FindingCenterRadiusTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'e.g. x² + y² - 6x - 8y + 9 = 0',
              hintStyle: TextStyle(
                color: FindingCenterRadiusTheme.textSecondary
                    .withValues(alpha: 0.4),
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: FindingCenterRadiusTheme.inputBg,
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
          const SizedBox(height: 16),

          // ── Button ───────────────────────────────────────────────────────
          _ComputeButton(
            label: widget.buttonLabel,
            color: widget.color,
            onTap: widget.onTap,
          ),
        ],
      ),
    );
  }
}

// ── Shared individual input field ─────────────────────────────────────────────

class _InputField extends StatefulWidget {
  final FieldDef f;
  final Color color;

  const _InputField({required this.f, required this.color});

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
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

  void _insertChar(String char) {
    final ctrl = widget.f.ctrl;
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
      onTap: () => _insertChar(char),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: widget.color.withValues(alpha: 0.35)),
        ),
        child: Text(
          char,
          style: TextStyle(
            color: widget.color,
            fontSize: 14,
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
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.f.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isFocused) ...[
                const SizedBox(width: 4),
                _quickKey('/'),
                const SizedBox(width: 4),
                _quickKey('-'),
              ],
            ],
          ),
        ),
        TextField(
          controller: widget.f.ctrl,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(
              signed: true, decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[-0-9./]')),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: FindingCenterRadiusTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: widget.f.hint,
            hintStyle: TextStyle(
              color: FindingCenterRadiusTheme.textSecondary
                  .withValues(alpha: 0.4),
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: FindingCenterRadiusTheme.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.color, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── Shared compute button ─────────────────────────────────────────────────────

class _ComputeButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ComputeButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, FindingCenterRadiusTheme.emerald],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}