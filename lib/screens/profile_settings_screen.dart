import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/custom_text_input.dart';
import '../services/notification_service.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _isMetric = true;
  TimeOfDay? _notificationTime;
  
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _isMetric = prefs.getBool('is_metric') ?? true;
      _weightController.text = prefs.getString('weight') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
      
      final hour = prefs.getInt('notification_hour');
      final minute = prefs.getInt('notification_minute');
      if (hour != null && minute != null) {
        _notificationTime = TimeOfDay(hour: hour, minute: minute);
      }
    });
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
    if (value is int) await prefs.setInt(key, value);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Credentials>(
      future: Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!).credentialsManager.credentials(),
      builder: (context, snapshot) {
        final user = snapshot.data?.user;
        final name = user?.name ?? 'Loading...';
        final email = user?.email ?? 'Loading...';
        final pictureUrl = user?.pictureUrl?.toString() ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=300&q=80';

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
              _buildProfileHeader(context, name, pictureUrl),
              const SizedBox(height: 40),
              _buildSectionTitle(context, 'ACCOUNT'),
              const SizedBox(height: 16),
              CustomTextInput(
                label: 'FULL NAME',
                hintText: name,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 24),
              CustomTextInput(
                label: 'EMAIL',
                hintText: email,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 48),

              _buildSectionTitle(context, 'BODY METRICS'),
              const SizedBox(height: 16),
              CustomTextInput(
                controller: _weightController,
                label: 'WEIGHT (${_isMetric ? 'kg' : 'lbs'})',
                hintText: _isMetric ? 'e.g. 80' : 'e.g. 176',
                prefixIcon: Icons.monitor_weight_outlined,
                onChanged: (val) => _savePreference('weight', val),
              ),
              const SizedBox(height: 24),
              CustomTextInput(
                controller: _heightController,
                label: 'HEIGHT (${_isMetric ? 'cm' : 'in'})',
                hintText: _isMetric ? 'e.g. 180' : 'e.g. 71',
                prefixIcon: Icons.height_outlined,
                onChanged: (val) => _savePreference('height', val),
              ),
              const SizedBox(height: 48),

              _buildSectionTitle(context, 'PREFERENCES'),
              const SizedBox(height: 16),
              _buildSettingsTile(
                context, 
                'Units', 
                _isMetric ? 'kg / cm' : 'lbs / in',
                onTap: () async {
                  setState(() => _isMetric = !_isMetric);
                  await _savePreference('is_metric', _isMetric);
                }
              ),
              _buildToggleTile(
                context, 
                'Notifications', 
                _notificationsEnabled, 
                subtitle: _notificationTime != null && _notificationsEnabled 
                  ? 'Daily at ${_notificationTime!.format(context)}' 
                  : 'Daily Workout Reminder',
                onChanged: (val) async {
                  if (val) {
                    final time = await showTimePicker(
                      context: context, 
                      initialTime: _notificationTime ?? const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (time != null) {
                      await NotificationService().scheduleDailyWorkoutNotification(time);
                      setState(() {
                        _notificationsEnabled = true;
                        _notificationTime = time;
                      });
                      await _savePreference('notifications_enabled', true);
                      await _savePreference('notification_hour', time.hour);
                      await _savePreference('notification_minute', time.minute);
                    }
                  } else {
                    await NotificationService().cancelDailyWorkoutNotification();
                    setState(() {
                      _notificationsEnabled = false;
                    });
                    await _savePreference('notifications_enabled', false);
                  }
                }
              ),
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
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String pictureUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          backgroundImage: NetworkImage(pictureUrl),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
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

  Widget _buildSettingsTile(BuildContext context, String title, String value, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
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
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.swap_horiz,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(BuildContext context, String title, bool value, {String? subtitle, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ]
            ],
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
