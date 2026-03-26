import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/widgets/primary_button.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late Auth0 auth0;
  bool _isLoading = true; // Wait for initial credential check!

  @override
  void initState() {
    super.initState();
    auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
    _checkSavedTokens();
  }

  Future<void> _checkSavedTokens() async {
    try {
      if (await auth0.credentialsManager.hasValidCredentials()) {
        final credentials = await auth0.credentialsManager.credentials(); // Ensure it actually fetches/refreshes
        
        // Optional Backend Sync:
        final String host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
        final uri = Uri.parse('http://$host:8080/api/user/me');
        await http.get(uri, headers: {'Authorization': 'Bearer ${credentials.accessToken}'});

        if (mounted) {
           Navigator.pushReplacementNamed(context, '/dashboard');
           return;
        }
      }
    } catch (e) {
      // Ignore or log error
      debugPrint('Auth Check Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final credentials = await auth0
          .webAuthentication(scheme: 'aigym')
          .login(audience: 'https://api.aigym.com');
          
      // Backend Sync
      final String host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
      final uri = Uri.parse('http://$host:8080/api/user/me');
      await http.get(uri, headers: {'Authorization': 'Bearer ${credentials.accessToken}'});

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.network(
            'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=2069&auto=format&fit=crop',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.6),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Theme.of(context).colorScheme.surface,
              );
            },
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // App Title / Logo
                  Text(
                    'KINETIX',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  // Editorial Headline
                  Text(
                    'FORGE\nYOUR\nLEGACY.',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'High-octane training for the focused athlete.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 48),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    // Primary Action
                    PrimaryButton(
                      text: 'GET STARTED',
                      onPressed: _login,
                    ),
                    const SizedBox(height: 16),
                    // Secondary Action
                    PrimaryButton(
                      text: 'LOG IN',
                      isSecondary: true,
                      onPressed: _login,
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
