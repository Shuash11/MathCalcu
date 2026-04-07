// lib/screens/activation_gate.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calculus_system/theme/theme_provider.dart';

class ActivationGate extends StatefulWidget {
  final Widget child; // the actual app content behind the gate

  const ActivationGate({super.key, required this.child});

  @override
  State<ActivationGate> createState() => _ActivationGateState();
}

class _ActivationGateState extends State<ActivationGate>
    with SingleTickerProviderStateMixin {
  bool _activated = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkActivation();
  }

  Future<void> _checkActivation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isActivated = prefs.getBool('app_activated') ?? false;
      if (mounted) {
        setState(() {
          _activated = isActivated;
          _loading = false;
        });
      }
    } catch (e) {
      // If SharedPreferences fails, show the activation screen
      if (mounted) {
        setState(() {
          _activated = false;
          _loading = false;
        });
      }
    }
  }

  Future<void> _onActivated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('app_activated', true);
    if (mounted) {
      setState(() => _activated = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_activated) {
      return widget.child;
    }

    return _ActivationScreen(onSuccess: _onActivated);
  }
}

// ── The lock screen ───────────────────────────────────────────────────────────

class _ActivationScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const _ActivationScreen({required this.onSuccess});

  @override
  State<_ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<_ActivationScreen>
    with TickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _focusNode = FocusNode();

  bool _showError = false;
  bool _obscure = true;
  String _errorMessage = '';

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  static const _accent = Color(0xFF6C63FF);

  @override
  void initState() {
    super.initState();

    // Shake animation for wrong code
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // Fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── CODE VALIDATION ─────────────────────────────────────────────────────
  //
  //  Rules (secret):
  //    • Exactly 9 characters
  //    • First character  → N  (index 0)
  //    • Middle character → T  (index 4)
  //    • Last character   → Z  (index 8)
  //
  //  Examples that work:  NABCTEFGZ, N123T456Z, NxxxxTxxxZ
  //  The user thinks it's a unique one-time key.
  //
  bool _validateCode(String code) {
    if (code.length != 9) return false;

    final upper = code.toUpperCase();
    if (upper[0] != 'N') return false; // first  = N
    if (upper[4] != 'T') return false; // middle = T
    if (upper[8] != 'Z') return false; // last   = Z

    return true;
  }

  void _submit() {
    final code = _codeController.text.trim();

    if (code.isEmpty) {
      _setError('Please enter your activation code');
      return;
    }

    if (code.length != 9) {
      _setError('Activation code must be exactly 9 characters');
      return;
    }

    if (_validateCode(code)) {
      // ── SUCCESS ──
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {
        // Haptic feedback not supported on this platform (e.g., web)
      }
      widget.onSuccess();
    } else {
      // ── WRONG CODE ──
      _setError(
          'Invalid code. Please contact the Lead Developer (Joashua Marl Barimbao).');
      try {
        HapticFeedback.mediumImpact();
      } catch (_) {
        // Haptic feedback not supported on this platform (e.g., web)
      }
      _shakeController.forward(from: 0);
    }
  }

  void _setError(String msg) {
    setState(() {
      _showError = true;
      _errorMessage = msg;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Lock icon ─────────────────────────────────────
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.2),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: _accent,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Title ─────────────────────────────────────────
                    Text(
                      'Activation Required',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Subtitle ──────────────────────────────────────
                    Text(
                      'Enter your one-time activation code\nto unlock MathCalc',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // ── Code input field with error pulse ────────────
                    SizedBox(
                      height: 58,
                      child: AnimatedBuilder(
                        animation: _showError
                            ? _shakeAnimation
                            : AlwaysStoppedAnimation(0),
                        builder: (context, child) {
                          // Use glow effect during error instead of shake
                          final glowIntensity =
                              _showError ? _shakeAnimation.value : 0;
                          return Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _showError
                                    ? Colors.redAccent.withValues(
                                        alpha: 0.3 + (glowIntensity * 0.4))
                                    : Colors.purple.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                if (_showError)
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(
                                        alpha: 0.1 + (glowIntensity * 0.2)),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  )
                                else
                                  BoxShadow(
                                    color:
                                        Colors.purple.withValues(alpha: 0.08),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: TextField(
                          controller: _codeController,
                          focusNode: _focusNode,
                          obscureText: _obscure,
                          maxLength: 9,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                            LengthLimitingTextInputFormatter(9),
                          ],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 6,
                            color: theme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '— — — — —',
                            hintStyle: TextStyle(
                              fontSize: 20,
                              letterSpacing: 4,
                              color: theme.textSecondary.withValues(alpha: 0.3),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color:
                                    theme.textSecondary.withValues(alpha: 0.4),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() => _obscure = !_obscure);
                              },
                            ),
                          ),
                          onChanged: (_) {
                            if (_showError) {
                              setState(() => _showError = false);
                            }
                          },
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                    ),

                    // ── Error message ─────────────────────────────────
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showError ? 32 : 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _showError ? 1 : 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Activate button ───────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Activate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Info box ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _accent.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: _accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Need a code?',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: theme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Contact the Lead Developer\n'
                                  'Joashua Marl Barimbao\n'
                                  'to request your one-time activation code.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.5,
                                    color: theme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _accent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Each code can only be used once',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Version footer ────────────────────────────────
                    Text(
                      'MathCalc v1.0.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textSecondary.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
