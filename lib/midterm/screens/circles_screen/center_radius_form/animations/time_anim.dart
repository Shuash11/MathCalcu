
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Manages delayed focus loss for quick-key toolbars.
/// CRITICAL FIX: All setState calls are deferred via addPostFrameCallback
/// to prevent DOM element replacement during active pointer events.
mixin QuickKeyFocusMixin<T extends StatefulWidget> on State<T> {
  final FocusNode focusNode = FocusNode();
  bool isFocused = false;
  Timer? _hideTimer;

  void initQuickKeyFocus() {
    focusNode.addListener(_onFocusChange);
  }

  void disposeQuickKeyFocus() {
    _hideTimer?.cancel();
    focusNode.removeListener(_onFocusChange);
    focusNode.dispose();
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      _hideTimer?.cancel();
      if (!isFocused) {
        // FIX: Defer setState to avoid replacing DOM element during pointer event
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => isFocused = true);
        });
      }
    } else {
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => isFocused = false);
          });
        }
      });
    }
  }

  void cancelFocusHide() => _hideTimer?.cancel();

  void insertChar(TextEditingController controller, String char) {
    final sel = controller.selection;
    final text = controller.text;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;

    controller.value = TextEditingValue(
      text: text.replaceRange(start, end, char),
      selection: TextSelection.collapsed(offset: start + char.length),
    );
    focusNode.requestFocus();
  }
}
