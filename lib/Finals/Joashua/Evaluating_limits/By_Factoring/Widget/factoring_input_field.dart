import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class FactoringInputField extends StatelessWidget {
  final TextEditingController expressionController;
  final TextEditingController approachController;
  final String currentVariable;
  final ValueChanged<String> onVariableChanged;
  final VoidCallback onSolve;

  const FactoringInputField({
    super.key,
    required this.expressionController,
    required this.approachController,
    required this.currentVariable,
    required this.onVariableChanged,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;
    const accentColor = FinalsTheme.primary;

    final expressionFontSize = isCompact ? 16.0 : 18.0;
    final limitTextSize = isCompact ? 16.0 : 22.0;
    final variableFontSize = isCompact ? 13.0 : 15.0;
    final inputHeight = isCompact ? 38.0 : 42.0;

    return Container(
      decoration: BoxDecoration(
        color: FinalsTheme.card(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: FinalsTheme.shadowColor(context).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Expression Input Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: expressionController,
                    onSubmitted: (_) => onSolve(),
                    style: FinalsTheme.titleStyle(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: expressionFontSize,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: isCompact ? 'x²-4 / x-2' : '(x^2 - 4) / (x - 2)',
                      hintStyle: FinalsTheme.subtitleStyle(context).copyWith(
                        color: FinalsTheme.textSecondary(context)
                            .withValues(alpha: 0.3),
                        fontSize: isCompact ? 12 : 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: isCompact ? 8 : 12),
                    ),
                  ),
                ),

                // Math Symbol Button
                _buildMathSymbolChip(context, '^', '^', accentColor),
                const SizedBox(width: 8),

                // Solve Button
                _SolveButton(onTap: onSolve, accentColor: accentColor),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8, indent: 20, endIndent: 20),

          // ── Limit Meta Row
          Padding(
            padding: EdgeInsets.fromLTRB(isCompact ? 8 : 12, isCompact ? 8 : 12, isCompact ? 8 : 12, isCompact ? 8 : 12),
            child: Row(
              children: [
                Text(
                  'lim',
                  style: FinalsTheme.titleStyle(context).copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: limitTextSize,
                    color: accentColor,
                    fontFamily: 'serif',
                  ),
                ),
                SizedBox(width: isCompact ? 4 : 8),

                // Variable Selection Pill
                _VariablePill(
                  variable: currentVariable,
                  onTap: () => _showVariablePicker(context),
                  accentColor: accentColor,
                  fontSize: variableFontSize,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isCompact ? 4 : 8),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: isCompact ? 12 : 14,
                    color: accentColor,
                  ),
                ),

                // Approach Value Input
                Expanded(
                  flex: isCompact ? 3 : 2,
                  child: Container(
                    height: inputHeight,
                    decoration: BoxDecoration(
                      color: FinalsTheme.cardSecondary(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: TextField(
                      controller: approachController,
                      onSubmitted: (_) => onSolve(),
                      textAlign: TextAlign.center,
                      style: FinalsTheme.titleStyle(context).copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'value (e.g. 2)',
                        hintStyle: FinalsTheme.subtitleStyle(context).copyWith(
                          fontSize: 13,
                          color: FinalsTheme.textSecondary(context)
                              .withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: isCompact ? 4 : 8),

                // Quick Presets
                _buildQuickChip(context, '0', accentColor),
                SizedBox(width: isCompact ? 4 : 6),
                _buildQuickChip(context, '1', accentColor),
                if (!isCompact) ...[
                  SizedBox(width: 6),
                  _buildQuickChip(context, '2', accentColor),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(BuildContext context, String label, Color accent) {
    return InkWell(
      onTap: () => approachController.text = label,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.15)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _showVariablePicker(BuildContext context) {
    final variables = ['x', 'y', 'z', 't', 'n', 'u'];
    showModalBottomSheet(
      context: context,
      backgroundColor: FinalsTheme.card(context),
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FinalsTheme.textSecondary(ctx).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Select Limit Variable',
                style: FinalsTheme.titleStyle(ctx).copyWith(fontSize: 20),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: variables.length,
                itemBuilder: (ctx, i) {
                  final v = variables[i];
                  final isSelected = v == currentVariable;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? FinalsTheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        v,
                        style: FinalsTheme.titleStyle(ctx).copyWith(
                          fontFamily: 'serif',
                          fontSize: 18,
                          color: isSelected ? FinalsTheme.primary : null,
                        ),
                      ),
                      onTap: () {
                        onVariableChanged(v);
                        Navigator.pop(ctx);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: FinalsTheme.primary)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  Widget _buildMathSymbolChip(BuildContext context, String label, String inputStr, Color accent, {bool isFunction = false}) {
    return InkWell(
      onTap: () {
        final text = expressionController.text;
        final selection = expressionController.selection;
        
        if (selection.baseOffset == -1 || selection.extentOffset == -1) {
          expressionController.text = text + inputStr;
          if (isFunction) {
            expressionController.selection = TextSelection.collapsed(offset: expressionController.text.length - 1);
          }
        } else {
          final start = selection.start;
          final end = selection.end;
          final newText = text.replaceRange(start, end, inputStr);
          expressionController.text = newText;
          
          final newOffset = isFunction ? start + inputStr.length - 1 : start + inputStr.length;
          expressionController.selection = TextSelection.collapsed(offset: newOffset);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accent.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SolveButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color accentColor;

  const _SolveButton({required this.onTap, required this.accentColor});

  @override
  State<_SolveButton> createState() => _SolveButtonState();
}

class _SolveButtonState extends State<_SolveButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accentColor,
                widget.accentColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    widget.accentColor.withValues(alpha: _hovered ? 0.4 : 0.2),
                blurRadius: _hovered ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Solve',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VariablePill extends StatelessWidget {
  final String variable;
  final VoidCallback onTap;
  final Color accentColor;
  final double fontSize;

  const _VariablePill({
    required this.variable,
    required this.onTap,
    required this.accentColor,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: fontSize * 0.7, vertical: fontSize * 0.35),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(fontSize * 0.5),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Text(
          variable,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}
