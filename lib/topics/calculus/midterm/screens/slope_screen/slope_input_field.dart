import 'package:flutter/material.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SlopeInputField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final VoidCallback? onEditingComplete;

  const SlopeInputField({
    super.key,
    required this.label,
    required this.controller,
    this.focusNode,
    this.textInputAction,
    this.onEditingComplete,
  });

  @override
  State<SlopeInputField> createState() => _SlopeInputFieldState();
}

class _SlopeInputFieldState extends State<SlopeInputField> {
  late final FocusNode _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(SlopeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      widget.focusNode?.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _internalFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isFocused
                  ? const Color(0xFF334155)
                  : context.watch<ThemeProvider>().textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.watch<ThemeProvider>().card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isFocused
                    ? const Color(0xFF334155)
                    : const Color(0xFF334155).withValues(alpha: 0.2),
                width: isFocused ? 2 : 1.5,
              ),
            ),
            child: GestureDetector(
              onTap: () => _focusNode.requestFocus(),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.text,
                textInputAction: widget.textInputAction,
                onEditingComplete: widget.onEditingComplete,
                style: TextStyle(
                  color: context.watch<ThemeProvider>().textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'e.g. 3',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                cursorColor: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
