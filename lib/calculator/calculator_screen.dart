import 'package:calculus_system/shared/widgets/accent_glow.dart';
import 'package:calculus_system/shared/widgets/responsive_text.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/calculus/finals/finals_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'calculator_engine.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';
  String _history = '';
  bool _showResult = false;

  void _onButtonTap(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
        _showResult = false;
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        try {
          final eval = CalculatorEngine.evaluate(_expression);
          _history = _expression;
          _result = CalculatorEngine.formatResult(eval);
          _showResult = true;
        } catch (e) {
          _result = 'Error';
          _showResult = true;
        }
      } else if (value == 'Ans') {
        if (_result.isNotEmpty && _result != 'Error') {
          _expression += _result;
          _showResult = false;
        }
      } else {
        if (_showResult) {
          _expression = '';
          _showResult = false;
        }
        _expression += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ResponsiveText(
          'Calculator',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Dynamic spacing: 2px (small), 3px (medium), 4px (large)
            final double buttonSpacing = constraints.maxHeight < 600
                ? 2.0
                : constraints.maxHeight < 700
                    ? 3.0
                    : 4.0;

            // Dynamic button height calculation
            const double verticalPadding = 16.0; // 8 top + 8 bottom
            final double spacingTotal = 7 * buttonSpacing;
            final double availableForContent =
                constraints.maxHeight - verticalPadding - spacingTotal;

            // Display takes ~22%, clamped 50-160px (lower min for tiny test screens)
            final double displayHeight =
                (availableForContent * 0.22).clamp(50.0, 160.0);

            // Button grid gets the rest
            final double buttonGridHeight = availableForContent - displayHeight;
            final double buttonHeight =
                ((buttonGridHeight - spacingTotal) / 8).clamp(44.0, 64.0);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Display - use explicit height
                  SizedBox(
                    height: displayHeight,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: (displayHeight * 0.1).clamp(6.0, 20.0),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            theme.card.withValues(alpha: 0.90),
                            theme.card.withValues(alpha: 0.80),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: theme.accentColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.accentColor.withValues(alpha: 0.10),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: displayHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_history.isNotEmpty) ...[
                              ResponsiveText(
                                _history,
                                style: TextStyle(
                                  fontSize:
                                      (displayHeight * 0.1).clamp(8.0, 12.0),
                                  color: theme.textSecondary,
                                ),
                              ),
                              SizedBox(
                                  height:
                                      (displayHeight * 0.03).clamp(1.0, 4.0)),
                            ],
                            ResponsiveText(
                              _expression.isEmpty ? '0' : _expression,
                              style: TextStyle(
                                fontSize:
                                    (displayHeight * 0.22).clamp(14.0, 24.0),
                                fontWeight: FontWeight.w600,
                                color: theme.textPrimary,
                              ),
                            ),
                            if (_showResult) ...[
                              SizedBox(
                                  height:
                                      (displayHeight * 0.03).clamp(1.0, 4.0)),
                              ResponsiveText(
                                '= $_result',
                                style: TextStyle(
                                  fontSize:
                                      (displayHeight * 0.15).clamp(10.0, 16.0),
                                  fontWeight: FontWeight.w400,
                                  color: theme.accentColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Button grid - use explicit height
                  SizedBox(
                    height: buttonGridHeight,
                    child: Column(
                      children: [
                        _buildButtonRow(['C', '(', ')', '⌫'], theme,
                            buttonSpacing, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        _buildButtonRow(['7', '8', '9', '\u00D7'], theme,
                            buttonSpacing, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        _buildButtonRow(['4', '5', '6', '\u2212'], theme,
                            buttonSpacing, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        _buildButtonRow(['1', '2', '3', '\u221B'], theme,
                            buttonSpacing, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        _buildButtonRow(['0', '.', 'Ans', '+'], theme,
                            buttonSpacing, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        _buildButtonRow(['sin', 'cos', 'tan', '^'], theme,
                            buttonSpacing, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        _buildButtonRow(['log', 'ln', '\u221A', '='], theme,
                            buttonSpacing, buttonHeight),
                        SizedBox(height: buttonSpacing),
                        _buildButtonRow(['\u03C0', 'e', '%', '!'], theme,
                            buttonSpacing, buttonHeight),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons, ThemeProvider theme,
      double spacing, double buttonHeight) {
    return SizedBox(
      height: buttonHeight,
      child: Row(
        children: buttons.map((btn) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: _buildButton(btn, theme),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String value, ThemeProvider theme) {
    final isOperator = ['+', '\u00D7', '\u2212', '\u221B', '='].contains(value);
    final isSpecial = ['C', '⌫', 'Ans'].contains(value);
    final isFunction =
        ['sin', 'cos', 'tan', 'log', 'ln', '\u221A'].contains(value);
    final isConstant = ['\u03C0', 'e'].contains(value);

    Color bgColor;
    Color textColor;
    double fontSize = 20;
    FontWeight fontWeight = FontWeight.w500;

    if (value == '=') {
      bgColor = theme.accentColor;
      textColor = theme.surface;
      fontWeight = FontWeight.w700;
    } else if (isOperator) {
      bgColor = theme.accentColor.withValues(alpha: 0.15);
      textColor = theme.accentColor;
      fontWeight = FontWeight.w600;
    } else if (isSpecial) {
      bgColor = FinalsTheme.danger.withValues(alpha: 0.15);
      textColor = FinalsTheme.danger;
    } else if (isFunction || isConstant) {
      bgColor = theme.cardSecondary;
      textColor = theme.textPrimary;
      fontSize = 16;
    } else {
      bgColor = theme.card;
      textColor = theme.textPrimary;
    }

    void activate() {
      HapticFeedback.lightImpact();
      String insert = value;
      if (value == 'sin' ||
          value == 'cos' ||
          value == 'tan' ||
          value == 'log' ||
          value == 'ln' ||
          value == '\u221A') {
        insert = '$value(';
      } else if (value == '!') {
        insert = '!';
      }
      _onButtonTap(insert);
    }

    return Semantics(
      label: 'Calculator key $value',
      button: true,
      onTap: activate,
      excludeSemantics: true,
      child: GestureDetector(
        excludeFromSemantics: true,
        onTap: activate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value == '='
                  ? theme.accentColor
                  : textColor.withValues(alpha: 0.1),
              width: value == '=' ? 0 : 1,
            ),
            boxShadow: value == '=' ? [AccentGlow.halo(context)] : const [],
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
