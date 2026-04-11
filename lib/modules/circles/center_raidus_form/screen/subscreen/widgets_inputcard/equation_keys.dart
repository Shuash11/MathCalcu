import 'dart:async';
import 'package:calculus_system/modules/circles/center_raidus_form/screen/subscreen/widgets_inputcard/buttons.dart';
import 'package:flutter/material.dart';

/// Standalone quick keys for equation input (x², y², etc.)
/// Manages visibility independently without rebuilding the TextField.
class EquationQuickKeys extends StatefulWidget {
  final FocusNode focusNode;
  final Color color;
  final void Function(String char) onInsert;

  const EquationQuickKeys({
    super.key,
    required this.focusNode,
    required this.color,
    required this.onInsert,
  });

  @override
  State<EquationQuickKeys> createState() => _EquationQuickKeysState();
}

class _EquationQuickKeysState extends State<EquationQuickKeys> {
  bool _isVisible = false;
  Timer? _hideTimer;

  static const List<String> _keys = ['x²', 'y²', 'x', 'y', '+', '-', '=', '0'];

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      _hideTimer?.cancel();
      if (!_isVisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isVisible = true);
        });
      }
    } else {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(milliseconds: 200), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _isVisible = false);
        });
      });
    }
  }

  void _cancelHide() => _hideTimer?.cancel();

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: _keys
            .map((char) => QuickKeyButton(
                  char: char,
                  color: widget.color,
                  onTapDown: _cancelHide,
                  onTap: () => widget.onInsert(char),
                ))
            .toList(),
      ),
    );
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }
}
