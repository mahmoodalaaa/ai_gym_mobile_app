import 'package:flutter/material.dart';
import '../core/widgets/primary_button.dart';
import 'active_workout_screen.dart';
import 'enhanced_workout_detail_screen.dart';
import 'adjust_workout_plan_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1000&auto=format&fit=crop',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.5),
                    colorBlendMode: BlendMode.darken,
                  ),
                  Positioned(
                    bottom: 24,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'HYPERTROPHY',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Heavy Back\n& Biceps',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(height: 1.1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildOverviewItem(context, Icons.timer_outlined, '60 MIN'),
                    _buildOverviewItem(
                      context,
                      Icons.fitness_center,
                      '6 MOVES',
                    ),
                    _buildOverviewItem(
                      context,
                      Icons.local_fire_department_outlined,
                      '~450 KCAL',
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                Text(
                  'WARM UP',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildExerciseItem(
                  context,
                  'A',
                  'Lat Pulldown',
                  '3 sets • 12-15 reps',
                ),
                _buildExerciseItem(
                  context,
                  'B',
                  'Face Pulls',
                  '2 sets • 15 reps',
                ),

                const SizedBox(height: 32),
                Text(
                  'MAIN BLOCK',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                _buildExerciseItem(
                  context,
                  'C1',
                  'Barbell Row',
                  '4 sets • 8-10 reps',
                ),
                _buildExerciseItem(
                  context,
                  'C2',
                  'Dumbbell Curl',
                  '4 sets • 10-12 reps',
                ),
                _buildExerciseItem(
                  context,
                  'D',
                  'Seated Cable Row',
                  '3 sets • 12 reps',
                ),

                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'START WORKOUT',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()));
                  },
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(BuildContext context, IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 8),
        Text(text, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }

  Widget _buildExerciseItem(
    BuildContext context,
    String letter,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            onSelected: (value) {
              if (value == 'video') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EnhancedWorkoutDetailScreen()));
              } else if (value == 'adjust') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdjustWorkoutPlanScreen()));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'video',
                child: Text('View Video & Cues'),
              ),
              const PopupMenuItem<String>(
                value: 'adjust',
                child: Text('Adjust Alternative'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
