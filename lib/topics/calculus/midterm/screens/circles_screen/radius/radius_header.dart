import 'package:flutter/material.dart';

class RadiusHeader extends StatelessWidget {
  const RadiusHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF334155).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF334155).withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: const Color(0xFF334155),
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [const Color(0xFF334155), const Color(0xFF334155)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.radio_button_unchecked,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Finding the Radius',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE8E8F0),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Distance formula method',
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
