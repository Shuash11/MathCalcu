import 'package:calculus_system/modules/y-intercept/solver/fraction.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../theme/theme_provider.dart';
import '../Theme/theme.dart';
import '../solver/y-intercpet_solver.dart';
import '../solver/parallel_perpendicular.dart';
import '../Graph/graph.dart';

// ─────────────────────────────────────────────────────────────
// Top-level screen tab
// ─────────────────────────────────────────────────────────────
enum _ScreenTab { yIntercept, parallelPerpendicular }

// ─────────────────────────────────────────────────────────────
// Y-Intercept input mode
// ─────────────────────────────────────────────────────────────
enum _InputMode { slopeIntercept, standardForm }

class YInterceptScreen extends StatefulWidget {
  const YInterceptScreen({super.key});

  @override
  State<YInterceptScreen> createState() => _YInterceptScreenState();
}

class _YInterceptScreenState extends State<YInterceptScreen>
    with SingleTickerProviderStateMixin {
  // ── Top tab ──────────────────────────────────────────────
  _ScreenTab _screenTab = _ScreenTab.yIntercept;

  // ── Y-Intercept controllers ───────────────────────────────
  final _mCtrl = TextEditingController();
  final _bCtrl = TextEditingController();
  final _sfCtrl = TextEditingController();
  _InputMode _yiMode = _InputMode.slopeIntercept;
  final _yiResultNotifier = ValueNotifier<YIResult?>(null);
  final _yiErrorNotifier = ValueNotifier<String?>(null);
  Timer? _yiDebounce;

  // ── Parallel/Perp controllers ─────────────────────────────
  final _l1Ctrl = TextEditingController();
  final _l2Ctrl = TextEditingController();
  final _ppResultNotifier = ValueNotifier<PPResult?>(null);
  final _ppErrorNotifier = ValueNotifier<String?>(null);
  Timer? _ppDebounce;

  // ── Animation ────────────────────────────────────────────
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _mCtrl.addListener(_onYIChanged);
    _bCtrl.addListener(_onYIChanged);
    _sfCtrl.addListener(_onYIChanged);
    _l1Ctrl.addListener(_onPPChanged);
    _l2Ctrl.addListener(_onPPChanged);
  }

  @override
  void dispose() {
    _yiDebounce?.cancel();
    _ppDebounce?.cancel();
    _pulseCtrl.dispose();
    for (final c in [_mCtrl, _bCtrl, _sfCtrl]) {
      c.removeListener(_onYIChanged);
      c.dispose();
    }
    for (final c in [_l1Ctrl, _l2Ctrl]) {
      c.removeListener(_onPPChanged);
      c.dispose();
    }
    _yiResultNotifier.dispose();
    _yiErrorNotifier.dispose();
    _ppResultNotifier.dispose();
    _ppErrorNotifier.dispose();
    super.dispose();
  }

  // ── Y-Intercept logic ─────────────────────────────────────

  void _onYIChanged() {
    _yiDebounce?.cancel();
    _yiDebounce = Timer(const Duration(milliseconds: 500), _computeYIResult);
  }

  void _switchYIMode(_InputMode mode) {
    if (_yiMode == mode) return;
    setState(() {
      _yiMode = mode;
      _yiResultNotifier.value = null;
      _yiErrorNotifier.value = null;
    });
  }

  void _computeYIResult() {
    if (_yiMode == _InputMode.slopeIntercept) {
      final mText = _mCtrl.text.trim();
      final bText = _bCtrl.text.trim();
      if (mText.isEmpty || bText.isEmpty) {
        _yiResultNotifier.value = null;
        _yiErrorNotifier.value = null;
        return;
      }
      final r =
          YInterceptSolver.tryParseSlopeIntercept(mText: mText, bText: bText);
      if (r == null) {
        _yiErrorNotifier.value =
            'Invalid input — use numbers or fractions like 3/4';
        _yiResultNotifier.value = null;
      } else {
        _yiErrorNotifier.value = null;
        _yiResultNotifier.value = r;
      }
    } else {
      final text = _sfCtrl.text.trim();
      if (text.isEmpty) {
        _yiResultNotifier.value = null;
        _yiErrorNotifier.value = null;
        return;
      }
      final r = YInterceptSolver.tryParseStandardForm(text);
      if (r == null) {
        _yiErrorNotifier.value =
            'Invalid format — try something like  6x - 3y = -3';
        _yiResultNotifier.value = null;
      } else {
        _yiErrorNotifier.value = null;
        _yiResultNotifier.value = r;
      }
    }
  }

  // ── Parallel/Perp logic ───────────────────────────────────

  void _onPPChanged() {
    _ppDebounce?.cancel();
    _ppDebounce = Timer(const Duration(milliseconds: 500), _computePPResult);
  }

  void _computePPResult() {
    final t1 = _l1Ctrl.text.trim();
    final t2 = _l2Ctrl.text.trim();
    if (t1.isEmpty || t2.isEmpty) {
      _ppResultNotifier.value = null;
      _ppErrorNotifier.value = null;
      return;
    }
    final r = ParallelPerpendicularSolver.tryParse(line1: t1, line2: t2);
    if (r == null) {
      _ppErrorNotifier.value =
          'Invalid format — try  3x + 5y + 7 = 0  or  5x - 3y = 2';
      _ppResultNotifier.value = null;
    } else {
      _ppErrorNotifier.value = null;
      _ppResultNotifier.value = r;
    }
  }

  // ── Steps bottom sheet ────────────────────────────────────

  void _showSteps(List<dynamic> steps, String cardTitle, Color accentColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StepsSheet(
        steps: steps,
        cardTitle: cardTitle,
        accentColor: accentColor,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YITheme.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildScreenTabSwitcher(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: _screenTab == _ScreenTab.yIntercept
                    ? _YInterceptTab(
                        key: const ValueKey(_ScreenTab.yIntercept),
                        mCtrl: _mCtrl,
                        bCtrl: _bCtrl,
                        sfCtrl: _sfCtrl,
                        mode: _yiMode,
                        onSwitchMode: _switchYIMode,
                        resultNotifier: _yiResultNotifier,
                        errorNotifier: _yiErrorNotifier,
                        pulseAnim: _pulseAnim,
                        onShowSteps: _showSteps,
                      )
                    : _PPTab(
                        key: const ValueKey(_ScreenTab.parallelPerpendicular),
                        l1Ctrl: _l1Ctrl,
                        l2Ctrl: _l2Ctrl,
                        resultNotifier: _ppResultNotifier,
                        errorNotifier: _ppErrorNotifier,
                        pulseAnim: _pulseAnim,
                        onShowSteps: _showSteps,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: YITheme.emerald(context).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: YITheme.emerald(context).withValues(alpha: 0.4),
                    width: 1.5),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: YITheme.emerald(context), size: 18),
            ),
          ),
          const SizedBox(width: 12),
          Text('Back', style: YITheme.subtitleStyle(context)),
        ],
      ),
    );
  }

  Widget _buildScreenTabSwitcher() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: YITheme.emerald(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
            color: YITheme.emerald(context).withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _screenTabBtn('Y-Intercept', Icons.trending_up_rounded,
                _ScreenTab.yIntercept),
          ),
          Expanded(
            child: _screenTabBtn('Parallel & Perpendicular',
                Icons.compare_arrows_rounded, _ScreenTab.parallelPerpendicular),
          ),
        ],
      ),
    );
  }

  Widget _screenTabBtn(String label, IconData icon, _ScreenTab tab) {
    final isActive = _screenTab == tab;
    return GestureDetector(
      onTap: () {
        if (_screenTab != tab) setState(() => _screenTab = tab);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isActive
              ? YITheme.emerald(context).withValues(alpha: 0.22)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(
                  color: YITheme.emerald(context).withValues(alpha: 0.5),
                  width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 15,
                color: isActive
                    ? YITheme.mint(context)
                    : YITheme.mint(context).withValues(alpha: 0.4)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: YITheme.inputLabelStyle(context).copyWith(
                  color: isActive
                      ? YITheme.mint(context)
                      : YITheme.mint(context).withValues(alpha: 0.4),
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ═════════════════════════════════════════════════════════════
// Y-INTERCEPT TAB
// ═════════════════════════════════════════════════════════════

class _YInterceptTab extends StatelessWidget {
  final TextEditingController mCtrl, bCtrl, sfCtrl;
  final _InputMode mode;
  final void Function(_InputMode) onSwitchMode;
  final ValueNotifier<YIResult?> resultNotifier;
  final ValueNotifier<String?> errorNotifier;
  final Animation<double> pulseAnim;
  final void Function(List<dynamic>, String, Color) onShowSteps;

  const _YInterceptTab({
    super.key,
    required this.mCtrl,
    required this.bCtrl,
    required this.sfCtrl,
    required this.mode,
    required this.onSwitchMode,
    required this.resultNotifier,
    required this.errorNotifier,
    required this.pulseAnim,
    required this.onShowSteps,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: YITheme.cardGradient(context),
          borderRadius: BorderRadius.circular(YITheme.radiusCard),
          border: Border.all(
              color: YITheme.emerald(context).withValues(alpha: 0.25),
              width: 1.5),
          boxShadow: YITheme.cardShadow(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(YITheme.radiusCard),
          child: Stack(children: [
            Positioned(
                top: -60,
                right: -60,
                child: _glow(200, YITheme.emerald(context), 0.1)),
            Positioned(
                bottom: -40,
                left: -40,
                child: _glow(150, YITheme.gold(context), 0.08)),
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
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, anim) =>
                          FadeTransition(opacity: anim, child: child),
                      child: mode == _InputMode.slopeIntercept
                          ? Row(
                              key: const ValueKey(_InputMode.slopeIntercept),
                              children: [
                                Expanded(
                                    child: _field(
                                        context, 'SLOPE', 'm', mCtrl, '0',
                                        isNumber: true)),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: _field(
                                        context, 'Y-INTERCEPT', 'b', bCtrl, '0',
                                        isNumber: true)),
                              ],
                            )
                          : _field(context, 'EQUATION', 'Ax + By = C', sfCtrl,
                              '6x - 3y = -3',
                              isNumber: false,
                              key: const ValueKey(_InputMode.standardForm)),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<String?>(
                      valueListenable: errorNotifier,
                      builder: (_, err, __) => err == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(err,
                                  style: YITheme.subtitleStyle(context)
                                      .copyWith(
                                          color: const Color(0xFFFF6B6B))),
                            ),
                    ),
                    _buildDivider(context),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<YIResult?>(
                      valueListenable: resultNotifier,
                      builder: (context, result, _) => Column(children: [
                        _eqCard(
                            context,
                            'SLOPE-INTERCEPT FORM',
                            result?.equation,
                            YITheme.gold(context),
                            result?.steps),
                        const SizedBox(height: 10),
                        _eqCard(context, 'STANDARD FORM', result?.standardForm,
                            YITheme.mint(context), result?.steps),
                        const SizedBox(height: 10),
                        _eqCard(context, 'GENERAL FORM', result?.generalForm,
                            const Color(0xFF7EB8F7), result?.steps),
                      ]),
                    ),
                    const SizedBox(height: 14),
                    ValueListenableBuilder<YIResult?>(
                      valueListenable: resultNotifier,
                      builder: (context, result, _) => YInterceptGraph(
                        mText: result?.slope?.toDouble().toString() ?? '',
                        bText: result?.yIntercept?.toDouble().toString() ?? '',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildBadges(context),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Row(children: [
      Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            YITheme.emerald(context).withValues(alpha: 0.3),
            YITheme.emerald(context)
                .withValues(alpha: 0.2), // forestGreen removed
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: YITheme.mint(context).withValues(alpha: 0.4), width: 2),
          boxShadow: [
            BoxShadow(
                color: YITheme.emerald(context).withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Icon(Icons.trending_up_rounded,
                color: YITheme.mint(context)
                    .withValues(alpha: 0.8 + pulseAnim.value * 0.2),
                size: 26),
          ),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('Y-Intercept Form', style: YITheme.titleStyle(context)),
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
                        spreadRadius: pulseAnim.value * 2)
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 3),
          Text(
            mode == _InputMode.slopeIntercept
                ? 'Enter slope and y-intercept directly'
                : 'Enter a standard form equation',
            style: YITheme.subtitleStyle(context),
          ),
        ]),
      ),
    ]);
  }

  Widget _buildModeSwitcher(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: YITheme.emerald(context).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: YITheme.emerald(context).withValues(alpha: 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeTab(context, 'Slope-Intercept', Icons.functions_rounded,
                _InputMode.slopeIntercept),
          ),
          Expanded(
            child: _modeTab(context, 'Standard Form',
                Icons.linear_scale_rounded, _InputMode.standardForm),
          ),
        ],
      ),
    );
  }

  Widget _modeTab(
      BuildContext context, String label, IconData icon, _InputMode tabMode) {
    final isSelected =
        mode == tabMode; // Use 'mode' from the widget, not '_currentMode'

    return GestureDetector(
      onTap: () => onSwitchMode(tabMode), // Use the callback, not setState
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

  Widget _buildFormulaBanner(BuildContext context) {
    final isSI = mode == _InputMode.slopeIntercept;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(mode),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: YITheme.emerald(context).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: YITheme.emerald(context).withValues(alpha: 0.25)),
        ),
        child: Column(children: [
          Text(isSI ? 'SLOPE-INTERCEPT FORM' : 'STANDARD FORM',
              style: YITheme.inputLabelStyle(context).copyWith(
                  color: YITheme.mint(context).withValues(alpha: 0.6))),
          const SizedBox(height: 6),
          RichText(
            text: isSI
                ? TextSpan(style: YITheme.formulaStyle(context), children: [
                    const TextSpan(text: 'y = '),
                    TextSpan(
                        text: 'm',
                        style: TextStyle(
                            color: YITheme.mint(context),
                            fontWeight: FontWeight.w700)),
                    const TextSpan(text: 'x + '),
                    TextSpan(
                        text: 'b',
                        style: TextStyle(
                            color: YITheme.gold(context),
                            fontWeight: FontWeight.w700)),
                  ])
                : TextSpan(style: YITheme.formulaStyle(context), children: [
                    TextSpan(
                        text: 'A',
                        style: TextStyle(
                            color: YITheme.mint(context),
                            fontWeight: FontWeight.w700)),
                    const TextSpan(text: 'x + '),
                    TextSpan(
                        text: 'B',
                        style: TextStyle(
                            color: YITheme.gold(context),
                            fontWeight: FontWeight.w700)),
                    const TextSpan(text: 'y = '),
                    const TextSpan(
                        text: 'C',
                        style: TextStyle(
                            color: Color(0xFF7EB8F7),
                            fontWeight: FontWeight.w700)),
                  ]),
          ),
        ]),
      ),
    );
  }

//for the keyboard ni
  Widget _field(BuildContext context, String label, String variable,
      TextEditingController ctrl, String hint,
      {required bool isNumber, Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('$label  ', style: YITheme.inputLabelStyle(context)),
          Text(variable, style: YITheme.inputVarStyle(context)),
        ]),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: context.watch<ThemeProvider>().isLight
                ? Colors.black.withValues(alpha: 0.03)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(YITheme.radiusInput),
            border: Border.all(
                color: YITheme.emerald(context).withValues(alpha: 0.2),
                width: 1.5),
          ),
          child: TextField(
            controller: ctrl,
            // Changed: Always use text keyboard to allow fractions like 3/4, -5/2, etc.
            keyboardType: TextInputType.text,
            style: YITheme.inputTextStyle(context),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: YITheme.inputTextStyle(context).copyWith(
                  color: context.watch<ThemeProvider>().isLight
                      ? Colors.black.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.2)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _eqCard(BuildContext context, String label, String? value,
      Color accent, List<YISolverStep>? steps) {
    final has = value != null;
    return GestureDetector(
      onTap:
          has && steps != null ? () => onShowSteps(steps, label, accent) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: has
                  ? [
                      accent.withValues(alpha: 0.13),
                      accent.withValues(alpha: 0.05)
                    ]
                  : [
                      YITheme.emerald(context).withValues(alpha: 0.05),
                      Colors.transparent
                    ]),
          borderRadius: BorderRadius.circular(YITheme.radiusInner),
          border: Border.all(
              color: has
                  ? accent.withValues(alpha: 0.45)
                  : YITheme.emerald(context).withValues(alpha: 0.2),
              width: 1.5),
          boxShadow: has
              ? [
                  BoxShadow(
                      color: accent.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 1)
                ]
              : null,
        ),
        child: Row(children: [
          Expanded(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: YITheme.inputLabelStyle(context).copyWith(
                          color: has
                              ? accent.withValues(alpha: 0.8)
                              : YITheme.mint(context).withValues(alpha: 0.4))),
                  const SizedBox(height: 6),
                  has
                      ? Text(value, style: YITheme.resultEquationStyle(context))
                      : Text('Enter values above',
                          style: YITheme.subtitleStyle(context)),
                ]),
          ),
          if (has) ...[
            const SizedBox(width: 10),
            Column(children: [
              Icon(Icons.receipt_long_rounded,
                  color: accent.withValues(alpha: 0.6), size: 16),
              const SizedBox(height: 2),
              Text('Steps',
                  style: YITheme.inputLabelStyle(context).copyWith(
                      color: accent.withValues(alpha: 0.6), fontSize: 9)),
            ]),
          ],
        ]),
      ),
    );
  }

  Widget _buildBadges(BuildContext context) {
    return ValueListenableBuilder<YIResult?>(
      valueListenable: resultNotifier,
      builder: (context, result, _) {
        if (result == null) return const SizedBox.shrink();
        final badges = <String, String>{
          'Direction': result.direction,
          'Angle': result.angle,
          'Slope': result.slope?.toString() ?? 'Undefined',
        };
        if (result.xIntercept != null) {
          badges['x-intercept'] = result.xIntercept.toString();
        }
        if (result.yIntercept != null) {
          badges['y-intercept'] = result.yIntercept.toString();
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: badges.entries
              .map((e) => _badge(context, e.key, e.value))
              .toList(),
        );
      },
    );
  }

  Widget _badge(BuildContext context, String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: YITheme.emerald(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(YITheme.radiusBadge),
        border:
            Border.all(color: YITheme.emerald(context).withValues(alpha: 0.3)),
      ),
      child: RichText(
          text: TextSpan(children: [
        TextSpan(text: '$key: ', style: YITheme.badgeKeyStyle(context)),
        TextSpan(text: value, style: YITheme.badgeValueStyle(context)),
      ])),
    );
  }

  Widget _buildDivider(BuildContext context) => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            YITheme.emerald(context).withValues(alpha: 0.3),
            Colors.transparent,
          ]),
        ),
      );

  Widget _glow(double size, Color color, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withValues(alpha: alpha), Colors.transparent]),
        ),
      );
}

// ═════════════════════════════════════════════════════════════
// PARALLEL / PERPENDICULAR TAB
// ═════════════════════════════════════════════════════════════

class _PPTab extends StatelessWidget {
  final TextEditingController l1Ctrl, l2Ctrl;
  final ValueNotifier<PPResult?> resultNotifier;
  final ValueNotifier<String?> errorNotifier;
  final Animation<double> pulseAnim;
  final void Function(List<dynamic>, String, Color) onShowSteps;

  const _PPTab({
    super.key,
    required this.l1Ctrl,
    required this.l2Ctrl,
    required this.resultNotifier,
    required this.errorNotifier,
    required this.pulseAnim,
    required this.onShowSteps,
  });

  static Color _verdictColor(BuildContext context, PPRelationship? r) {
    switch (r) {
      case PPRelationship.parallel:
        return const Color(0xFF7EB8F7);
      case PPRelationship.perpendicular:
        return YITheme.gold(context);
      case PPRelationship.sameLine:
        return const Color(0xFFB47EF7);
      case PPRelationship.neither:
        return const Color(0xFFFF8C69);
      case null:
        return YITheme.emerald(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: YITheme.cardGradient(context),
          borderRadius: BorderRadius.circular(YITheme.radiusCard),
          border: Border.all(
              color: YITheme.emerald(context).withValues(alpha: 0.25),
              width: 1.5),
          boxShadow: YITheme.cardShadow(context),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(YITheme.radiusCard),
          child: Stack(children: [
            Positioned(
                top: -60,
                right: -60,
                child: _glow(200, YITheme.emerald(context), 0.1)),
            Positioned(
                bottom: -40,
                left: -40,
                child: _glow(150, const Color(0xFF7EB8F7), 0.08)),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 20),
                    _buildFormulaBanner(context),
                    const SizedBox(height: 20),
                    _lineInput(
                        context, 'LINE 1', 'L1', l1Ctrl, '3x + 5y + 7 = 0',
                        accent: YITheme.mint(context)),
                    const SizedBox(height: 14),
                    _lineInput(
                        context, 'LINE 2', 'L2', l2Ctrl, '5x - 3y - 2 = 0',
                        accent: const Color(0xFF7EB8F7)),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<String?>(
                      valueListenable: errorNotifier,
                      builder: (_, err, __) => err == null
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(err,
                                  style: YITheme.subtitleStyle(context)
                                      .copyWith(
                                          color: const Color(0xFFFF6B6B))),
                            ),
                    ),
                    _buildDivider(context),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<PPResult?>(
                      valueListenable: resultNotifier,
                      builder: (context, result, _) {
                        final accent =
                            _verdictColor(context, result?.relationship);
                        return Column(children: [
                          _verdictCard(context, result, accent),
                          if (result != null) ...[
                            const SizedBox(height: 10),
                            _slopeCard(
                                context,
                                'LINE 1',
                                result.slopeIntercept1,
                                result.slope1,
                                YITheme.mint(context),
                                result.steps),
                            const SizedBox(height: 10),
                            _slopeCard(
                                context,
                                'LINE 2',
                                result.slopeIntercept2,
                                result.slope2,
                                const Color(0xFF7EB8F7),
                                result.steps),
                          ],
                        ]);
                      },
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              const Color(0xFF7EB8F7).withValues(alpha: 0.3),
              YITheme.emerald(context).withValues(alpha: 0.2),
            ]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: const Color(0xFF7EB8F7).withValues(alpha: 0.4),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF7EB8F7).withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: pulseAnim,
              builder: (_, __) => Icon(Icons.compare_arrows_rounded,
                  color: const Color(0xFF7EB8F7)
                      .withValues(alpha: 0.8 + pulseAnim.value * 0.2),
                  size: 26),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Prevent column from expanding
            children: [
              Row(
                children: [
                  // Wrap title in Expanded + Flexible to prevent overflow
                  Expanded(
                    child: Text(
                      'Parallel & Perpendicular',
                      style: YITheme.titleStyle(context),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: pulseAnim,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7EB8F7),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFF7EB8F7)
                                  .withValues(alpha: pulseAnim.value),
                              blurRadius: pulseAnim.value * 14,
                              spreadRadius: pulseAnim.value * 2)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'Enter two lines to compare',
                style: YITheme.subtitleStyle(context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormulaBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: YITheme.emerald(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: YITheme.emerald(context).withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        _fChip(context, '∥ Parallel', 'm₁ = m₂', YITheme.mint(context)),
        Container(
            width: 1,
            height: 36,
            color: YITheme.emerald(context).withValues(alpha: 0.25)),
        _fChip(
            context, '⊥ Perpendicular', 'm₁ × m₂ = −1', YITheme.gold(context)),
      ]),
    );
  }

  Widget _fChip(
      BuildContext context, String label, String formula, Color color) {
    return Column(children: [
      Text(label,
          style: YITheme.inputLabelStyle(context)
              .copyWith(color: color.withValues(alpha: 0.7))),
      const SizedBox(height: 4),
      Text(formula,
          style: YITheme.formulaStyle(context).copyWith(fontSize: 13)),
    ]);
  }

  Widget _lineInput(BuildContext context, String label, String prefix,
      TextEditingController ctrl, String hint,
      {required Color accent}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
          ),
          child: Text(prefix,
              style: YITheme.inputLabelStyle(context)
                  .copyWith(color: accent, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 8),
        Text(label, style: YITheme.inputLabelStyle(context)),
      ]),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: context.watch<ThemeProvider>().isLight
              ? Colors.black.withValues(alpha: 0.03)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(YITheme.radiusInput),
          border: Border.all(color: accent.withValues(alpha: 0.25), width: 1.5),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.text,
          style: YITheme.inputTextStyle(context),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: YITheme.inputTextStyle(context).copyWith(
                color: context.watch<ThemeProvider>().isLight
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.2)),
          ),
        ),
      ),
    ]);
  }

  Widget _verdictCard(BuildContext context, PPResult? result, Color accent) {
    final has = result != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: has ? accent.withValues(alpha: 0.08) : Colors.transparent,
        gradient: LinearGradient(
            colors: has
                ? [
                    accent.withValues(alpha: 0.18),
                    accent.withValues(alpha: 0.06)
                  ]
                : [
                    YITheme.emerald(context).withValues(alpha: 0.05),
                    Colors.transparent
                  ]),
        borderRadius: BorderRadius.circular(YITheme.radiusInner),
        border: Border.all(
            color: has
                ? accent.withValues(alpha: 0.55)
                : YITheme.emerald(context).withValues(alpha: 0.2),
            width: 1.5),
        boxShadow: has
            ? [
                BoxShadow(
                    color: accent.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2)
              ]
            : null,
      ),
      child: has
          ? Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: accent.withValues(alpha: 0.45), width: 1.5),
                ),
                child: Center(
                  child: Text(result.verdictSymbol,
                      style: TextStyle(
                          color: accent,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VERDICT',
                          style: YITheme.inputLabelStyle(context)
                              .copyWith(color: accent.withValues(alpha: 0.7))),
                      const SizedBox(height: 4),
                      Text(result.verdict,
                          style: YITheme.resultEquationStyle(context)
                              .copyWith(color: accent)),
                    ]),
              ),
              GestureDetector(
                onTap: () =>
                    onShowSteps(result.steps, 'Solution Steps', accent),
                child: Column(children: [
                  Icon(Icons.receipt_long_rounded,
                      color: accent.withValues(alpha: 0.7), size: 18),
                  const SizedBox(height: 2),
                  Text('Steps',
                      style: YITheme.inputLabelStyle(context).copyWith(
                          color: accent.withValues(alpha: 0.7), fontSize: 9)),
                ]),
              ),
            ])
          : Column(children: [
              Text('VERDICT',
                  style: YITheme.inputLabelStyle(context).copyWith(
                      color: YITheme.mint(context).withValues(alpha: 0.4))),
              const SizedBox(height: 8),
              Text('Enter both lines above',
                  style: YITheme.subtitleStyle(context)),
            ]),
    );
  }

  Widget _slopeCard(BuildContext context, String label, String siEq,
      YIFraction? slope, Color accent, List<PPSolverStep> steps) {
    return GestureDetector(
      onTap: () => onShowSteps(steps, 'Solution Steps', accent),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(YITheme.radiusInner),
          border: Border.all(color: accent.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border:
                  Border.all(color: accent.withValues(alpha: 0.35), width: 1),
            ),
            child: Text(label,
                style: YITheme.inputLabelStyle(context).copyWith(
                    color: accent, fontWeight: FontWeight.w700, fontSize: 9)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(siEq,
                  style: YITheme.resultEquationStyle(context)
                      .copyWith(fontSize: 13)),
              const SizedBox(height: 2),
              Text(
                slope != null ? 'm = $slope' : 'm = undefined (vertical)',
                style: YITheme.subtitleStyle(context)
                    .copyWith(color: accent.withValues(alpha: 0.7)),
              ),
            ]),
          ),
          Icon(Icons.receipt_long_rounded,
              color: accent.withValues(alpha: 0.4), size: 14),
        ]),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            YITheme.emerald(context).withValues(alpha: 0.3),
            Colors.transparent,
          ]),
        ),
      );

  Widget _glow(double size, Color color, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
              colors: [color.withValues(alpha: alpha), Colors.transparent]),
        ),
      );
}

// ═════════════════════════════════════════════════════════════
// SHARED: Steps bottom sheet
// ═════════════════════════════════════════════════════════════

class _StepsSheet extends StatelessWidget {
  final List<dynamic> steps;
  final String cardTitle;
  final Color accentColor;

  const _StepsSheet({
    required this.steps,
    required this.cardTitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.94,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: YITheme.surface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
                color: accentColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 32,
                  spreadRadius: 4)
            ],
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: Column(children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.receipt_long_rounded,
                        color: accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Solution Steps',
                              style: YITheme.titleStyle(context)
                                  .copyWith(fontSize: 16)),
                          const SizedBox(height: 2),
                          Text(cardTitle,
                              style: YITheme.inputLabelStyle(context).copyWith(
                                  color: accentColor.withValues(alpha: 0.7))),
                        ]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: YITheme.textSecondary(context)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.close_rounded,
                          color: YITheme.textSecondary(context)
                              .withValues(alpha: 0.5),
                          size: 16),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.transparent,
                      accentColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                itemCount: steps.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _StepCard(step: steps[i], accentColor: accentColor),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step card — duck-typed, works for both solver step types
// ─────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final dynamic step;
  final Color accentColor;

  const _StepCard({required this.step, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final num = step.number as int;
    final title = step.title as String;
    final formula = step.formula as String;
    final sub = step.substitution as String;
    final res = step.result as String;
    final expl = step.explanation as String;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                  color: accentColor.withValues(alpha: 0.45), width: 1),
            ),
            child: Center(
              child: Text('$num',
                  style: TextStyle(
                      color: accentColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: YITheme.inputLabelStyle(context).copyWith(
                    color: accentColor.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600)),
          ),
        ]),
        if (formula.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(formula,
                style: YITheme.subtitleStyle(context).copyWith(
                    fontFamily: 'monospace',
                    color:
                        YITheme.textSecondary(context).withValues(alpha: 0.7),
                    fontSize: 11)),
          ),
        ],
        if (sub.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(sub,
              style: YITheme.subtitleStyle(context).copyWith(
                  color: YITheme.textSecondary(context).withValues(alpha: 0.6),
                  fontSize: 12)),
        ],
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: accentColor.withValues(alpha: 0.3)),
          ),
          child: Text(res,
              style: YITheme.resultEquationStyle(context)
                  .copyWith(fontSize: 14, color: accentColor)),
        ),
        if (expl.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(expl,
              style: YITheme.subtitleStyle(context).copyWith(
                  fontSize: 11,
                  color: YITheme.textSecondary(context).withValues(alpha: 0.4),
                  fontStyle: FontStyle.italic)),
        ],
      ]),
    );
  }
}
