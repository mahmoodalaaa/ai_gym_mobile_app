import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double opacity;
  final EdgeInsets padding;
  final bool applyGhostBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24.0,
    this.opacity = 0.6,
    this.padding = const EdgeInsets.all(16.0),
    this.applyGhostBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHigh.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: applyGhostBorder
                ? Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withOpacity(0.15),
                    width: 1,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
