class SetLog {
  double weight;
  int reps;
  bool isCompleted;

  SetLog({
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      weight: (json['weight'] as num).toDouble(),
      reps: (json['reps'] as num).toInt(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }
}

class ExerciseLog {
  final String exerciseName;
  final String? exerciseId;
  final List<SetLog> sets;

  ExerciseLog({
    required this.exerciseName,
    this.exerciseId,
    required this.sets,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    var setsList = json['sets'] as List? ?? [];
    return ExerciseLog(
      exerciseName: json['exerciseName'] ?? '',
      exerciseId: json['exerciseId'],
      sets: setsList.map((s) => SetLog.fromJson(s)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'exerciseId': exerciseId,
      'sets': sets.map((s) => s.toJson()).toList(),
    };
  }
}

class WorkoutSession {
  final String id;
  final String name;
  final DateTime date;
  final int durationMinutes;
  final List<ExerciseLog> exercises;

  WorkoutSession({
    required this.id,
    required this.name,
    required this.date,
    required this.durationMinutes,
    required this.exercises,
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    var exerciseList = json['exercises'] as List? ?? [];
    return WorkoutSession(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      durationMinutes: json['durationMinutes'] ?? 0,
      exercises: exerciseList.map((e) => ExerciseLog.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutTemplate {
  final String id;
  final String name;
  final String category;
  final int estimatedDurationMinutes;
  final List<TemplateExercise> exercises;
  final String imageUrl;

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.estimatedDurationMinutes,
    required this.exercises,
    required this.imageUrl,
  });
}

class TemplateExercise {
  final String name;
  final String? exerciseId;
  final int defaultSets;
  final String defaultRepsRange;
  final String type; // e.g. "Warm up" or "Main block"

  TemplateExercise({
    required this.name,
    this.exerciseId,
    required this.defaultSets,
    required this.defaultRepsRange,
    required this.type,
  });
}

class WeightLog {
  final DateTime date;
  final double weight;

  WeightLog({
    required this.date,
    required this.weight,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      weight: (json['weight'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
    };
  }
}
