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
      newText =
          value.text.substring(0, cursor) + text + value.text.substring(cursor);
      offset = cursor + text.length;
    } else {
      newText = value.text.substring(0, sel.start) +
          text +
          value.text.substring(sel.end);
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
      newText =
          value.text.substring(0, cursor - 1) + value.text.substring(cursor);
      offset = cursor - 1;
    } else {
      newText =
          value.text.substring(0, sel.start) + value.text.substring(sel.end);
      offset = sel.start;
    }

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  Widget _key(String label, {Color? bg, double? fontSize}) {
    final theme = context.watch<ThemeProvider>();
    final isBackspace = label == '?';
    final semanticLabel = isBackspace ? 'Backspace' : 'Insert $label';
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Semantics(
          label: semanticLabel,
          button: true,
          onTap: () => isBackspace ? _backspace() : _insert(label),
          excludeSemantics: true,
          child: Material(
            color: bg ?? theme.card,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              excludeFromSemantics: true,
              borderRadius: BorderRadius.circular(8),
              onTap: () => isBackspace ? _backspace() : _insert(label),
              child: SizedBox(
                height: 44,
                child: Center(
                  child: isBackspace
                      ? Icon(
                          Icons.backspace_outlined,
                          size: 20,
                          color: widget.accentColor,
                        )
                      : Text(
                          label,
                          style: TextStyle(
                            fontSize: fontSize ?? 17,
                            fontWeight: FontWeight.w500,
                            color: theme.textPrimary,
                          ),
                        ),
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
          .map((l) => l == '?'
              ? _key(l, bg: widget.accentColor.withValues(alpha: 0.15))
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
          Semantics(
            label: _visible ? 'Hide math keyboard' : 'Show math keyboard',
            button: true,
            onTap: () => setState(() => _visible = !_visible),
            excludeSemantics: true,
            child: GestureDetector(
              excludeFromSemantics: true,
              onTap: () => setState(() => _visible = !_visible),
              child: SizedBox(
                height: 44,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _visible
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        size: 18,
                        color: theme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _visible ? 'Hide math keyboard' : 'Show math keyboard',
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
            ),
          ),
          if (_visible) ...[
            const SizedBox(height: 2),
            _buildRow(['(', ')', 'v', '|', 'x', '\u03C0']),
            const SizedBox(height: 2),
            _buildRow(['7', '8', '9', '+', '-', '^']),
            const SizedBox(height: 2),
            _buildRow(['4', '5', '6', '<', '>', '/']),
            const SizedBox(height: 2),
            _buildRow(['1', '2', '3', '\u2264', '\u2265', '?']),
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
