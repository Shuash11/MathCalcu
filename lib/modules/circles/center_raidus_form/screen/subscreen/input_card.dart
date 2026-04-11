import 'package:calculus_system/modules/circles/center_raidus_form/Theme/center_radius_theme.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/models/field_def.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/screen/subscreen/widgets_inputcard/compute_button.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/screen/subscreen/widgets_inputcard/quick_key_field.dart';
import 'package:flutter/material.dart';

class InputCard extends StatelessWidget {
  final String title;
  final String formula;
  final Color color;
  final List<FieldDef> fields;
  final String buttonLabel;
  final VoidCallback onTap;

  const InputCard({
    super.key,
    required this.title,
    required this.formula,
    required this.color,
    required this.fields,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: FindingCenterRadiusTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildFieldsRow(),
          const SizedBox(height: 16),
          GradientComputeButton(
            label: buttonLabel,
            color: color,
            onTap: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: FindingCenterRadiusTheme.textPrimary,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            formula,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldsRow() {
    return Row(
      children: fields.asMap().entries.map((entry) {
        final index = entry.key;
        final field = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == fields.length - 1 ? 0 : 10,
            ),
            child: LabeledQuickKeyField(
              field: field,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }
}
