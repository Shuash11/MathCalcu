// lib/Screens/SubScreens/error_section.dart
import 'package:flutter/material.dart';

class CenterErrorSection extends StatelessWidget {
  final String? errorMsg;

  const CenterErrorSection({super.key, required this.errorMsg});

  @override
  Widget build(BuildContext context) {
    if (errorMsg == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMsg!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
