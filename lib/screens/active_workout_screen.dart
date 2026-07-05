import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/widgets/primary_button.dart';
import '../models/workout_session.dart';
import '../providers/workout_provider.dart';
import 'enhanced_workout_detail_screen.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutTemplate? template;

  const ActiveWorkoutScreen({super.key, this.template});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late WorkoutTemplate _activeTemplate;
  late List<ExerciseLog> _exerciseLogs;
  late DateTime _startTime;
  Timer? _timer;
  int _secondsElapsed = 0;
  String _elapsedTimeString = '00:00';

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    
    // Fetch template or fallback to the first one in the provider
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    _activeTemplate = widget.template ?? provider.templates.first;

    _exerciseLogs = _activeTemplate.exercises.map((te) {
      final reps = _parseReps(te.defaultRepsRange);
      return ExerciseLog(
        exerciseName: te.name,
        exerciseId: te.exerciseId,
        sets: List.generate(
          te.defaultSets,
          (index) => SetLog(weight: 20.0, reps: reps, isCompleted: false),
        ),
      );
    }).toList();

    _startTimer();
  }

  int _parseReps(String repsRange) {
    final clean = repsRange.replaceAll(RegExp(r'[^0-9\-]'), '');
    if (clean.contains('-')) {
      final parts = clean.split('-');
      return int.tryParse(parts.first) ?? 10;
    }
    return int.tryParse(clean) ?? 10;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
          final minutes = _secondsElapsed ~/ 60;
          final seconds = _secondsElapsed % 60;
          _elapsedTimeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _addNewSet(int exerciseIndex) {
    setState(() {
      final lastSet = _exerciseLogs[exerciseIndex].sets.isNotEmpty
          ? _exerciseLogs[exerciseIndex].sets.last
          : SetLog(weight: 20.0, reps: 10);
      _exerciseLogs[exerciseIndex].sets.add(
            SetLog(
              weight: lastSet.weight,
              reps: lastSet.reps,
              isCompleted: false,
            ),
          );
    });
  }

  void _removeLastSet(int exerciseIndex) {
    if (_exerciseLogs[exerciseIndex].sets.isNotEmpty) {
      setState(() {
        _exerciseLogs[exerciseIndex].sets.removeLast();
      });
    }
  }

  void _finishWorkout() {
    // Check if at least one set is completed
    bool hasCompletedSet = false;
    for (var ex in _exerciseLogs) {
      for (var s in ex.sets) {
        if (s.isCompleted) {
          hasCompletedSet = true;
          break;
        }
      }
    }

    if (!hasCompletedSet) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('No Sets Completed'),
          content: const Text('Please complete at least one set before finishing your workout.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final durationMin = (_secondsElapsed / 60).ceil();
    final newSession = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _activeTemplate.name,
      date: DateTime.now(),
      durationMinutes: durationMin,
      exercises: _exerciseLogs,
    );

    // Save workout
    Provider.of<WorkoutProvider>(context, listen: false).addCompletedWorkout(newSession);
    _timer?.cancel();

    // Calculate total stats for the summary
    double totalVol = 0;
    int setsCount = 0;
    for (var ex in _exerciseLogs) {
      for (var s in ex.sets) {
        if (s.isCompleted) {
          totalVol += s.weight * s.reps;
          setsCount++;
        }
      }
    }

    // Success overlay / Congratulatory Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.emoji_events_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'WORKOUT COMPLETE!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Awesome job! You finished ${_activeTemplate.name}.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryStat(context, '${durationMin}m', 'Time'),
                  _buildSummaryStat(context, '$setsCount', 'Sets'),
                  _buildSummaryStat(context, totalVol > 1000 ? '${(totalVol / 1000).toStringAsFixed(1)}k' : '${totalVol.toInt()}', 'Volume (kg)'),
                ],
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'BACK TO DASHBOARD',
                onPressed: () {
                  Navigator.pop(context); // Pop Dialog
                  Navigator.pop(context); // Pop Active Workout Screen
                  Navigator.pop(context); // Pop Workout Details Screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
                          title: const Text('Cancel Workout?'),
                          content: const Text('Are you sure you want to cancel? Your progress for this session will be lost.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Keep Training', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context); // Pop Alert
                                Navigator.pop(context); // Pop Active Workout Screen
                              },
                              child: const Text('Cancel Workout', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                  ),
                  Text(
                    _activeTemplate.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _elapsedTimeString,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Exercises List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                itemCount: _exerciseLogs.length,
                itemBuilder: (context, exIndex) {
                  final exLog = _exerciseLogs[exIndex];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Exercise Name & Header
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${exIndex + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                exLog.exerciseName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              tooltip: 'View Details & Video',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EnhancedWorkoutDetailScreen(
                                      exerciseName: exLog.exerciseName,
                                      type: '${exIndex + 1}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Sets Header
                        Row(
                          children: [
                            const SizedBox(width: 40, child: Text('SET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                            const Expanded(child: Text('WEIGHT (KG)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center)),
                            const Expanded(child: Text('REPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center)),
                            const SizedBox(width: 50, child: Text('DONE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1),
                        const SizedBox(height: 8),

                        // Sets list
                        ...exLog.sets.asMap().entries.map((setEntry) {
                          final setIndex = setEntry.key;
                          final setLog = setEntry.value;
                          final rowKey = ValueKey('ex_${exIndex}_set_$setIndex');

                          return Padding(
                            key: rowKey,
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: Row(
                              children: [
                                // Set Number
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    '${setIndex + 1}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: setLog.isCompleted
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),

                                // Weight Input
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TextFormField(
                                      initialValue: setLog.weight.toString(),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      textAlign: TextAlign.center,
                                      enabled: !setLog.isCompleted,
                                      style: TextStyle(
                                        color: setLog.isCompleted ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                        filled: true,
                                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      ),
                                      onChanged: (val) {
                                        setLog.weight = double.tryParse(val) ?? 0.0;
                                      },
                                    ),
                                  ),
                                ),

                                // Reps Input
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: TextFormField(
                                      initialValue: setLog.reps.toString(),
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      enabled: !setLog.isCompleted,
                                      style: TextStyle(
                                        color: setLog.isCompleted ? Colors.grey : Theme.of(context).colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                        filled: true,
                                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                      ),
                                      onChanged: (val) {
                                        setLog.reps = int.tryParse(val) ?? 0;
                                      },
                                    ),
                                  ),
                                ),

                                // Completion Checkbox Button
                                Container(
                                  width: 50,
                                  alignment: Alignment.center,
                                  child: IconButton(
                                    icon: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: setLog.isCompleted
                                            ? Theme.of(context).colorScheme.primary
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: setLog.isCompleted
                                              ? Theme.of(context).colorScheme.primary
                                              : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 16,
                                        color: setLog.isCompleted
                                            ? Theme.of(context).colorScheme.onPrimary
                                            : Colors.transparent,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        setLog.isCompleted = !setLog.isCompleted;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 12),
                        // Add/Remove set buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _removeLastSet(exIndex),
                              icon: const Icon(Icons.remove, size: 16, color: Colors.redAccent),
                              label: const Text('Delete Set', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _addNewSet(exIndex),
                              icon: Icon(Icons.add, size: 16, color: Theme.of(context).colorScheme.primary),
                              label: Text('Add Set', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 13)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2))),
        ),
        child: PrimaryButton(
          text: 'FINISH WORKOUT',
          onPressed: _finishWorkout,
        ),
      ),
    );
  }
}
