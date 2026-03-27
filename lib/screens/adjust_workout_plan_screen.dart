import 'package:flutter/material.dart';

class AdjustWorkoutPlanScreen extends StatefulWidget {
  const AdjustWorkoutPlanScreen({super.key});

  @override
  State<AdjustWorkoutPlanScreen> createState() => _AdjustWorkoutPlanScreenState();
}

class _AdjustWorkoutPlanScreenState extends State<AdjustWorkoutPlanScreen> {
  String? _selectedMuscle;
  String? _selectedExercise;

  // Exercise library grouped by muscle
  final Map<String, List<String>> _muscleExercises = {
    'Back': [
      'Barbell Row',
      'Dumbbell Row',
      'Machine Row',
      'T-Bar Row',
      'Seated Cable Row',
      'Pendlay Row',
      'Lat Pulldown',
      'Pull-Up',
      'Chin-Up',
    ],
    'Biceps': [
      'Barbell Curl',
      'Dumbbell Curl',
      'Hammer Curl',
      'Preacher Curl',
      'Cable Curl',
    ],
    'Chest': [
      'Bench Press',
      'Incline Dumbbell Press',
      'Push-Up',
    ],
    'Shoulders': [
      'Overhead Press',
      'Lateral Raise',
    ],
    'Legs': [
      'Back Squat',
      'Leg Press',
      'Romanian Deadlift',
      'Leg Extension',
      'Leg Curl',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap Exercise'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Substitute', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Choose a muscle group first, then select a new exercise to replace the current one.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Muscle Selection Section
          Text(
            'Target Muscle Group',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _muscleExercises.keys.map((muscle) {
              final isSelected = _selectedMuscle == muscle;
              return FilterChip(
                label: Text(muscle),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedMuscle = selected ? muscle : null;
                    _selectedExercise = null; // Reset exercise choice
                  });
                },
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Exercise Selection Section (Animated)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.05),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _selectedMuscle != null
                ? Column(
                    key: ValueKey<String>(_selectedMuscle!),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Exercise',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: _muscleExercises[_selectedMuscle!]!.map((exerciseName) {
                            return RadioListTile<String>(
                              value: exerciseName,
                              groupValue: _selectedExercise,
                              onChanged: (val) {
                                setState(() {
                                  _selectedExercise = val;
                                });
                              },
                              title: Text(exerciseName),
                              activeColor: Theme.of(context).colorScheme.primaryContainer,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  )
                : Center(
                    key: const ValueKey<String>('placeholder'),
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Text(
                        'Select a muscle group to see exercises',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: _selectedExercise == null
                ? null
                : () {
                    Navigator.pop(context, _selectedExercise);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Swapped to $_selectedExercise!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.surface,
              disabledBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              disabledForegroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              'SAVE CHANGES',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
      ),
    );
  }
}
