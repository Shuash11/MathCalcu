import 'package:calculus_system/topics/calculus/midterm/graph/yintercept_graph/graph.dart';
import 'package:calculus_system/shared/widgets/full_screen_graph_screen.dart';
import 'package:calculus_system/topics/calculus/midterm/solvers/yintercept_solver/yi_solver.dart';
import 'slope_intercept_scr.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';

class YInterceptTab extends StatelessWidget {
  final TextEditingController mCtrl, bCtrl, sfCtrl;
  final FocusNode mFocus, bFocus, sfFocus;
  final InputMode mode;
  final void Function(InputMode) onSwitchMode;
  final VoidCallback onSolve;
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
    required this.mFocus,
    required this.bFocus,
    required this.sfFocus,
    required this.mode,
    required this.onSwitchMode,
    required this.onSolve,
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
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [context.watch<ThemeProvider>().card, context.watch<ThemeProvider>().surface]),
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: const Color(0xFF334155).withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [BoxShadow(color: const Color(0xFF334155).withValues(alpha: context.watch<ThemeProvider>().isLight ? 0.08 : 0.15), blurRadius: 30, offset: const Offset(0, 10)), BoxShadow(color: context.watch<ThemeProvider>().shadowColor, blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Stack(
            children: [
              // Background glows
              Positioned(
                top: -60,
                right: -60,
                child: _glow(200, const Color(0xFF334155), 0.1),
              ),
              Positioned(
                bottom: -40,
                left: -40,
                child: _glow(150, const Color(0xFF334155), 0.08),
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
                                    mFocus,
                                    textInputAction: TextInputAction.next,
                                    onEditingComplete: () => bFocus.requestFocus(),
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
                                    bFocus,
                                    textInputAction: TextInputAction.done,
                                    onEditingComplete: () => bFocus.unfocus(),
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
                              sfFocus,
                              textInputAction: TextInputAction.done,
                              onEditingComplete: () => sfFocus.unfocus(),
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
                                style: TextStyle(fontSize: 13, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.8) : const Color(0xFF334155).withValues(alpha: 0.7), height: 1.3).copyWith(
                                  color: const Color(0xFFFF6B6B),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Solve button
                    GestureDetector(
                      onTap: onSolve,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Solve',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                            const SizedBox(height: 14),
                            GestureDetector(
                              onTap: () {
                                final slope = result.slope?.toDouble();
                                final yInt = result.yIntercept?.toDouble();
                                final xInt = (slope != null && slope != 0 && yInt != null)
                                    ? -yInt / slope
                                    : null;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenGraphScreen(
                                      title: 'Y-Intercept Graph',
                                      formula: 'y = mx + b',
                                      keyInfo: [
                                        if (slope != null)
                                          FullScreenInfoItem(
                                            label: 'Slope (m)',
                                            value: slope.toStringAsFixed(1),
                                            color: context.watch<ThemeProvider>().accentColor,
                                          ),
                                        if (yInt != null)
                                          FullScreenInfoItem(
                                            label: 'Y-intercept (b)',
                                            value: yInt.toStringAsFixed(1),
                                            color: context.watch<ThemeProvider>().accentColor,
                                          ),
                                        if (xInt != null)
                                          FullScreenInfoItem(
                                            label: 'X-intercept',
                                            value: xInt.toStringAsFixed(1),
                                            color: context.watch<ThemeProvider>().accentColor,
                                          ),
                                      ],
                                      accentColor: context.watch<ThemeProvider>().accentColor,
                                       graph: YInterceptGraph(
                                        mText: result.slope != null
                                            ? result.slope!.toDouble().toString()
                                            : '',
                                        bText: result.yIntercept != null
                                            ? result.yIntercept!.toDouble().toString()
                                            : '',
                                        accentColor: context.watch<ThemeProvider>().accentColor,
                                        backgroundColor: context.watch<ThemeProvider>().surface,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: YInterceptGraph(
                                height: 220,
                                mText: result.slope != null
                                    ? result.slope!.toDouble().toString()
                                    : '',
                                bText: result.yIntercept != null
                                    ? result.yIntercept!.toDouble().toString()
                                    : '',
                                accentColor: context.watch<ThemeProvider>().accentColor,
                                backgroundColor: context.watch<ThemeProvider>().surface,
                              ),
                            ),
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

  // ---------------------------------------------------------
  // HEADER SECTION
  // ---------------------------------------------------------

  Widget _buildHeaderSection(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF334155).withValues(alpha: 0.3),
              const Color(0xFF334155).withValues(alpha: 0.2),
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF334155).withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF334155).withValues(alpha: 0.2),
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
                color: const Color(0xFF334155)
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().textPrimary, letterSpacing: -0.5),
                  ),
                  const SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: pulseAnim,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF334155),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF334155)
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
                style: TextStyle(fontSize: 13, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.8) : const Color(0xFF334155).withValues(alpha: 0.7), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // MODE SWITCHER
  // ---------------------------------------------------------

  Widget _buildModeSwitcher(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.2),
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
              ? const Color(0xFF334155).withValues(alpha: 0.15)
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
                  ? const Color(0xFF334155)
                  : const Color(0xFF334155).withValues(alpha: 0.5),
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
                      ? const Color(0xFF334155)
                      : const Color(0xFF334155).withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // FORMULA BANNER
  // ---------------------------------------------------------

  Widget _buildFormulaBanner(BuildContext context) {
    final isSI = mode == InputMode.slopeIntercept;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(mode),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF334155).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF334155).withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          children: [
            Text(
              isSI ? 'SLOPE-INTERCEPT FORM' : 'STANDARD FORM',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2).copyWith(
                color: const Color(0xFF334155).withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 6),
            RichText(
              text: isSI
                  ? TextSpan(
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: context.watch<ThemeProvider>().textPrimary, fontFamily: 'monospace'),
                      children: [
                        const TextSpan(text: 'y = '),
                        TextSpan(
                          text: 'm',
                          style: TextStyle(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: 'x + '),
                        TextSpan(
                          text: 'b',
                          style: TextStyle(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : TextSpan(
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: context.watch<ThemeProvider>().textPrimary, fontFamily: 'monospace'),
                      children: [
                        TextSpan(
                          text: 'A',
                          style: TextStyle(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: 'x + '),
                        TextSpan(
                          text: 'B',
                          style: TextStyle(
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: 'y = '),
                        const TextSpan(
                          text: 'C',
                          style: TextStyle(
                            color: Color(0xFF334155),
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

  // ---------------------------------------------------------
  // INPUT FIELD
  // ---------------------------------------------------------

  Widget _buildInputField(
    BuildContext context,
    String label,
    String variable,
    TextEditingController ctrl,
    String hint,
    FocusNode focusNode, {
    Key? key,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
  }) {
    final isLight = context.watch<ThemeProvider>().isLight;
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('$label  ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2)),
            Text(variable, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155) : const Color(0xFF334155))),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: isLight
                ? Colors.black.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: const Color(0xFF334155).withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: ctrl,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            textInputAction: textInputAction,
            onEditingComplete: onEditingComplete,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: context.watch<ThemeProvider>().textPrimary, fontFamily: 'monospace'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: context.watch<ThemeProvider>().textPrimary, fontFamily: 'monospace').copyWith(
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

  // ---------------------------------------------------------
  // ANSWER CARD
  // ---------------------------------------------------------

  Widget _buildAnswerCard(BuildContext context, YIResult? result) {
    final emerald = const Color(0xFF334155);
    final amber = const Color(0xFF334155);
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
        borderRadius: BorderRadius.circular(16.0),
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
          : const SizedBox.shrink(),
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
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2).copyWith(
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
                const Color(0xFF334155),
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
                const Color(0xFF334155),
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
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2).copyWith(
              color: accent.withValues(alpha: 0.75),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Math.tex(
            r.equation,
            textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155) : const Color(0xFF334155), fontFamily: 'monospace').copyWith(
              color: accent,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _stepsButton(
            accent: accent,
            label: 'View Steps',
            onTap: () => onShowSlopeSteps(r),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // INTERCEPT TILE (with Show Steps button)
  // ---------------------------------------------------------

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
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2).copyWith(
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155) : const Color(0xFF334155), fontFamily: 'monospace').copyWith(
              color: accent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _stepsButton(
            accent: accent,
            label: 'Show Steps',
            onTap: onSteps,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // FORM TILE (display only)
  // ---------------------------------------------------------

  // ---------------------------------------------------------
  // FORM TILE WITH STEPS BUTTON (for Standard and General)
  // ---------------------------------------------------------

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
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2).copyWith(
                  color: accent.withValues(alpha: 0.9),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5), letterSpacing: 1.2).copyWith(
                  color: accent.withValues(alpha: 0.5),
                  fontSize: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155) : const Color(0xFF334155), fontFamily: 'monospace').copyWith(
              color: accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _stepsButton(
            accent: accent,
            label: 'Steps',
            onTap: onSteps,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BADGES
  // -------------------------------??-------------------------

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
        color: const Color(0xFF334155).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: const Color(0xFF334155).withValues(alpha: 0.3),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: '$key: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().isLight ? const Color(0xFF334155).withValues(alpha: 0.7) : const Color(0xFF334155).withValues(alpha: 0.5))),
            TextSpan(text: value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.watch<ThemeProvider>().textPrimary)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------???--
  // UTILITIES
  // ---------------------------------------------------------

  Widget _buildDivider(BuildContext context) => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              const Color(0xFF334155).withValues(alpha: 0.3),
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

  // ---------------------------------------------------------
  // STEPS BUTTON -- shared across intercept tiles (OutlinedButton.icon)
  // ---------------------------------------------------------

  Widget _stepsButton({
    required Color accent,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(Icons.receipt_long_rounded, size: 14, color: accent),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
          backgroundColor: accent.withValues(alpha: 0.08),
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
