class Exercise {
  final String exerciseId;
  final String name;
  final String targetMuscles;
  final String bodyParts;
  final String equipments;
  final List<String> secondaryMuscles;
  final String gifUrl;
  final List<String> instructions;

  Exercise({
    required this.exerciseId,
    required this.name,
    required this.targetMuscles,
    required this.bodyParts,
    required this.equipments,
    required this.secondaryMuscles,
    required this.gifUrl,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseId: json['exerciseId'] ?? '',
      name: json['name'] ?? '',
      targetMuscles: json['targetMuscles'] ?? '',
      bodyParts: json['bodyParts'] ?? '',
      equipments: json['equipments'] ?? '',
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      gifUrl: json['gifUrl'] ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'name': name,
      'targetMuscles': targetMuscles,
      'bodyParts': bodyParts,
      'equipments': equipments,
      'secondaryMuscles': secondaryMuscles,
      'gifUrl': gifUrl,
      'instructions': instructions,
    };
  }
}
