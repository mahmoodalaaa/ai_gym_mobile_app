import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatService {
  final Auth0 auth0 = Auth0(
    dotenv.env['AUTH0_DOMAIN']!,
    dotenv.env['AUTH0_CLIENT_ID']!,
  );

  String get _baseUrl {
    final String host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    return 'http://$host:8080/api/chat';
  }

  Future<String> sendMessage(String message) async {
    try {
      final credentials = await auth0.credentialsManager.credentials();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
