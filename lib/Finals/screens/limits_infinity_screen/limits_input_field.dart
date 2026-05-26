import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class LimitsInputField extends StatelessWidget {
  final TextEditingController expressionController;
  final TextEditingController approachController;
  final FocusNode expressionFocus;
  final FocusNode approachFocus;
  final String currentVariable;
  final ValueChanged<String> onVariableChanged;
  final VoidCallback onSolve;

  const LimitsInputField({
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 380;
    
    final inputHeight = isCompact ? 34.0 : 40.0;

    final limitTextSize = isCompact ? 14.0 : 18.0;

    return Container(
      decoration: BoxDecoration(
        color: FinalsTheme.card(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: FinalsTheme.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: FinalsTheme.shadowColor(context).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Expression Input Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: expressionController,
                    focusNode: expressionFocus,
                    keyboardType: TextInputType.none,
                    onSubmitted: (_) => onSolve(),
                    style: FinalsTheme.titleStyle(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Enter rational/polynomial (e.g. (3x^2+2)/(x^2+1))',
                      hintStyle: FinalsTheme.subtitleStyle(context).copyWith(
                        color: FinalsTheme.textSecondary(context)
                            .withValues(alpha: 0.4),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // Solve Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onSolve,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: FinalsTheme.headerGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: FinalsTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),

          // Approach Row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'lim',
                  style: FinalsTheme.titleStyle(context).copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: limitTextSize,
                    color: FinalsTheme.primary,
                  ),
                ),
                const SizedBox(width: 6),

                // Variable Selector
                GestureDetector(
                  onTap: () => _showVariablePicker(context),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: FinalsTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentVariable,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: FinalsTheme.primary,
                      ),
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_right_alt,
                      size: 20, color: FinalsTheme.primary),
                ),

                // Approach Value Input
                Expanded(
                  flex: isCompact ? 3 : 2,
                  child: Container(
                    height: inputHeight,
                    decoration: BoxDecoration(
                      color: FinalsTheme.cardSecondary(context),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: approachController,
                      focusNode: approachFocus,
                      keyboardType: TextInputType.none,
                      onSubmitted: (_) => onSolve(),
                      textAlign: TextAlign.center,
                      style: FinalsTheme.titleStyle(context)
                          .copyWith(fontSize: limitTextSize - 4),
                      decoration: InputDecoration(
                        hintText: 'value',
                        hintStyle: FinalsTheme.subtitleStyle(context)
                            .copyWith(fontSize: 11),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: isCompact ? 8 : 12),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text('Select Variable', style: FinalsTheme.titleStyle(ctx)),
            ),
            ...variables.map((v) {
              final isSelected = v == currentVariable;
              return ListTile(
                title: Text(
                  v,
                  style: FinalsTheme.titleStyle(ctx).copyWith(
                    fontFamily: 'serif',
                    color: isSelected ? FinalsTheme.primary : null,
                  ),
                ),
                onTap: () {
                  onVariableChanged(v);
                  Navigator.pop(ctx);
                },
                trailing: isSelected
                    ? const Icon(Icons.check, color: FinalsTheme.primary)
                    : null,
              );
            })
          ],
        ),
      ),
    );
  }
}
