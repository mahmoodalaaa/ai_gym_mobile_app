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
      
      // Fetch Auth0 data
      final auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
      final credentials = await auth0.credentialsManager.credentials();
      final user = credentials.user;
      
      // Fetch Backend data
      final profile = await userService.fetchCurrentUser();

      // Silent Sync: If backend has placeholder email, update it with Auth0 email
      if (profile.email == 'temp-email@domain.com' && user.email != null) {
        final syncedProfile = profile.copyWith(email: user.email);
        // Fire and forget update to avoid blocking UI
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
    if (value is String) await prefs.setString(key, value);
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final name = _displayName ?? 'User';
    final email = _displayEmail ?? '';
    final pictureUrl = _pictureUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80';

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: const [
          // SAVE button removed
          SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
        children: [
          _buildProfileHeader(context, name, email, pictureUrl),
          const SizedBox(height: 48),

          _buildSectionTitle(context, 'NUTRITION & MACROS'),
          const SizedBox(height: 16),
          CustomTextInput(
            controller: _caloriesController,
            label: 'DAILY CALORIES',
            hintText: 'e.g. 2500 kcal',
            prefixIcon: Icons.local_fire_department_outlined,
            onChanged: (_) => _onFieldChanged(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextInput(
                  controller: _proteinController,
                  label: 'PROTEIN (g)',
                  hintText: 'e.g. 150',
                  prefixIcon: Icons.egg_outlined,
                  onChanged: (_) => _onFieldChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextInput(
                  controller: _carbsController,
                  label: 'CARBS (g)',
                  hintText: 'e.g. 200',
                  prefixIcon: Icons.bakery_dining_outlined,
                  onChanged: (_) => _onFieldChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextInput(
                  controller: _fatController,
                  label: 'FAT (g)',
                  hintText: 'e.g. 70',
                  prefixIcon: Icons.opacity_outlined,
                  onChanged: (_) => _onFieldChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          _buildSectionTitle(context, 'BODY METRICS'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTextInput(
                  controller: _weightController,
                  label: 'WEIGHT (${_isMetric ? 'kg' : 'lbs'})',
                  hintText: _isMetric ? 'e.g. 80' : 'e.g. 176',
                  prefixIcon: Icons.monitor_weight_outlined,
                  onChanged: (_) => _onFieldChanged(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextInput(
                  controller: _heightController,
                  label: 'HEIGHT (${_isMetric ? 'cm' : 'in'})',
                  hintText: _isMetric ? 'e.g. 180' : 'e.g. 71',
                  prefixIcon: Icons.height_outlined,
                  onChanged: (_) => _onFieldChanged(),
                ),
              ),
            ],
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

  Widget _buildProfileHeader(BuildContext context, String name, String email, String pictureUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          backgroundImage: pictureUrl.isNotEmpty ? NetworkImage(pictureUrl) : null,
          child: pictureUrl.isEmpty ? Icon(
            Icons.person,
            size: 40,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ) : null,
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
                email,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
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
