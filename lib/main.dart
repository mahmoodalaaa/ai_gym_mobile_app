import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ai Gym Mobile App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Auth0 Integration Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserProfile? _user;
  String? _accessToken;
  String _backendResponse = '';

  late Auth0 auth0;

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    _checkSavedTokens();
  }

  Future<void> _checkSavedTokens() async {
    try {
      if (await auth0.credentialsManager.hasValidCredentials()) {
        final credentials = await auth0.credentialsManager.credentials();
        setState(() {
          _user = credentials.user;
          _accessToken = credentials.accessToken;
        });
        await _fetchBackendUser();
      }
    } catch (e) {
      // No saved credentials or keychain error, show login button
    }
  }

  Future<void> _login() async {
    try {
      final credentials = await auth0
          .webAuthentication(scheme: 'aigym')
          .login(audience: 'https://api.aigym.com');
      setState(() {
        _user = credentials.user;
        _accessToken = credentials.accessToken;
      });
      await _fetchBackendUser();
    } catch (e) {
      setState(() {
        _backendResponse = 'Login failed: $e';
      });
    }
  }

  Future<void> _logout() async {
    try {
      await auth0.webAuthentication(scheme: 'aigym').logout();
      await auth0.credentialsManager.clearCredentials();
      setState(() {
        _user = null;
        _accessToken = null;
        _backendResponse = '';
      });
    } catch (e) {
      setState(() {
        _backendResponse = 'Logout failed: $e';
      });
    }
  }

  Future<void> _fetchBackendUser() async {
    if (_accessToken == null) return;

    final String host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    final uri = Uri.parse('http://$host:8080/api/user/me');

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _backendResponse = 'Backend synced User:\n\n${response.body}';
        });
      } else {
        setState(() {
          _backendResponse =
              'Backend error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _backendResponse =
            'Network error (Try 127.0.0.1 if on iOS or Real Device): $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_user == null)
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login with Auth0'),
                )
              else ...[
                Text('Hello, ${_user!.name ?? _user!.email}!'),
                const SizedBox(height: 10),
                ElevatedButton(onPressed: _logout, child: const Text('Logout')),
                const SizedBox(height: 20),
                const Text(
                  'Backend User Sync Status:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(_backendResponse, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
