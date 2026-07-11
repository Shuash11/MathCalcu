import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:flutter/material.dart';

class ConjugateInputField extends StatelessWidget {
  final TextEditingController expressionController;
  final TextEditingController approachController;
  final FocusNode expressionFocus;
  final FocusNode approachFocus;
  final String currentVariable;
  final ValueChanged<String> onVariableChanged;
  final VoidCallback onSolve;

  const ConjugateInputField({
    super.key,
    required this.expressionController,
    required this.approachController,
    required this.expressionFocus,
    required this.approachFocus,
    required this.currentVariable,
    required this.onVariableChanged,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isCompact = screenWidth < 380;
        final isMedium = screenWidth >= 380 && screenWidth < 600;

        return _ConjugateInputFieldContent(
          isCompact: isCompact,
          isMedium: isMedium,
          expressionController: expressionController,
          approachController: approachController,
          expressionFocus: expressionFocus,
          approachFocus: approachFocus,
          currentVariable: currentVariable,
          onVariableChanged: onVariableChanged,
          onSolve: onSolve,
        );
      },
    );
  }
}

class _ConjugateInputFieldContent extends StatelessWidget {
  final bool isCompact;
  final bool isMedium;
  final TextEditingController expressionController;
  final TextEditingController approachController;
  final FocusNode expressionFocus;
  final FocusNode approachFocus;
  final String currentVariable;
  final ValueChanged<String> onVariableChanged;
  final VoidCallback onSolve;

  const _ConjugateInputFieldContent({
    required this.isCompact,
    required this.isMedium,
    required this.expressionController,
    required this.approachController,
    required this.expressionFocus,
    required this.approachFocus,
    required this.currentVariable,
    required this.onVariableChanged,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = FinalsTheme.secondary;

    final expressionFontSize = isCompact ? 16.0 : (isMedium ? 17.0 : 18.0);
    final limitTextSize = isCompact ? 16.0 : (isMedium ? 20.0 : 22.0);
    final variableFontSize = isCompact ? 13.0 : (isMedium ? 14.0 : 15.0);
    final inputHeight = isCompact ? 38.0 : (isMedium ? 40.0 : 42.0);
    final solveButtonPaddingH = isCompact ? 14.0 : (isMedium ? 17.0 : 20.0);
    final solveButtonPaddingV = isCompact ? 10.0 : (isMedium ? 11.0 : 12.0);
    final solveButtonFontSize = isCompact ? 13.0 : (isMedium ? 14.0 : 15.0);
    final solveButtonIconSize = isCompact ? 16.0 : (isMedium ? 18.0 : 20.0);

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
          Padding(
            padding: EdgeInsets.fromLTRB(isCompact ? 16 : 20, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
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
                        hintText: isCompact ? 'âˆšx-2 / x-4' : '(sqrt(x) - 2) / (x - 4)',
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
                _SolveButton(
                  onTap: onSolve,
                  accentColor: accentColor,
                  paddingH: solveButtonPaddingH,
                  paddingV: solveButtonPaddingV,
                  fontSize: solveButtonFontSize,
                  iconSize: solveButtonIconSize,
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 0.8, indent: isCompact ? 16 : 20, endIndent: isCompact ? 16 : 20),
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
                          fontSize: expressionFontSize - 2,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'value',
                          hintStyle: FinalsTheme.subtitleStyle(context).copyWith(
                            fontSize: 11,
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
                          ? FinalsTheme.secondary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        v,
                        style: FinalsTheme.titleStyle(ctx).copyWith(
                          fontFamily: 'serif',
                          fontSize: 18,
                          color: isSelected ? FinalsTheme.secondary : null,
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
                              color: FinalsTheme.secondary)
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
  final double paddingH;
  final double paddingV;
  final double fontSize;
  final double iconSize;

  const _SolveButton({
    required this.onTap,
    required this.accentColor,
    this.paddingH = 20,
    this.paddingV = 12,
    this.fontSize = 15,
    this.iconSize = 20,
  });

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
          padding: EdgeInsets.symmetric(horizontal: widget.paddingH, vertical: widget.paddingV),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Solve',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: widget.fontSize,
                ),
              ),
              SizedBox(width: widget.fontSize * 0.5),
              Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: widget.iconSize,
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
