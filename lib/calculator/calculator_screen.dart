import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/topics/finals/finals_theme.dart';
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Calculator',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Display
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: FinalsTheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_history.isNotEmpty)
                        Text(
                          _history,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: theme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_showResult) ...[
                        const SizedBox(height: 8),
                        Text(
                          '= $_result',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            color: FinalsTheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Button grid
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildButtonRow(['C', '(', ')', '⌫'], theme),
                    const SizedBox(height: 8),
                    _buildButtonRow(['7', '8', '9', '÷'], theme),
                    const SizedBox(height: 8),
                    _buildButtonRow(['4', '5', '6', '×'], theme),
                    const SizedBox(height: 8),
                    _buildButtonRow(['1', '2', '3', '−'], theme),
                    const SizedBox(height: 8),
                    _buildButtonRow(['0', '.', 'Ans', '+'], theme),
                    const SizedBox(height: 8),
                    _buildButtonRow(['sin', 'cos', 'tan', '^'], theme),
                    const SizedBox(height: 8),
                    _buildButtonRow(['log', 'ln', '√', '='], theme),
                    const SizedBox(height: 8),
                    _buildButtonRow(['π', 'e', '%', '!'], theme),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> buttons, ThemeProvider theme) {
    return Expanded(
      child: Row(
        children: buttons.map((btn) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _buildButton(btn, theme),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildButton(String value, ThemeProvider theme) {
    final isOperator = ['+', '−', '×', '÷', '='].contains(value);
    final isSpecial = ['C', '⌫', 'Ans'].contains(value);
    final isFunction = ['sin', 'cos', 'tan', 'log', 'ln', '√'].contains(value);
    final isConstant = ['π', 'e'].contains(value);

    Color bgColor;
    Color textColor;
    double fontSize = 20;
    FontWeight fontWeight = FontWeight.w500;

    if (value == '=') {
      bgColor = FinalsTheme.primary;
      textColor = Colors.white;
      fontWeight = FontWeight.w700;
    } else if (isOperator) {
      bgColor = FinalsTheme.primary.withValues(alpha: 0.15);
      textColor = FinalsTheme.primary;
      fontWeight = FontWeight.w600;
    } else if (isSpecial) {
      bgColor = FinalsTheme.danger.withValues(alpha: 0.15);
      textColor = FinalsTheme.danger;
    } else if (isFunction || isConstant) {
      bgColor = theme.cardSecondary;
      textColor = FinalsTheme.secondary;
      fontSize = 16;
    } else {
      bgColor = theme.card;
      textColor = theme.textPrimary;
    }

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        String insert = value;
        if (value == 'sin' || value == 'cos' || value == 'tan' ||
            value == 'log' || value == 'ln' || value == '√') {
          insert = '$value(';
        } else if (value == '!') {
          insert = '!';
        }
        _onButtonTap(insert);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value == '='
                ? FinalsTheme.primary
                : textColor.withValues(alpha: 0.1),
            width: value == '=' ? 0 : 1,
          ),
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
    );
  }
}
