import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MathKeyboard extends StatefulWidget {
  final TextEditingController controller;
  final Color accentColor;
  final ValueNotifier<int>? hideSignal;

  const MathKeyboard({
    super.key,
    required this.controller,
    required this.accentColor,
    this.hideSignal,
  });

  @override
  State<MathKeyboard> createState() => _MathKeyboardState();
}

class _MathKeyboardState extends State<MathKeyboard> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    widget.hideSignal?.addListener(_onHideSignal);
  }

  @override
  void didUpdateWidget(MathKeyboard old) {
    super.didUpdateWidget(old);
    if (old.hideSignal != widget.hideSignal) {
      old.hideSignal?.removeListener(_onHideSignal);
      widget.hideSignal?.addListener(_onHideSignal);
    }
  }

  @override
  void dispose() {
    widget.hideSignal?.removeListener(_onHideSignal);
    super.dispose();
  }

  void _onHideSignal() {
    if (mounted) setState(() => _visible = false);
  }

  void _insert(String text) {
    final value = widget.controller.value;
    final sel = value.selection;
    if (!sel.isValid) return;

    String newText;
    int offset;
    if (sel.isCollapsed) {
      final cursor = sel.baseOffset;
      newText = value.text.substring(0, cursor) + text + value.text.substring(cursor);
      offset = cursor + text.length;
    } else {
      newText = value.text.substring(0, sel.start) + text + value.text.substring(sel.end);
      offset = sel.start + text.length;
    }

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  void _backspace() {
    final value = widget.controller.value;
    final sel = value.selection;
    if (!sel.isValid) return;

    String newText;
    int offset;
    if (sel.isCollapsed) {
      final cursor = sel.baseOffset;
      if (cursor <= 0) return;
      newText = value.text.substring(0, cursor - 1) + value.text.substring(cursor);
      offset = cursor - 1;
    } else {
      newText = value.text.substring(0, sel.start) + value.text.substring(sel.end);
      offset = sel.start;
    }

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  Widget _key(String label, {Color? bg, double? fontSize}) {
    final theme = context.watch<ThemeProvider>();
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Material(
          color: bg ?? theme.card,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => label == '⌫' ? _backspace() : _insert(label),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize ?? 17,
                  fontWeight: FontWeight.w500,
                  color: label == '⌫'
                      ? widget.accentColor
                      : theme.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels) {
    return Row(
      children: labels
          .map((l) => l == '⌫'
              ? _key(l, bg: widget.accentColor.withValues(alpha: 0.1))
              : _key(l))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.cardSecondary.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _visible = !_visible),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _visible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                    size: 18,
                    color: theme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _visible ? 'Hide keyboard' : 'Show keyboard',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_visible) ...[
            const SizedBox(height: 2),
            _buildRow(['(', ')', '√', '|', 'x', '²']),
            const SizedBox(height: 2),
            _buildRow(['7', '8', '9', '+', '−', '^']),
            const SizedBox(height: 2),
            _buildRow(['4', '5', '6', '<', '>', '/']),
            const SizedBox(height: 2),
            _buildRow(['1', '2', '3', '≤', '≥', '⌫']),
            const SizedBox(height: 2),
            Row(
              children: [
                _key('0'),
                _key('.'),
                const Expanded(flex: 4, child: SizedBox()),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}
