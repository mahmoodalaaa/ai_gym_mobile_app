import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:auth0_flutter/auth0_flutter.dart' hide UserProfile;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_profile.dart';

class UserService {
  final Auth0 auth0 = Auth0(
    dotenv.env['AUTH0_DOMAIN']!,
    dotenv.env['AUTH0_CLIENT_ID']!,
  );

  String get _baseUrl {
    final String host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    return 'http://$host:8080/api/user';
  }

  Future<UserProfile> fetchCurrentUser() async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: $e');
    }
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.put(
        Uri.parse('$_baseUrl/me'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
