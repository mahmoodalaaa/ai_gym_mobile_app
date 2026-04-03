class UserProfile {
  final int? id;
  final String auth0Id;
  final String email;
  final String? name;
  final double? height;
  final double? weight;
  final int? dailyCalories;
  final int? dailyProtein;
  final int? dailyCarbs;
  final int? dailyFat;

  UserProfile({
    this.id,
    required this.auth0Id,
    required this.email,
    this.name,
    this.height,
    this.weight,
    this.dailyCalories,
    this.dailyProtein,
    this.dailyCarbs,
    this.dailyFat,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      auth0Id: json['auth0Id'],
      email: json['email'],
      name: json['name'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      dailyCalories: json['dailyCalories'],
      dailyProtein: json['dailyProtein'],
      dailyCarbs: json['dailyCarbs'],
      dailyFat: json['dailyFat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'height': height,
      'weight': weight,
      'dailyCalories': dailyCalories,
      'dailyProtein': dailyProtein,
      'dailyCarbs': dailyCarbs,
      'dailyFat': dailyFat,
    };
  }

  UserProfile copyWith({
    String? name,
    double? height,
    double? weight,
    int? dailyCalories,
    int? dailyProtein,
    int? dailyCarbs,
    int? dailyFat,
  }) {
    return UserProfile(
      id: id,
      auth0Id: auth0Id,
      email: email,
      name: name ?? this.name,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProtein: dailyProtein ?? this.dailyProtein,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      dailyFat: dailyFat ?? this.dailyFat,
    );
  }
}
