import 'package:calculus_system/modules/y-intercept/Theme/theme.dart';
import 'package:calculus_system/modules/y-intercept/solver/y-intercpet_solver.dart';
import 'package:calculus_system/modules/y-intercept/ui/slope_intercept_scr.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

class YInterceptTab extends StatelessWidget {
  final TextEditingController mCtrl, bCtrl, sfCtrl;
  final InputMode mode;
  final void Function(InputMode) onSwitchMode;
  final ValueNotifier<YIResult?> resultNotifier;
  final ValueNotifier<String?> errorNotifier;
  final Animation<double> pulseAnim;
  final Color emeraldColor;
  final Color goldColor;
  final void Function(YIResult) onShowSlopeSteps;
  final void Function(YIResult) onShowStandardFormSteps;
  final void Function(YIResult) onShowGeneralFormSteps;
  final void Function(YIResult) onShowXInterceptSteps;

  const YInterceptTab({
    super.key,
    required this.mCtrl,
    required this.bCtrl,
    required this.sfCtrl,
    required this.mode,
    required this.onSwitchMode,
    required this.resultNotifier,
    required this.errorNotifier,
    required this.pulseAnim,
    required this.emeraldColor,
    required this.goldColor,
    required this.onShowSlopeSteps,
    required this.onShowStandardFormSteps,
    required this.onShowGeneralFormSteps,
    required this.onShowXInterceptSteps,
  });

  @override
  Widget build(BuildContext context) {
    // Watch theme provider only once to trigger rebuilds
    context.watch<ThemeProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: YITheme.cardGradient(context),
          borderRadius: BorderRadius.circular(YITheme.radiusCard),
          border: Border.all(
            color: YITheme.emerald(context).withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: YITheme.cardShadow(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(YITheme.radiusCard),
          child: Stack(
            children: [
              // Background glows
              Positioned(
                top: -60,
                right: -60,
                child: _glow(200, YITheme.emerald(context), 0.1),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: _glow(150, YITheme.gold(context), 0.08),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeaderSection(context),
                    const SizedBox(height: 20),
                    _buildModeSwitcher(context),
                    const SizedBox(height: 20),
                    _buildFormulaBanner(context),
                    const SizedBox(height: 20),
                    // Input fields with animation
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: mode == InputMode.slopeIntercept
                          ? Row(
                              key: const ValueKey(InputMode.slopeIntercept),
                              children: [
                                Expanded(
                                  child: _buildInputField(
                                    context,
                                    'SLOPE',
                                    'm',
                                    mCtrl,
                                    '0',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildInputField(
                                    context,
                                    'Y-INTERCEPT',
                                    'b',
                                    bCtrl,
                                    '0',
                                  ),
                                ),
                              ],
                            )
                          : _buildInputField(
                              context,
                              'EQUATION',
                              'Ax + By = C',
                              sfCtrl,
                              '6x - 3y = -3',
                              key: const ValueKey(InputMode.standardForm),
                            ),
                    ),
                    const SizedBox(height: 12),
                    // Error message
                    ValueListenableBuilder<String?>(
                      valueListenable: errorNotifier,
                      builder: (_, err, __) => err == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                err,
                                style: YITheme.subtitleStyle(context).copyWith(
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                    ),
                    _buildDivider(context),
                    const SizedBox(height: 20),
                    // Answer card with results
                    ValueListenableBuilder<YIResult?>(
                      valueListenable: resultNotifier,
                      builder: (context, result, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildAnswerCard(context, result),
                          // Badges when result exists
                          if (result != null) ...[
                            const SizedBox(height: 14),
                            _buildBadges(context, result),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HEADER SECTION
  // ─────────────────────────────────────────────────────────

  Widget _buildHeaderSection(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              YITheme.emerald(context).withValues(alpha: 0.3),
              YITheme.emerald(context).withValues(alpha: 0.2),
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: YITheme.mint(context).withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: YITheme.emerald(context).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) => Icon(
                Icons.trending_up_rounded,
                color: YITheme.mint(context)
                    .withValues(alpha: 0.8 + pulseAnim.value * 0.2),
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Y-Intercept Form',
                    style: YITheme.titleStyle(context),
                  ),
                  const SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: pulseAnim,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: YITheme.gold(context),
                        boxShadow: [
                          BoxShadow(
                            color: YITheme.gold(context)
                                .withValues(alpha: pulseAnim.value),
                            blurRadius: pulseAnim.value * 14,
                            spreadRadius: pulseAnim.value * 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                mode == InputMode.slopeIntercept
                    ? 'Enter slope and y-intercept directly'
                    : 'Enter a standard form equation',
                style: YITheme.subtitleStyle(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // MODE SWITCHER
  // ─────────────────────────────────────────────────────────

  Widget _buildModeSwitcher(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: YITheme.emerald(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: YITheme.emerald(context).withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeTab(
              context,
              'Slope-Intercept',
              Icons.functions_rounded,
              InputMode.slopeIntercept,
            ),
          ),
          Expanded(
            child: _buildModeTab(
              context,
              'Standard Form',
              Icons.linear_scale_rounded,
              InputMode.standardForm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(
    BuildContext context,
    String label,
    IconData icon,
    InputMode tabMode,
  ) {
    final isSelected = mode == tabMode;
    return GestureDetector(
      onTap: () => onSwitchMode(tabMode),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? YITheme.emerald(context).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? YITheme.emerald(context)
                  : YITheme.emerald(context).withValues(alpha: 0.5),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? YITheme.emerald(context)
                      : YITheme.emerald(context).withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // FORMULA BANNER
  // ─────────────────────────────────────────────────────────

  Widget _buildFormulaBanner(BuildContext context) {
    final isSI = mode == InputMode.slopeIntercept;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(mode),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: YITheme.emerald(context).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: YITheme.emerald(context).withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            Text(
              isSI ? 'SLOPE-INTERCEPT FORM' : 'STANDARD FORM',
              style: YITheme.inputLabelStyle(context).copyWith(
                color: YITheme.mint(context).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: isSI
                  ? TextSpan(
                      style: YITheme.formulaStyle(context),
                      children: [
                        const TextSpan(text: 'y = '),
                        TextSpan(
                          text: 'm',
                          style: TextStyle(
                            color: YITheme.mint(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: 'x + '),
                        TextSpan(
                          text: 'b',
                          style: TextStyle(
                            color: YITheme.gold(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : TextSpan(
                      style: YITheme.formulaStyle(context),
                      children: [
                        TextSpan(
                          text: 'A',
                          style: TextStyle(
                            color: YITheme.mint(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: 'x + '),
                        TextSpan(
                          text: 'B',
                          style: TextStyle(
                            color: YITheme.gold(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: 'y = '),
                        const TextSpan(
                          text: 'C',
                          style: TextStyle(
                            color: Color(0xFF7EB8F7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // INPUT FIELD
  // ─────────────────────────────────────────────────────────

  Widget _buildInputField(
    BuildContext context,
    String label,
    String variable,
    TextEditingController ctrl,
    String hint, {
    Key? key,
  }) {
    final isLight = YITheme.isLight(context);
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$label  ', style: YITheme.inputLabelStyle(context)),
            Text(variable, style: YITheme.inputVarStyle(context)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isLight
                ? Colors.black.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(YITheme.radiusInput),
            border: Border.all(
              color: YITheme.emerald(context).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.text,
            style: YITheme.inputTextStyle(context),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: YITheme.inputTextStyle(context).copyWith(
                color: isLight
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // ANSWER CARD
  // ─────────────────────────────────────────────────────────

  Widget _buildAnswerCard(BuildContext context, YIResult? result) {
    final emerald = YITheme.emerald(context);
    final amber = YITheme.gold(context);
    final has = result != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: has
              ? [
                  emerald.withValues(alpha: 0.10),
                  emerald.withValues(alpha: 0.04),
                ]
              : [
                  emerald.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(YITheme.radiusInner),
        border: Border.all(
          color: has
              ? emerald.withValues(alpha: 0.4)
              : emerald.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: has
            ? [
                BoxShadow(
                  color: emerald.withValues(alpha: 0.12),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: has
          ? _buildFilledCard(context, result, emerald, amber)
          : _buildEmptyCard(context),
    );
  }

  Widget _buildFilledCard(
    BuildContext context,
    YIResult r,
    Color emerald,
    Color amber,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SLOPE-INTERCEPT FORM (y = mx + b)',
          style: YITheme.inputLabelStyle(context).copyWith(
            color: emerald.withValues(alpha: 0.7),
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        // Main Answer: Slope-intercept equation
        _buildMainEquationTile(context, r, emerald),
        const SizedBox(height: 12),
        // Secondary info: X-intercept
        if (r.xIntercept != null)
          _buildInterceptTile(
            context,
            'X-Intercept',
            '(${r.xIntercept}, 0)',
            amber,
            Icons.east_rounded,
            () => onShowXInterceptSteps(r),
          ),
        if (r.xIntercept != null) const SizedBox(height: 12),
        // Row: Standard form | General form (both with Show Steps)
        Row(
          children: [
            Expanded(
              child: _buildFormTileWithSteps(
                context,
                'Standard Form',
                'Ax + By = C',
                r.standardForm,
                const Color(0xFF7EB8F7),
                () => onShowStandardFormSteps(r),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFormTileWithSteps(
                context,
                'General Form',
                'Ax + By + C = 0',
                r.generalForm,
                const Color(0xFF7EB8F7),
                () => onShowGeneralFormSteps(r),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainEquationTile(
      BuildContext context, YIResult r, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR EQUATION',
            style: YITheme.inputLabelStyle(context).copyWith(
              color: accent.withValues(alpha: 0.75),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Math.tex(
            r.equation,
            textStyle: YITheme.resultEquationStyle(context).copyWith(
              color: accent,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => onShowSlopeSteps(r),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: accent.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, color: accent, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    'View Steps',
                    style: YITheme.inputLabelStyle(context).copyWith(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        'Enter values above to see the solution',
        style: YITheme.subtitleStyle(context),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // INTERCEPT TILE (with Show Steps button)
  // ─────────────────────────────────────────────────────────

  Widget _buildInterceptTile(
    BuildContext context,
    String label,
    String value,
    Color accent,
    IconData icon,
    VoidCallback onSteps,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.28),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 12),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: YITheme.inputLabelStyle(context).copyWith(
                    color: accent.withValues(alpha: 0.85),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: YITheme.resultEquationStyle(context).copyWith(
              color: accent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onSteps,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: accent.withValues(alpha: 0.32),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, color: accent, size: 11),
                  const SizedBox(width: 4),
                  Text(
                    'Show Steps',
                    style: YITheme.inputLabelStyle(context).copyWith(
                      color: accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // FORM TILE (display only)
  // ─────────────────────────────────────────────────────────

  // ─────────────────────────────────────────────────────────
  // FORM TILE WITH STEPS BUTTON (for Standard and General)
  // ─────────────────────────────────────────────────────────

  Widget _buildFormTileWithSteps(
    BuildContext context,
    String label,
    String subtitle,
    String value,
    Color accent,
    VoidCallback onSteps,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accent.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: YITheme.inputLabelStyle(context).copyWith(
                  color: accent.withValues(alpha: 0.9),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: YITheme.inputLabelStyle(context).copyWith(
                  color: accent.withValues(alpha: 0.5),
                  fontSize: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: YITheme.resultEquationStyle(context).copyWith(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onSteps,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_rounded, color: accent, size: 10),
                  const SizedBox(width: 3),
                  Text(
                    'Steps',
                    style: YITheme.inputLabelStyle(context).copyWith(
                      color: accent,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BADGES
  // ───────────────────────────────��─────────────────────────

  Widget _buildBadges(BuildContext context, YIResult result) {
    final badges = <String, String>{
      'Direction': result.direction,
      'Angle': result.angle,
      'Slope': result.slope?.toString() ?? 'Undefined',
    };
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.entries
          .map((e) => _buildBadge(context, e.key, e.value))
          .toList(),
    );
  }

  Widget _buildBadge(BuildContext context, String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: YITheme.emerald(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(YITheme.radiusBadge),
        border: Border.all(
          color: YITheme.emerald(context).withValues(alpha: 0.3),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$key: ', style: YITheme.badgeKeyStyle(context)),
            TextSpan(text: value, style: YITheme.badgeValueStyle(context)),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────���──
  // UTILITIES
  // ─────────────────────────────────────────────────────────

  Widget _buildDivider(BuildContext context) => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              YITheme.emerald(context).withValues(alpha: 0.3),
              Colors.transparent,
            ],
          ),
        ),
      );

  Widget _glow(double size, Color color, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: alpha), Colors.transparent],
          ),
        ),
      );
}
