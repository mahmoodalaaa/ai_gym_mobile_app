import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart' hide UserProfile;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/custom_text_input.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

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
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();

  UserProfile? _profile;
  bool _isLoading = true;
  Timer? _debounceTimer;
  String? _pictureUrl;
  String? _displayName;
  String? _displayEmail;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userService = UserService();
      
      final auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
      final credentials = await auth0.credentialsManager.credentials();
      final user = credentials.user;
      
      final profile = await userService.fetchCurrentUser();

      if (profile.email == 'temp-email@domain.com' && user.email != null) {
        final syncedProfile = profile.copyWith(email: user.email);
        userService.updateProfile(syncedProfile).catchError((e) {
          debugPrint('Silent sync failed: $e');
          return profile;
        });
      }

      setState(() {
        _profile = profile;
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
        _isMetric = prefs.getBool('is_metric') ?? true;
        _pictureUrl = user.pictureUrl?.toString();
        _displayName = user.name ?? profile.name ?? 'User';
        _displayEmail = user.email ?? profile.email;
        
        _weightController.text = profile.weight?.toString() ?? '';
        _heightController.text = profile.height?.toString() ?? '';
        _caloriesController.text = profile.dailyCalories?.toString() ?? '';
        _proteinController.text = profile.dailyProtein?.toString() ?? '';
        _carbsController.text = profile.dailyCarbs?.toString() ?? '';
        _fatController.text = profile.dailyFat?.toString() ?? '';
        
        final hour = prefs.getInt('notification_hour');
        final minute = prefs.getInt('notification_minute');
        if (hour != null && minute != null) {
          _notificationTime = TimeOfDay(hour: hour, minute: minute);
        }
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _onFieldChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      _autoSaveProfile();
    });
  }

  Future<void> _autoSaveProfile() async {
    if (_profile == null) return;
    try {
      final updatedProfile = _profile!.copyWith(
        weight: double.tryParse(_weightController.text),
        height: double.tryParse(_heightController.text),
        dailyCalories: int.tryParse(_caloriesController.text),
        dailyProtein: int.tryParse(_proteinController.text),
        dailyCarbs: int.tryParse(_carbsController.text),
        dailyFat: int.tryParse(_fatController.text),
      );
      await UserService().updateProfile(updatedProfile);
      _profile = updatedProfile;
    } catch (e) {
      debugPrint('Auto-save failed: $e');
    }
  }

  Future<void> _savePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is int) await prefs.setInt(key, value);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _weightController.dispose();
    _heightController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Hub'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 48),

          _buildSectionTitle(context, 'HEALTH & NUTRITION'),
          const SizedBox(height: 16),
          _buildMacroInputs(),
          const SizedBox(height: 24),
          _buildBodyMetricsInputs(),

          const SizedBox(height: 48),
          _buildSectionTitle(context, 'APP PREFERENCES'),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context, 
            'Units of Measure', 
            _isMetric ? 'Metric (kg/cm)' : 'Imperial (lbs/in)',
            icon: Icons.straighten,
            onTap: () async {
              setState(() => _isMetric = !_isMetric);
              await _savePreference('is_metric', _isMetric);
            }
          ),
          _buildToggleTile(
            context, 
            'Push Notifications', 
            _notificationsEnabled, 
            icon: Icons.notifications_none,
            subtitle: _notificationTime != null && _notificationsEnabled 
              ? 'Reminder at ${_notificationTime!.format(context)}' 
              : 'Daily Workout Reminders',
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
                setState(() => _notificationsEnabled = false);
                await _savePreference('notifications_enabled', false);
              }
            }
          ),

          const SizedBox(height: 48),
          _buildSectionTitle(context, 'SUPPORT & LEGAL'),
          const SizedBox(height: 16),
          _buildActionTile(context, 'Help Center', Icons.help_outline, () => _showComingSoon(context, 'Support')),
          _buildActionTile(context, 'Terms of Service', Icons.description_outlined, () => _showComingSoon(context, 'Terms')),
          _buildActionTile(context, 'Privacy Policy', Icons.privacy_tip_outlined, () => _showComingSoon(context, 'Privacy')),
          _buildActionTile(context, 'Contact Us', Icons.mail_outline, () => _showComingSoon(context, 'Contact')),

          const SizedBox(height: 48),
          _buildSectionTitle(context, 'DANGER ZONE'),
          const SizedBox(height: 16),
          _buildActionTile(
            context, 
            'Log Out', 
            Icons.logout, 
            _handleLogout,
            color: Colors.redAccent,
          ),
          
          const SizedBox(height: 60),
          Center(
            child: Text(
              'AiGym v1.0.0 (BETA)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: _pictureUrl != null ? NetworkImage(_pictureUrl!) : null,
            child: _pictureUrl == null ? const Icon(Icons.person, size: 30) : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_displayName ?? 'User', style: Theme.of(context).textTheme.titleLarge),
                Text(_displayEmail ?? '', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInputs() {
    return Column(
      children: [
        CustomTextInput(
          controller: _caloriesController,
          label: 'CALORIE GOAL',
          hintText: '2500 kcal',
          prefixIcon: Icons.local_fire_department,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: CustomTextInput(controller: _proteinController, label: 'PROTEIN', hintText: '150g', onChanged: (_) => _onFieldChanged())),
            const SizedBox(width: 12),
            Expanded(child: CustomTextInput(controller: _carbsController, label: 'CARBS', hintText: '200g', onChanged: (_) => _onFieldChanged())),
            const SizedBox(width: 12),
            Expanded(child: CustomTextInput(controller: _fatController, label: 'FAT', hintText: '70g', onChanged: (_) => _onFieldChanged())),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyMetricsInputs() {
    return Row(
      children: [
        Expanded(child: CustomTextInput(controller: _weightController, label: 'WEIGHT', hintText: '80', prefixIcon: Icons.monitor_weight, onChanged: (_) => _onFieldChanged())),
        const SizedBox(width: 16),
        Expanded(child: CustomTextInput(controller: _heightController, label: 'HEIGHT', hintText: '180', prefixIcon: Icons.height, onChanged: (_) => _onFieldChanged())),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, String value, {required IconData icon, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile(BuildContext context, String title, bool value, {required IconData icon, String? subtitle, required ValueChanged<bool> onChanged}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null ? Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary)) : null,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurfaceVariant),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color)),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$feature Center'),
        content: Text('This $feature logic is coming soon in the next update. Stay tuned!'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      final auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
      await auth0.webAuthentication(scheme: 'aigym').logout();
      await auth0.credentialsManager.clearCredentials();
      if (mounted) Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }
}
