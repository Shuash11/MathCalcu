// lib/ui/point_slope_screen.dart
import 'package:calculus_system/topics/calculus/midterm/solvers/pointslope_solver/pointslopesolver.dart';
import 'package:calculus_system/shared/widgets/solution_steps_modal.dart';
import 'package:calculus_system/theme/app_design.dart';
import 'pointslopesteps.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:flutter/material.dart';
import 'pointslopesubwidget.dart';
import 'package:calculus_system/shared/widgets/full_screen_graph_screen.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/shared/widgets/accent_glow.dart';

class PointSlopeScreen extends StatefulWidget {
  const PointSlopeScreen({super.key});

  @override
  State<PointSlopeScreen> createState() => _PointSlopeScreenState();
}

class _PointSlopeScreenState extends State<PointSlopeScreen>
    with SingleTickerProviderStateMixin {
  final _mCtrl = TextEditingController();
  final _x1Ctrl = TextEditingController();
  final _y1Ctrl = TextEditingController();
  final _mFocus = FocusNode();
  final _x1Focus = FocusNode();
  final _y1Focus = FocusNode();

  final _resultNotifier = ValueNotifier<_ResultData?>(null);
  final _badgesNotifier = ValueNotifier<Map<String, String>?>(null);
  final _graphStringsNotifier = ValueNotifier<_GraphStrings?>(null);

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  static const double _baseDesignWidth = 400.0;

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
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();

    _mCtrl.dispose();
    _x1Ctrl.dispose();
    _y1Ctrl.dispose();
    _mFocus.dispose();
    _x1Focus.dispose();
    _y1Focus.dispose();

    _resultNotifier.dispose();
    _badgesNotifier.dispose();
    _graphStringsNotifier.dispose();

    super.dispose();
  }

  void _computeResult() {
    final mText = _mCtrl.text.trim();
    final xText = _x1Ctrl.text.trim();
    final yText = _y1Ctrl.text.trim();

    if (mText.isEmpty || xText.isEmpty || yText.isEmpty) {
      _resultNotifier.value = null;
      _badgesNotifier.value = null;
      _graphStringsNotifier.value = null;
      return;
    }

    final solver = PointSlopeSolver.tryParse(
      mText: mText,
      x1Text: xText,
      y1Text: yText,
    );

    if (solver == null) {
      _resultNotifier.value = null;
      _badgesNotifier.value = null;
      _graphStringsNotifier.value = null;
      return;
    }

    final m = solver.m.toDouble();
    final x1 = solver.x1.toDouble();
    final y1 = solver.y1.toDouble();

    _resultNotifier.value = _ResultData(
      pointSlopeEq: solver.pointSlopeForm,
      generalFormEq: solver.generalForm,
      standardFormEq: solver.standardForm,
      m: solver.m.toString(),
      x1: solver.x1.toString(),
      y1: solver.y1.toString(),
      b: solver.b.toString(),
    );

    _graphStringsNotifier.value = _GraphStrings(
      mText: m.toString(),
      xText: x1.toString(),
      yText: y1.toString(),
    );

    _badgesNotifier.value = {
      'direction': solver.direction,
      'angle': solver.angle,
      'riseRun': solver.riseRun,
    };
  }

  void _openStepsModal() {
    final result = _resultNotifier.value;
    if (result == null) return;
    showSolutionStepsModal(
      context: context,
      title: 'Point-Slope Solution',
      design: AppDesign.app,
      child: PointSlopeSteps(
        m: result.m,
        x1: result.x1,
        y1: result.y1,
        b: result.b,
        generalForm: result.generalFormEq,
        standardForm: result.standardFormEq,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.watch<ThemeProvider>().surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double effectiveWidth = constraints.hasInfiniteWidth
                      ? _baseDesignWidth
                      : constraints.maxWidth;
                  final double s =
                      (effectiveWidth / _baseDesignWidth).clamp(0.7, 1.2);

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
                    child: PSCard(
                      s: s,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PSHeader(pulseAnim: _pulseAnim, s: s),
                          SizedBox(height: 20 * s),
                          const PSFormulaBanner(),
                          SizedBox(height: 20 * s),
                          RepaintBoundary(
                            child: PSInputsRow(
                              mCtrl: _mCtrl,
                              x1Ctrl: _x1Ctrl,
                              y1Ctrl: _y1Ctrl,
                              mFocus: _mFocus,
                              x1Focus: _x1Focus,
                              y1Focus: _y1Focus,
                              s: s,
                            ),
                          ),
                          SizedBox(height: 12 * s),
                          GestureDetector(
                            onTap: _computeResult,
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color:
                                    context.watch<ThemeProvider>().accentColor,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [AccentGlow.halo(context)],
                              ),
                              child: Center(
                                child: Text(
                                  'Solve',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        context.watch<ThemeProvider>().isLight
                                            ? Colors.white
                                            : const Color(0xFF1E1E2E),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20 * s),
                          const PSDivider(),
                          SizedBox(height: 20 * s),
                          _PSResultSection(
                            resultNotifier: _resultNotifier,
                            s: s,
                          ),
                          SizedBox(height: 12 * s),
                          ValueListenableBuilder<_ResultData?>(
                            valueListenable: _resultNotifier,
                            builder: (context, result, _) {
                              if (result == null) {
                                return const SizedBox.shrink();
                              }
                              return SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _openStepsModal,
                                  icon: const Icon(
                                    Icons.receipt_long_rounded,
                                    size: 14,
                                    color: const Color(0xFF334155),
                                  ),
                                  label: const Text(
                                    'Show Steps',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: const Color(0xFF334155)
                                          .withValues(alpha: 0.35),
                                    ),
                                    backgroundColor: const Color(0xFF334155)
                                        .withValues(alpha: 0.08),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 14 * s),
                          ValueListenableBuilder<_GraphStrings?>(
                            valueListenable: _graphStringsNotifier,
                            builder: (context, strings, _) {
                              return ValueListenableBuilder<_ResultData?>(
                                valueListenable: _resultNotifier,
                                builder: (context, result, _) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => FullScreenGraphScreen(
                                            title: 'Point-Slope Graph',
                                            graph: PSGraph(
                                              mText: strings?.mText ?? '',
                                              xText: strings?.xText ?? '',
                                              yText: strings?.yText ?? '',
                                              s: 1.0,
                                            ),
                                            formula: result?.pointSlopeEq,
                                            keyInfo: [
                                              if (result != null) ...[
                                                FullScreenInfoItem(
                                                  label: 'Slope',
                                                  value: 'm = ${result.m}',
                                                  color: context
                                                      .watch<ThemeProvider>()
                                                      .accentColor,
                                                ),
                                                FullScreenInfoItem(
                                                  label: 'Point',
                                                  value:
                                                      '(${result.x1}, ${result.y1})',
                                                  color: context
                                                      .watch<ThemeProvider>()
                                                      .accentColor,
                                                ),
                                              ],
                                            ],
                                            accentColor: context
                                                .watch<ThemeProvider>()
                                                .accentColor,
                                          ),
                                        ),
                                      );
                                    },
                                    child: PSGraph(
                                      mText: strings?.mText ?? '',
                                      xText: strings?.xText ?? '',
                                      yText: strings?.yText ?? '',
                                      s: s,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(height: 12 * s),
                          ValueListenableBuilder<Map<String, String>?>(
                            valueListenable: _badgesNotifier,
                            builder: (context, badges, _) {
                              if (badges == null)
                                return const SizedBox.shrink();
                              return PSBadges(
                                direction: badges['direction']!,
                                angle: badges['angle']!,
                                riseRun: badges['riseRun']!,
                                s: s,
                              );
                            },
                          ),
                          SizedBox(height: 16 * s),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = context.watch<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          AccentGlow.iconHalo(
            context,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.accentColor,
                size: 18,
              ),
              style: IconButton.styleFrom(
                backgroundColor: theme.accentColor.withValues(alpha: 0.12),
                foregroundColor: theme.accentColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.accentColor.withValues(alpha: 0.40),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ResponsiveText(
            'Back',
            style: TextStyle(
              fontSize: 13,
              color: theme.accentColor
                  .withValues(alpha: theme.isLight ? 0.7 : 0.5),
              shadows: [
                Shadow(
                  color: theme.accentColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: Offset.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultData {
  final String pointSlopeEq;
  final String generalFormEq;
  final String standardFormEq;
  final String m;
  final String x1;
  final String y1;
  final String b;

  const _ResultData({
    required this.pointSlopeEq,
    required this.generalFormEq,
    required this.standardFormEq,
    required this.m,
    required this.x1,
    required this.y1,
    required this.b,
  });
}

class _GraphStrings {
  final String mText;
  final String xText;
  final String yText;

  const _GraphStrings({
    required this.mText,
    required this.xText,
    required this.yText,
  });

  @override
  bool operator ==(Object other) =>
      other is _GraphStrings &&
      other.mText == mText &&
      other.xText == xText &&
      other.yText == yText;

  @override
  int get hashCode => Object.hash(mText, xText, yText);
}

class _PSResultSection extends StatelessWidget {
  final ValueNotifier<_ResultData?> resultNotifier;
  final double s;

  const _PSResultSection({
    required this.resultNotifier,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_ResultData?>(
      valueListenable: resultNotifier,
      builder: (context, result, _) {
        return PSResultBanner(
          pointSlopeEq: result?.pointSlopeEq,
          generalFormEq: result?.generalFormEq,
          standardFormEq: result?.standardFormEq,
          s: s,
        );
      },
    );
  }
}
