import 'package:flutter/material.dart';

class AdjustWorkoutPlanScreen extends StatefulWidget {
  const AdjustWorkoutPlanScreen({super.key});

  @override
  State<AdjustWorkoutPlanScreen> createState() => _AdjustWorkoutPlanScreenState();
}

class _AdjustWorkoutPlanScreenState extends State<AdjustWorkoutPlanScreen> {
  String _searchQuery = '';
  String? _selectedExercise;

  // Mock list of all available exercises in the database
  final List<String> _allExercises = [
    'Barbell Row',
    'Dumbbell Row',
    'Machine Row',
    'T-Bar Row',
    'Seated Cable Row',
    'Pendlay Row',
    'Lat Pulldown',
    'Pull-Up',
    'Chin-Up',
    'Barbell Curl',
    'Dumbbell Curl',
    'Hammer Curl',
    'Preacher Curl',
    'Cable Curl',
    'Bench Press',
    'Incline Dumbbell Press',
    'Push-Up',
    'Overhead Press',
    'Lateral Raise',
    'Back Squat',
    'Leg Press',
    'Romanian Deadlift',
    'Leg Extension',
    'Leg Curl',
  ];

  @override
  Widget build(BuildContext context) {
    // Filter exercises based on search query
    final filteredExercises = _allExercises.where((exercise) {
      return exercise.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap Exercise'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search for any exercise...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Substitute', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 8),
                Text(
                  'Search and select a new exercise from our library to replace the current one.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: filteredExercises.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: Text('No exercises found.')),
                        )
                      : Column(
                          children: filteredExercises.map((exerciseName) {
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
