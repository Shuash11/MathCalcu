import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:calculus_system/topics/calculus/finals/widgets/finals_solver_controls.dart';
import 'package:flutter/material.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';

class DerivativeInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onVariableChanged;
  final String currentVariable;
  final VoidCallback onSolve;
  final FocusNode focusNode;
  final bool isLoading;

  const DerivativeInputField({
    super.key,
    required this.controller,
    required this.onVariableChanged,
    required this.currentVariable,
    required this.onSolve,
    required this.focusNode,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: FinalsTheme.card(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FinalsTheme.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: FinalsTheme.shadowColor(context).withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              FinalsVariableChip(
                variable: currentVariable,
                onTap: () => _showVariablePicker(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.none,
                  onSubmitted: (_) => onSolve(),
                  style: FinalsTheme.titleStyle(context).copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. x² + 3x + ln(x)',
                    hintStyle: FinalsTheme.subtitleStyle(context).copyWith(
                      color: FinalsTheme.textSecondary(context)
                          .withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FinalsSolverButton(onPressed: onSolve, isLoading: isLoading),
      ],
    );
  }

  void _showVariablePicker(BuildContext context) {
    final variables = ['x', 'y', 'z', 't', 'u'];
    showModalBottomSheet(
      context: context,
      backgroundColor: FinalsTheme.cardForEvent(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: variables.map((v) {
            final isSelected = v == currentVariable;
            return ListTile(
              title: ResponsiveText(
                '',
                style: FinalsTheme.titleStyle(ctx).copyWith(
                  color: isSelected ? FinalsTheme.primaryFor(ctx) : null,
                ),
              ),
              onTap: () {
                onVariableChanged(v);
                Navigator.pop(ctx);
              },
              trailing: isSelected
                  ? Icon(Icons.check, color: FinalsTheme.primaryFor(ctx))
                  : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}
