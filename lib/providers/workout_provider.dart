import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auth0_flutter/auth0_flutter.dart' hide UserProfile;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/workout_session.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

class WorkoutProvider with ChangeNotifier {
  List<WorkoutTemplate> _templates = [];
  List<WorkoutSession> _completedWorkouts = [];
  List<WeightLog> _weightHistory = [];
  bool _isLoading = true;

  List<WorkoutTemplate> get templates => _templates;
  List<WorkoutSession> get completedWorkouts => _completedWorkouts;
  List<WeightLog> get weightHistory => _weightHistory;
  bool get isLoading => _isLoading;

  final Auth0 auth0 = Auth0(
    dotenv.env['AUTH0_DOMAIN']!,
    dotenv.env['AUTH0_CLIENT_ID']!,
  );

  String get _baseUrl {
    final String host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    return 'http://$host:8080/api';
  }

  WorkoutProvider() {
    _initData();
  }

  Future<void> _initData() async {
    _templates = [
      WorkoutTemplate(
        id: 'back_biceps',
        name: 'Heavy Back & Biceps',
        category: 'HYPERTROPHY',
        estimatedDurationMinutes: 60,
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800&auto=format&fit=crop',
        exercises: [
          TemplateExercise(name: 'Lat Pulldown', defaultSets: 3, defaultRepsRange: '12-15', type: 'WARM UP'),
          TemplateExercise(name: 'Face Pulls', defaultSets: 2, defaultRepsRange: '15', type: 'WARM UP'),
          TemplateExercise(name: 'Barbell Row', defaultSets: 4, defaultRepsRange: '8-10', type: 'MAIN BLOCK'),
          TemplateExercise(name: 'Dumbbell Curl', defaultSets: 4, defaultRepsRange: '10-12', type: 'MAIN BLOCK'),
          TemplateExercise(name: 'Seated Cable Row', defaultSets: 3, defaultRepsRange: '12', type: 'MAIN BLOCK'),
        ],
      ),
      WorkoutTemplate(
        id: 'legs_core',
        name: 'Legs & Core',
        category: 'STRENGTH',
        estimatedDurationMinutes: 75,
        imageUrl: 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=800&auto=format&fit=crop',
        exercises: [
          TemplateExercise(name: 'Barbell Squat', defaultSets: 3, defaultRepsRange: '10', type: 'WARM UP'),
          TemplateExercise(name: 'Leg Press', defaultSets: 4, defaultRepsRange: '10-12', type: 'MAIN BLOCK'),
          TemplateExercise(name: 'Romanian Deadlift', defaultSets: 4, defaultRepsRange: '8-10', type: 'MAIN BLOCK'),
          TemplateExercise(name: 'Standing Calf Raises', defaultSets: 4, defaultRepsRange: '15', type: 'MAIN BLOCK'),
          TemplateExercise(name: 'Hanging Leg Raises', defaultSets: 3, defaultRepsRange: '15', type: 'MAIN BLOCK'),
        ],
      ),
      WorkoutTemplate(
        id: 'chest_shoulders',
        name: 'Chest & Shoulders',
        category: 'HYPERTROPHY',
        estimatedDurationMinutes: 65,
        imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?q=80&w=800&auto=format&fit=crop',
        exercises: [
          TemplateExercise(name: 'Incline Dumbbell Press', defaultSets: 3, defaultRepsRange: '10', type: 'WARM UP'),
          TemplateExercise(name: 'Flat Bench Press', defaultSets: 4, defaultRepsRange: '8-10', type: 'MAIN BLOCK'),
          TemplateExercise(name: 'Overhead Press', defaultSets: 3, defaultRepsRange: '8-10', type: 'MAIN BLOCK'),
          TemplateExercise(name: 'Lateral Raises', defaultSets: 4, defaultRepsRange: '12-15', type: 'MAIN BLOCK'),
          TemplateExercise(name: 'Cable Crossover', defaultSets: 3, defaultRepsRange: '12', type: 'MAIN BLOCK'),
        ],
      ),
    ];
    await loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load workouts from cache first
      final workoutsString = prefs.getString('completed_workouts');
      if (workoutsString != null) {
        final List<dynamic> decoded = jsonDecode(workoutsString);
        _completedWorkouts = decoded.map((w) => WorkoutSession.fromJson(w)).toList();
      }

      // Load weight history from cache first
      final weightString = prefs.getString('weight_history');
      if (weightString != null) {
        final List<dynamic> decoded = jsonDecode(weightString);
        _weightHistory = decoded.map((w) => WeightLog.fromJson(w)).toList();
      }

      _isLoading = false;
      notifyListeners();

      // Fetch from API in background to update cache
      _fetchFromBackend();
    } catch (e) {
      debugPrint('Error loading workout data from prefs: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchFromBackend() async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final headers = {
        'Authorization': 'Bearer ${credentials.accessToken}',
        'Content-Type': 'application/json',
      };

      // Fetch workouts
      final workoutsResponse = await http.get(Uri.parse('$_baseUrl/workouts'), headers: headers);
      if (workoutsResponse.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(workoutsResponse.body);
        _completedWorkouts = decoded.map((w) => WorkoutSession.fromJson(w)).toList();
        await saveWorkoutsToPrefs();
      }

      // Fetch weight logs
      final weightResponse = await http.get(Uri.parse('$_baseUrl/user/weight'), headers: headers);
      if (weightResponse.statusCode == 200) {
        final List<dynamic> decoded = jsonDecode(weightResponse.body);
        _weightHistory = decoded.map((w) => WeightLog.fromJson(w)).toList();
        await saveWeightsToPrefs();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch workout/weight data from backend: $e');
    }
  }

  Future<void> saveWorkoutsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_completedWorkouts.map((w) => w.toJson()).toList());
    await prefs.setString('completed_workouts', encoded);
  }

  Future<void> saveWeightsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_weightHistory.map((w) => w.toJson()).toList());
    await prefs.setString('weight_history', encoded);
  }

  Future<void> addCompletedWorkout(WorkoutSession session) async {
    // Add locally immediately
    _completedWorkouts.insert(0, session);
    await saveWorkoutsToPrefs();
    notifyListeners();

    // Sync to backend
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.post(
        Uri.parse('$_baseUrl/workouts'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(session.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        // Replace temp session with database session
        final index = _completedWorkouts.indexWhere((w) => w.id == session.id);
        if (index != -1) {
          _completedWorkouts[index] = WorkoutSession.fromJson(body);
          await saveWorkoutsToPrefs();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Failed to sync workout to backend: $e');
    }
  }

  Future<void> logWeight(double weight, {UserProfile? currentProfile}) async {
    // Add locally immediately
    _weightHistory.insert(0, WeightLog(date: DateTime.now(), weight: weight));
    await saveWeightsToPrefs();
    notifyListeners();

    // Sync to backend
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.post(
        Uri.parse('$_baseUrl/user/weight'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'weight': weight,
          'date': DateTime.now().toIso8601String(),
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        // Replace temp log with database log
        if (_weightHistory.isNotEmpty) {
          _weightHistory[0] = WeightLog.fromJson(body);
          await saveWeightsToPrefs();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Failed to sync weight update to backend: $e');
    }
  }

  // Statistics Helper Functions
  double get totalVolume {
    double total = 0.0;
    for (var session in _completedWorkouts) {
      for (var exercise in session.exercises) {
        for (var set in exercise.sets) {
          if (set.isCompleted) {
            total += set.weight * set.reps;
          }
        }
      }
    }
    return total;
  }

  int get completedWorkoutsCount => _completedWorkouts.length;

  int get totalSetsCompleted {
    int total = 0;
    for (var session in _completedWorkouts) {
      for (var exercise in session.exercises) {
        total += exercise.sets.where((s) => s.isCompleted).length;
      }
    }
    return total;
  }

  // Volume by day for the past 7 days (e.g. Mon to Sun)
  Map<int, double> getPastSevenDaysVolume() {
    final Map<int, double> volumeMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    final now = DateTime.now();
    
    for (var session in _completedWorkouts) {
      final difference = now.difference(session.date).inDays;
      if (difference < 7) {
        double sessionVolume = 0;
        for (var exercise in session.exercises) {
          for (var set in exercise.sets) {
            if (set.isCompleted) {
              sessionVolume += set.weight * set.reps;
            }
          }
        }
        int weekday = session.date.weekday;
        volumeMap[weekday] = (volumeMap[weekday] ?? 0) + sessionVolume;
      }
    }
    return volumeMap;
  }

  // Trained days for consistency in the current week (Monday=1 to Sunday=7)
  Set<int> getWeeklyTrainedDays() {
    final Set<int> trainedDays = {};
    final now = DateTime.now();
    // Start of current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    for (var session in _completedWorkouts) {
      if (session.date.isAfter(startOfDay)) {
        trainedDays.add(session.date.weekday);
      }
    }
    return trainedDays;
  }
}
