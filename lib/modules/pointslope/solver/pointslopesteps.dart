import 'package:flutter/material.dart';
import '../Theme/pointslopetheme.dart';
import '../solver/pointslopesolver.dart';

class SolveStepsScreen extends StatefulWidget {
  final PointSlopeSolver solver;
  const SolveStepsScreen({super.key, required this.solver});

  @override
  State<SolveStepsScreen> createState() => _SolveStepsScreenState();
}

class _SolveStepsScreenState extends State<SolveStepsScreen> {
  int _revealed = 1;

  List<SolveStep> get _steps => widget.solver.steps;
  bool get _allRevealed => _revealed >= _steps.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PSTheme.bgDark(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ── Top bar (fixed height) ──
            _buildTopBar(context),

            // ── Step cards (scrollable, takes remaining space) ──
            Expanded(
              child: _steps.isEmpty
                  ? const Center(
                      child: Text(
                        'No steps — check solver import',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      itemCount: _revealed,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _StepCard(
                        step: _steps[i],
                        index: i,
                        total: _steps.length,
                        isActive: i == _revealed - 1,
                      ),
                    ),
            ),

            // ── Bottom nav (fixed height, never expands) ──
            _buildBottomBar(context),

          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PSTheme.bgDark(context),
        border: Border(
          bottom: BorderSide(color: PSTheme.glowViolet(0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: PSTheme.glowPurple(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: PSTheme.glowPurple(0.35), width: 1.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: PSTheme.electricPurple, size: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Step-by-Step Solution',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.solver.pointSlopeEquation,
                  style: const TextStyle(
                    color: Color(0xFFD8B4FE),
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: PSTheme.glowViolet(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: PSTheme.glowViolet(0.3)),
            ),
            child: Text(
              '$_revealed / ${_steps.length}',
              style: const TextStyle(
                color: Color(0xFFE9D5FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom bar: IntrinsicHeight so it never expands beyond its content ──
  Widget _buildBottomBar(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: PSTheme.bgDark(context),
          border: Border(
            top: BorderSide(color: PSTheme.glowViolet(0.2), width: 1),
          ),
        ),
        child: Row(
          children: [
            if (_revealed > 1) ...[
              Expanded(
                child: _NavButton(
                  label: '← Prev',
                  onTap: () => setState(() => _revealed--),
                  primary: false,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              flex: 2,
              child: _allRevealed
                  ? const _NavButton(
                      label: '✓ All steps shown',
                      onTap: null,
                      primary: true,
                    )
                  : _NavButton(
                      label: 'Next step →',
                      onTap: () => setState(() => _revealed++),
                      primary: true,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step card ─────────────────────────────────────────────────────────────────

class _StepCard extends StatelessWidget {
  final SolveStep step;
  final int index;
  final int total;
  final bool isActive;

  const _StepCard({
    required this.step,
    required this.index,
    required this.total,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PSTheme.isLight(context)
            ? (isActive ? const Color(0xFFF3E8FF) : const Color(0xFFFAF5FF))
            : (isActive ? const Color(0xFF1E1133) : const Color(0xFF120D22)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? PSTheme.neonMagenta
              : (PSTheme.isLight(context) ? PSTheme.deepViolet.withValues(alpha: 0.3) : const Color(0xFF4C1D95)),
          width: isActive ? 1.8 : 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Number + title ──
            Row(
              children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF4C1D95),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.title,
                    style: TextStyle(
                      color: PSTheme.isLight(context)
                          ? (isActive ? PSTheme.deepViolet : Colors.black87)
                          : (isActive ? Colors.white : const Color(0xFFD8B4FE)),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${index + 1}/$total',
                  style: const TextStyle(
                    color: Color(0xFF9F7AEA),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Explanation ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF6D28D9).withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                step.explanation,
                style: TextStyle(
                  color: PSTheme.isLight(context) ? Colors.black87 : const Color(0xFFE9D5FF),
                  fontSize: 13.5,
                  height: 1.75,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Result pill ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF5B21B6).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFD946EF).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Color(0xFFF0ABFC), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      step.result,
                      style: TextStyle(
                        color: PSTheme.isLight(context) ? PSTheme.deepViolet : Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
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
}

// ── Nav button ────────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;

  const _NavButton({
    required this.label,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ← explicit height so it never grows to fill parent
        height: 50,
        decoration: BoxDecoration(
          color: primary && enabled
              ? const Color(0xFF7C3AED)
              : const Color(0xFF1E1133),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primary && enabled
                ? const Color(0xFFD946EF)
                : const Color(0xFF4C1D95),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : const Color(0xFF7C3AED),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}