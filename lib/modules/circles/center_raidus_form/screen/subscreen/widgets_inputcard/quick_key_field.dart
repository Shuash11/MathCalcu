import 'package:calculus_system/modules/circles/center_raidus_form/Animations/Time_anim.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/Theme/center_radius_theme.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/models/field_def.dart';
import 'package:calculus_system/modules/circles/center_raidus_form/screen/subscreen/widgets_inputcard/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledQuickKeyField extends StatefulWidget {
  final FieldDef field;
  final Color color;

  const LabeledQuickKeyField({
    super.key,
    required this.field,
    required this.color,
  });

  @override
  State<LabeledQuickKeyField> createState() => _LabeledQuickKeyFieldState();
}

class _LabeledQuickKeyFieldState extends State<LabeledQuickKeyField>
    with QuickKeyFocusMixin<LabeledQuickKeyField> {
  @override
  void initState() {
    super.initState();
    initQuickKeyFocus();
  }

  @override
  void dispose() {
    disposeQuickKeyFocus();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row with inline quick keys
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.field.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isFocused) ...[
                const SizedBox(width: 4),
                QuickKeyButton(
                  char: '/',
                  color: widget.color,
                  onTapDown: cancelFocusHide,
                  onTap: () => insertChar(widget.field.ctrl, '/'),
                ),
                const SizedBox(width: 4),
                QuickKeyButton(
                  char: '-',
                  color: widget.color,
                  onTapDown: cancelFocusHide,
                  onTap: () => insertChar(widget.field.ctrl, '-'),
                ),
              ],
            ],
          ),
        ),

        // Input field
        TextField(
          controller: widget.field.ctrl,
          focusNode: focusNode,
          keyboardType: const TextInputType.numberWithOptions(
            signed: true,
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[-0-9./]')),
          ],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: FindingCenterRadiusTheme.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            hintText: widget.field.hint,
            hintStyle: TextStyle(
              color:
                  FindingCenterRadiusTheme.textSecondary.withValues(alpha: 0.4),
              fontSize: 13,
              fontWeight: FontWeight.normal,
            ),
            filled: true,
            fillColor: FindingCenterRadiusTheme.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: widget.color, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
