import 'package:flutter/material.dart';
import '../core/widgets/primary_button.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background representing the active exercise
          Image.network(
            'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1000&auto=format&fit=crop',
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.6),
            colorBlendMode: BlendMode.darken,
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          '12:45',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Exercise Details
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Theme.of(context).colorScheme.background,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.3],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video icon indicator
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'SET 2 OF 4',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 2,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Barbell Back Squat',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 32),

                      // Reps & Weight
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatColumn(context, 'Reps', '8'),
                          Container(
                            width: 1,
                            height: 40,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          _buildStatColumn(context, 'Target', '100 kg'),
                          Container(
                            width: 1,
                            height: 40,
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          _buildStatColumn(context, 'Rest', '90s'),
                        ],
                      ),
                      const SizedBox(height: 48),

                      PrimaryButton(text: 'COMPLETE SET', onPressed: () {}),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}
