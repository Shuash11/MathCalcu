// lib/Screens/SubScreens/header_bar.dart
import 'package:flutter/material.dart';
import '../../Theme/centertheme.dart';

class CenterHeaderBar extends StatelessWidget {
  const CenterHeaderBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: FindingCenterTheme.indigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FindingCenterTheme.indigo.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: FindingCenterTheme.indigo,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [FindingCenterTheme.indigo, FindingCenterTheme.purple],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.adjust_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Finding the Center',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: FindingCenterTheme.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Midpoint formula method',
                style: TextStyle(
                  fontSize: 13,
                  color: FindingCenterTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}