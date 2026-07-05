import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/widgets/primary_button.dart';
import '../models/workout_session.dart';
import '../providers/workout_provider.dart';
import 'active_workout_screen.dart';
import 'enhanced_workout_detail_screen.dart';
import 'adjust_workout_plan_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final WorkoutTemplate? template;

  const WorkoutDetailScreen({super.key, this.template});

  @override
  Widget build(BuildContext context) {
    final activeTemplate = template ?? Provider.of<WorkoutProvider>(context, listen: false).templates.first;
    
    final warmUps = activeTemplate.exercises.where((e) => e.type == 'WARM UP').toList();
    final mainBlock = activeTemplate.exercises.where((e) => e.type == 'MAIN BLOCK').toList();

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
                    activeTemplate.imageUrl,
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
                            activeTemplate.category,
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
                          activeTemplate.name.replaceAll(' & ', '\n& '),
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
                    _buildOverviewItem(context, Icons.timer_outlined, '${activeTemplate.estimatedDurationMinutes} MIN'),
                    _buildOverviewItem(
                      context,
                      Icons.fitness_center,
                      '${activeTemplate.exercises.length} MOVES',
                    ),
                    _buildOverviewItem(
                      context,
                      Icons.local_fire_department_outlined,
                      '~450 KCAL',
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                if (warmUps.isNotEmpty) ...[
                  Text(
                    'WARM UP',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...warmUps.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ex = entry.value;
                    final letter = String.fromCharCode(65 + index); // A, B, C...
                    return _buildExerciseItem(
                      context,
                      letter,
                      ex.name,
                      '${ex.defaultSets} sets • ${ex.defaultRepsRange} reps',
                    );
                  }),
                  const SizedBox(height: 32),
                ],

                if (mainBlock.isNotEmpty) ...[
                  Text(
                    'MAIN BLOCK',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...mainBlock.asMap().entries.map((entry) {
                    final index = entry.key;
                    final ex = entry.value;
                    final letter = 'C${index + 1}';
                    return _buildExerciseItem(
                      context,
                      letter,
                      ex.name,
                      '${ex.defaultSets} sets • ${ex.defaultRepsRange} reps',
                    );
                  }),
                  const SizedBox(height: 40),
                ],

                PrimaryButton(
                  text: 'START WORKOUT',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ActiveWorkoutScreen(template: activeTemplate),
                      ),
                    );
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
          IconButton(
            icon: Icon(
              Icons.play_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            tooltip: 'View Video & Details',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnhancedWorkoutDetailScreen(
                    exerciseName: title,
                    type: letter,
                  ),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            onSelected: (value) {
              if (value == 'video') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EnhancedWorkoutDetailScreen(
                      exerciseName: title,
                      type: letter,
                    ),
                  ),
                );
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
