import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/custom_text_input.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 40),
          _buildSectionTitle(context, 'ACCOUNT'),
          const SizedBox(height: 16),
          const CustomTextInput(
            label: 'FULL NAME',
            hintText: 'John Doe',
            prefixIcon: Icons.person_outline,
          ),
          const SizedBox(height: 24),
          const CustomTextInput(
            label: 'EMAIL',
            hintText: 'john@example.com',
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 48),

          _buildSectionTitle(context, 'PREFERENCES'),
          const SizedBox(height: 16),
          _buildSettingsTile(context, 'Units', 'kg / cm'),
          _buildSettingsTile(context, 'Theme', 'GYM AI Dark'),
          _buildSettingsTile(context, 'Notifications', 'Enabled'),
          const SizedBox(height: 48),

          PrimaryButton(
            text: 'LOG OUT',
            isSecondary: true,
            onPressed: () async {
              try {
                final auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
                await auth0.webAuthentication(scheme: 'aigym').logout();
                await auth0.credentialsManager.clearCredentials();
                if (context.mounted) {
                  Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: $e')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          backgroundImage: const NetworkImage(
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80',
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'John Doe',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Pro Member',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.edit_outlined,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          Row(
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
