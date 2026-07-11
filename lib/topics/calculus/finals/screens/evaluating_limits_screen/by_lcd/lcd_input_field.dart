import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:flutter/material.dart';

class LCDInputField extends StatelessWidget {
  final TextEditingController expressionController;
  final TextEditingController approachController;
  final String currentVariable;
  final ValueChanged<String> onVariableChanged;
  final VoidCallback onSolve;
  final FocusNode expressionFocus;
  final FocusNode approachFocus;

  const LCDInputField({
    super.key,
    required this.expressionController,
    required this.approachController,
    required this.currentVariable,
    required this.onVariableChanged,
    required this.onSolve,
    required this.expressionFocus,
    required this.approachFocus,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;
    final isTablet = screenWidth > 600;
    // We use the 'danger' color (rose red) as the primary accent for LCD
    const accentColor = FinalsTheme.danger;

    final expressionFontSize = isCompact ? 16.0 : (isTablet ? 20.0 : 18.0);
    final limitTextSize = isCompact ? 16.0 : (isTablet ? 24.0 : 18.0);
    final variableFontSize = isCompact ? 13.0 : (isTablet ? 18.0 : 15.0);
    final inputHeight = isCompact ? 38.0 : (isTablet ? 48.0 : 44.0);
    final expressionPadding = isCompact
        ? const EdgeInsets.fromLTRB(12, 8, 8, 4)
        : const EdgeInsets.fromLTRB(20, 12, 12, 4);

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
            padding: expressionPadding,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: expressionController,
                    focusNode: expressionFocus,
                    keyboardType: TextInputType.text,
                    onSubmitted: (_) => onSolve(),
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => approachFocus.requestFocus(),
                    style: FinalsTheme.titleStyle(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: expressionFontSize,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      hintText: '(1/x - 1/3) / (x - 3)',
                      hintStyle: FinalsTheme.subtitleStyle(context).copyWith(
                        color: FinalsTheme.textSecondary(context)
                            .withValues(alpha: 0.3),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                // Solve Button
                _SolveButton(onTap: onSolve, accentColor: accentColor),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.8, indent: 20, endIndent: 20),

// ── Limit Meta Row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                const SizedBox(width: 6),

                // Variable Selection Pill
                _VariablePill(
                  variable: currentVariable,
                  onTap: () => _showVariablePicker(context),
                  accentColor: accentColor,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 12,
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
                      focusNode: approachFocus,
                      keyboardType: TextInputType.text,
                      onSubmitted: (_) => onSolve(),
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => approachFocus.unfocus(),
                      textAlign: TextAlign.center,
                      style: FinalsTheme.titleStyle(context).copyWith(
                        fontSize: variableFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'value',
                        hintStyle: FinalsTheme.subtitleStyle(context).copyWith(
                          fontSize: 12,
                          color: FinalsTheme.textSecondary(context)
                              .withValues(alpha: 0.4),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: isCompact ? 6 : 10),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: isCompact ? 4 : 8),
              ],
            ),
          ),
        ],
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
                          ? FinalsTheme.danger.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        v,
                        style: FinalsTheme.titleStyle(ctx).copyWith(
                          fontFamily: 'serif',
                          fontSize: 18,
                          color: isSelected ? FinalsTheme.danger : null,
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
                              color: FinalsTheme.danger)
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  const _VariablePill({
    required this.variable,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: accentColor.withValues(alpha: 0.2)),
        ),
        child: Text(
          variable,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}
