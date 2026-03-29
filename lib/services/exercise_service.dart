import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/exercise.dart';

class ExerciseService {
  final Auth0 auth0 = Auth0(
    dotenv.env['AUTH0_DOMAIN']!,
    dotenv.env['AUTH0_CLIENT_ID']!,
  );

  String get _baseUrl {
    final String host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    return 'http://$host:8080/api/exercises';
  }

  Future<List<Exercise>> searchExercises(String keyword) async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.get(
        Uri.parse('$_baseUrl/search?keyword=$keyword'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search exercises: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching exercises: $e');
    }
  }

  Future<List<Exercise>> getExercisesByBodypart(String bodypart, {int offset = 0, int limit = 10}) async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.get(
        Uri.parse('$_baseUrl/bodypart?bodypart=$bodypart&offset=$offset&limit=$limit'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Exercise.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch exercises for $bodypart: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching exercises by bodypart: $e');
    }
  }

  Future<List<String>> getAllBodyparts() async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.get(
        Uri.parse('$_baseUrl/bodyparts'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<String>.from(data);
      } else {
        return [
          'neck', 'lower arms', 'shoulders', 'cardio', 'upper arms',
          'chest', 'lower legs', 'back', 'upper legs', 'waist'
        ];
      }
    } catch (e) {
      return [
        'neck', 'lower arms', 'shoulders', 'cardio', 'upper arms',
        'chest', 'lower legs', 'back', 'upper legs', 'waist'
      ];
    }
  }

  Future<List<String>> getAllMuscles() async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.get(
        Uri.parse('$_baseUrl/muscles'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<String>.from(data);
      } else {
        return [
          'back', 'levator scapulae', 'abductors', 'serratus anterior', 'traps',
          'forearms', 'delts', 'biceps', 'upper back', 'spine',
          'cardiovascular system', 'triceps', 'adductors', 'hamstrings', 'glutes',
          'pectorals', 'calves', 'lats', 'quads', 'abs'
        ];
      }
    } catch (e) {
      return [
        'back', 'levator scapulae', 'abductors', 'serratus anterior', 'traps',
        'forearms', 'delts', 'biceps', 'upper back', 'spine',
        'cardiovascular system', 'triceps', 'adductors', 'hamstrings', 'glutes',
        'pectorals', 'calves', 'lats', 'quads', 'abs'
      ];
    }
  }
}
