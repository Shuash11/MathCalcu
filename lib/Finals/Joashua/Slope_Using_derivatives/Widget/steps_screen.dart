import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Solver/steps.dart';
import 'package:calculus_system/Finals/Joashua/Slope_Using_derivatives/Widget/steps_items_widget.dart';
import 'package:flutter/material.dart';

import 'package:calculus_system/Finals/finals_theme.dart';




class StepsScreen extends StatelessWidget {
  final ClassroomSolution solution;
  const StepsScreen({super.key, required this.solution});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinalsTheme.surface(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: FinalsTheme.danger.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: FinalsTheme.danger.withValues(alpha: 0.3)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: FinalsTheme.danger),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          solution.problemTitle,
                          style: TextStyle(
                            color: FinalsTheme.textPrimary(context), 
                            fontWeight: FontWeight.w800, 
                            fontSize: 20,
                            letterSpacing: -0.4
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: FinalsTheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: FinalsTheme.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            solution.type.name.toUpperCase(),
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: FinalsTheme.primary.withValues(alpha: 0.8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StepItemWidget(step: solution.steps[index]),
                  );
                },
                childCount: solution.steps.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}