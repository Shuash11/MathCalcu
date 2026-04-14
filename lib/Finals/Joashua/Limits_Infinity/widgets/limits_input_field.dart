import 'package:calculus_system/Finals/finals_theme.dart';
import 'package:flutter/material.dart';

class LimitsInputField extends StatelessWidget {
  final TextEditingController expressionController;
  final TextEditingController approachController;
  final String currentVariable;
  final ValueChanged<String> onVariableChanged;
  final VoidCallback onSolve;

  const LimitsInputField({
    super.key,
    required this.expressionController,
    required this.approachController,
    required this.currentVariable,
    required this.onVariableChanged,
    required this.onSolve,
  });

  @override
  Widget build(BuildContext context) {
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
                  child: TextField(
                    controller: expressionController,
                    onSubmitted: (_) => onSolve(),
                    style: FinalsTheme.titleStyle(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter expression (e.g. (x^2-1)/(x-1))',
                      hintStyle: FinalsTheme.subtitleStyle(context).copyWith(
                        color: FinalsTheme.textSecondary(context).withValues(alpha: 0.4),
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
                    fontSize: 20,
                    color: FinalsTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                
                // Variable Selector
                GestureDetector(
                  onTap: () => _showVariablePicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: FinalsTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      currentVariable,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: FinalsTheme.primary,
                      ),
                    ),
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_right_alt, size: 20, color: FinalsTheme.primary),
                ),

                // Approach Value Input
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: FinalsTheme.cardSecondary(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: approachController,
                      onSubmitted: (_) => onSolve(),
                      textAlign: TextAlign.center,
                      style: FinalsTheme.titleStyle(context).copyWith(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'value (e.g. 0, inf, -inf)',
                        hintStyle: FinalsTheme.subtitleStyle(context).copyWith(fontSize: 12),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.only(bottom: 12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),

                // Presets (inf, -inf)
                _buildQuickChip(context, '0'),
                const SizedBox(width: 4),
                _buildQuickChip(context, '∞', val: 'inf'),
                const SizedBox(width: 4),
                _buildQuickChip(context, '-∞', val: '-inf'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(BuildContext context, String label, {String? val}) {
    return InkWell(
      onTap: () {
        approachController.text = val ?? label;
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: FinalsTheme.primary.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: FinalsTheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Select Variable', style: FinalsTheme.titleStyle(ctx)),
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
            }).toList(),
          ],
        ),
      ),
    );
  }
}
