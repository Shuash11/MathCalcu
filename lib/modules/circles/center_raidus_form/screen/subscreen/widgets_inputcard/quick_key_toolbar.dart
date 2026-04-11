import 'dart:async';
import 'package:calculus_system/modules/circles/center_raidus_form/screen/subscreen/widgets_inputcard/buttons.dart';
import 'package:flutter/material.dart';

/// Standalone toolbar that manages its own visibility state.
/// Does NOT rebuild parent widget, preventing DOM element replacement.
class QuickKeyToolbar extends StatefulWidget {
  final FocusNode focusNode;
  final Color color;
  final void Function(String char) onInsert;
  final List<String> keys;
  final EdgeInsets padding;

  const QuickKeyToolbar({
    super.key,
    required this.focusNode,
    required this.color,
    required this.onInsert,
    this.keys = const ['/', '-'],
    this.padding = const EdgeInsets.only(bottom: 6, left: 2),
  });

  @override
  State<QuickKeyToolbar> createState() => _QuickKeyToolbarState();
}

class _QuickKeyToolbarState extends State<QuickKeyToolbar> {
  bool _isVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (widget.focusNode.hasFocus) {
      _hideTimer?.cancel();
      if (!_isVisible) {
        // Defer to avoid pointer event conflict
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
      padding: widget.padding,
      child: Wrap(
        spacing: 4,
        children: widget.keys
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
