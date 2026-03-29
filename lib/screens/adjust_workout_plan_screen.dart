import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_service.dart';

class AdjustWorkoutPlanScreen extends StatefulWidget {
  const AdjustWorkoutPlanScreen({super.key});

  @override
  State<AdjustWorkoutPlanScreen> createState() => _AdjustWorkoutPlanScreenState();
}

class _AdjustWorkoutPlanScreenState extends State<AdjustWorkoutPlanScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  
  String? _selectedBodyPart;
  Exercise? _selectedExercise;
  
  final List<String> _bodyParts = [
    'back',
    'cardio',
    'chest',
    'lower arms',
    'lower legs',
    'neck',
    'shoulders',
    'upper arms',
    'upper legs',
    'waist',
  ];
  List<Exercise> _exercises = [];
  int _offset = 0;
  final int _limit = 10;
  bool _isLoadingExercises = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Body parts are initialized with static data from the API reference
  }

  Future<void> _loadExercises(String bodyPart, {bool loadMore = false}) async {
    if (loadMore && (_isLoadingMore || !_hasMore)) return;

    setState(() {
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoadingExercises = true;
        _exercises = [];
        _offset = 0;
        _hasMore = true;
      }
      _error = null;
    });

    try {
      final newExercises = await _exerciseService.getExercisesByBodypart(
        bodyPart.toLowerCase(),
        offset: _offset,
        limit: _limit,
      );

      setState(() {
        if (loadMore) {
          _exercises.addAll(newExercises);
          _isLoadingMore = false;
        } else {
          _exercises = newExercises;
          _isLoadingExercises = false;
        }
        
        // If we got fewer items than the limit, there are no more to load
        if (newExercises.length < _limit) {
          _hasMore = false;
        }
        
        _offset += newExercises.length;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load exercises for $bodyPart';
        _isLoadingExercises = false;
        _isLoadingMore = false;
      });
    }
  }

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
            'Choose a body part first, then select a new exercise to replace the current one.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Body Part Selection Section
          Text(
            'Target Body Part',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 16),
          if (_error != null && _selectedBodyPart == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<String>(
                value: _selectedBodyPart,
                hint: Text(
                  'Select body part',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                isExpanded: true,
                dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: _bodyParts.map((part) {
                  return DropdownMenuItem<String>(
                    value: part,
                    child: Text(
                      part.split(' ').map((word) {
                        if (word.isEmpty) return word;
                        return word[0].toUpperCase() + word.substring(1).toLowerCase();
                      }).join(' '),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedBodyPart = value;
                      _selectedExercise = null;
                    });
                    _loadExercises(value);
                  }
                },
              ),
            ),
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
            child: _selectedBodyPart != null
                ? Column(
                    key: ValueKey<String>(_selectedBodyPart!),
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
                      if (_isLoadingExercises)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        Text(_error!, style: const TextStyle(color: Colors.red))
                      else if (_exercises.isEmpty)
                        const Text('No exercises found for this body part.')
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              ..._exercises.map((exercise) {
                                return RadioListTile<Exercise>(
                                  value: exercise,
                                  groupValue: _selectedExercise,
                                  onChanged: (val) {
                                    setState(() {
                                      _selectedExercise = val;
                                    });
                                  },
                                  title: Text(exercise.name),
                                  activeColor: Theme.of(context).colorScheme.primaryContainer,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                );
                              }).toList(),
                              if (_hasMore)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: _isLoadingMore
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : TextButton.icon(
                                            onPressed: () => _loadExercises(_selectedBodyPart!, loadMore: true),
                                            icon: const Icon(Icons.add, size: 18),
                                            label: const Text('LOAD MORE'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Theme.of(context).colorScheme.primary,
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.2,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  )
                : Center(
                    key: const ValueKey<String>('placeholder'),
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Text(
                        'Select a body part to see exercises',
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
                        content: Text('Swapped to ${_selectedExercise!.name}!'),
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
