import 'dart:async';

import 'package:calculus_system/modules/circles/center_raidus_form/Theme/center_radius_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

  // FIX: Stable key prevents DOM element replacement
  final GlobalKey _textFieldKey = GlobalKey();

  bool _isFocused = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _hideTimer?.cancel();
      if (!_isFocused) {
        // FIX: Defer setState until after pointer event completes
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isFocused = true);
        });
      }
    } else {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isFocused = false);
          });
        }
      });
    }
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
    _focusNode.requestFocus();
  }

  Widget _quickKey(String char) {
    return GestureDetector(
      onTapDown: (_) => _hideTimer?.cancel(),
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
  void dispose() {
    _hideTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
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
          // Header
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

          // Quick keys
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

          // TextField with stable key - FIX: prevents DOM replacement
          TextField(
            key: _textFieldKey,
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

          // Button
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [widget.color, FindingCenterRadiusTheme.emerald],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  widget.buttonLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
