import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calculus_system/models/developer.dart';
import 'package:calculus_system/theme/theme_provider.dart';
import 'package:calculus_system/widgets/developer_tile.dart';

class DevelopersScreen extends StatefulWidget {
  const DevelopersScreen({super.key});

  @override
  State<DevelopersScreen> createState() => _DevelopersScreenState();
}

class _DevelopersScreenState extends State<DevelopersScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + developers.length * 80),
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Animation<double> _fadeFor(int index) {
    final start = (index * 0.1).clamp(0.0, 0.8);
    final end = (start + 0.25).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
  }

  Animation<Offset> _slideFor(int index) {
    final start = (index * 0.1).clamp(0.0, 0.8);
    final end = (start + 0.3).clamp(0.0, 1.0);
    return Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: theme.surface,
      appBar: AppBar(
        title: const Text('Developers'),
        centerTitle: true,
        backgroundColor: theme.surface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        itemCount: developers.length,
        itemBuilder: (context, index) {
          return FadeTransition(
            opacity: _fadeFor(index),
            child: SlideTransition(
              position: _slideFor(index),
              child: DeveloperTile(
                developer: developers[index],
                index: index,
              ),
            ),
          );
        },
      ),
    );
  }
}
