// lib/ui/point_slope_screen.dart
import 'package:calculus_system/modules/pointslope/Theme/pointslopetheme.dart';
import 'package:calculus_system/modules/pointslope/solver/pointslopesolver.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'pointslopesubwidget.dart';
import 'package:calculus_system/modules/pointslope/solver/pointslopesteps.dart';

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

  final _resultNotifier = ValueNotifier<_ResultData?>(null);
  final _badgesNotifier = ValueNotifier<Map<String, String>?>(null);
  final _graphStringsNotifier = ValueNotifier<_GraphStrings?>(null);

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  Timer? _debounceTimer;

  String _lastM = '';
  String _lastX = '';
  String _lastY = '';

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

    _mCtrl.addListener(_onTextChanged);
    _x1Ctrl.addListener(_onTextChanged);
    _y1Ctrl.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _pulseCtrl.dispose();

    _mCtrl.removeListener(_onTextChanged);
    _x1Ctrl.removeListener(_onTextChanged);
    _y1Ctrl.removeListener(_onTextChanged);

    _mCtrl.dispose();
    _x1Ctrl.dispose();
    _y1Ctrl.dispose();

    _resultNotifier.dispose();
    _badgesNotifier.dispose();
    _graphStringsNotifier.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    final mText = _mCtrl.text;
    final xText = _x1Ctrl.text;
    final yText = _y1Ctrl.text;

    if (mText == _lastM && xText == _lastX && yText == _lastY) return;

    _lastM = mText;
    _lastX = xText;
    _lastY = yText;

    if (mText.trim().isEmpty || xText.trim().isEmpty || yText.trim().isEmpty) {
      _debounceTimer?.cancel();
      _resultNotifier.value = null;
      _badgesNotifier.value = null;
      _graphStringsNotifier.value = null;
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), _computeResult);
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

  void _openSteps() {
    if (_resultNotifier.value == null) return;

    final solver = PointSlopeSolver.tryParse(
      mText: _mCtrl.text.trim(),
      x1Text: _x1Ctrl.text.trim(),
      y1Text: _y1Ctrl.text.trim(),
    );

    if (solver == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SolveStepsScreen(solver: solver),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PSTheme.surface(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: PSCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PSHeader(pulseAnim: _pulseAnim),
                      const SizedBox(height: 20),
                      const PSFormulaBanner(),
                      const SizedBox(height: 20),
                      RepaintBoundary(
                        child: PSInputsRow(
                          mCtrl: _mCtrl,
                          x1Ctrl: _x1Ctrl,
                          y1Ctrl: _y1Ctrl,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const PSDivider(),
                      const SizedBox(height: 20),
                      ValueListenableBuilder<_ResultData?>(
                        valueListenable: _resultNotifier,
                        builder: (context, result, _) {
                          return GestureDetector(
                            onTap: result != null ? _openSteps : null,
                            child: PSResultBanner(
                              pointSlopeEq: result?.pointSlopeEq,
                              generalFormEq: result?.generalFormEq,
                              standardFormEq: result?.standardFormEq,
                              tappable: result != null,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      ValueListenableBuilder<_GraphStrings?>(
                        valueListenable: _graphStringsNotifier,
                        builder: (context, strings, _) {
                          return PSGraph(
                            mText: strings?.mText ?? '',
                            xText: strings?.xText ?? '',
                            yText: strings?.yText ?? '',
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<Map<String, String>?>(
                        valueListenable: _badgesNotifier,
                        builder: (context, badges, _) {
                          if (badges == null) return const SizedBox.shrink();
                          return PSBadges(
                            direction: badges['direction']!,
                            angle: badges['angle']!,
                            riseRun: badges['riseRun']!,
                          );
                        },
                      ),
                    ],
                  ),
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
                color: PSTheme.glowPurple(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PSTheme.glowPurple(0.40),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: PSTheme.electricPurple,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('Back', style: PSTheme.subtitleStyle(context)),
        ],
      ),
    );
  }
}

class _ResultData {
  final String pointSlopeEq;
  final String generalFormEq;
  final String standardFormEq;

  const _ResultData({
    required this.pointSlopeEq,
    required this.generalFormEq,
    required this.standardFormEq,
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
