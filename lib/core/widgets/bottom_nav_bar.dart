import 'package:flutter/material.dart';
import 'glass_card.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, icon: Icons.home_outlined, index: 0),
            _buildNavItem(context, icon: Icons.analytics_outlined, index: 1),
            _buildNavItem(context, icon: Icons.smart_toy_outlined, index: 2),
            _buildNavItem(context, icon: Icons.person_outline, index: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required int index,
  }) {
    final isActive = currentIndex == index;
    final color = isActive
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          if (isActive)
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          else
            const SizedBox(height: 4), // Placeholder to maintain height
        ],
      ),
    );
  }
}
