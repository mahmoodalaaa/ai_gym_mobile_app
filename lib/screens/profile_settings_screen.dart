import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart' hide UserProfile;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/widgets/custom_text_input.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

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

      final auth0 = Auth0(
        dotenv.env['AUTH0_DOMAIN']!,
        dotenv.env['AUTH0_CLIENT_ID']!,
      );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
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

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountHub),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 48),

          _buildSectionTitle(context, l10n.healthNutrition),
          const SizedBox(height: 16),
          _buildMacroInputs(l10n),
          const SizedBox(height: 24),
          _buildBodyMetricsInputs(l10n),

          const SizedBox(height: 48),
          _buildSectionTitle(context, l10n.appPreferences),
          const SizedBox(height: 16),
          _buildSettingsTile(
            context,
            l10n.language,
            _getLanguageName(context),
            icon: Icons.language,
            onTap: () => _showLanguageSelector(context),
          ),
          _buildSettingsTile(
            context,
            l10n.unitsOfMeasure,
            _isMetric ? 'Metric (kg/cm)' : 'Imperial (lbs/in)',
            icon: Icons.straighten,
            onTap: () async {
              setState(() => _isMetric = !_isMetric);
              await _savePreference('is_metric', _isMetric);
            },
          ),
          _buildToggleTile(
            context,
            l10n.pushNotifications,
            _notificationsEnabled,
            icon: Icons.notifications_none,
            subtitle: _notificationTime != null && _notificationsEnabled
                ? 'Reminder at ${_notificationTime!.format(context)}'
                : 'Daily Workout Reminders',
            onChanged: (val) async {
              if (val) {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      _notificationTime ?? const TimeOfDay(hour: 8, minute: 0),
                );
                if (time != null) {
                  await NotificationService().scheduleDailyWorkoutNotification(
                    time,
                  );
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
            },
          ),

          const SizedBox(height: 48),
          _buildSectionTitle(context, l10n.supportLegal),
          const SizedBox(height: 16),
          _buildActionTile(
            context,
            l10n.helpCenter,
            Icons.help_outline,
            () => _showComingSoon(context, l10n.helpCenter),
          ),
          _buildActionTile(
            context,
            l10n.termsOfService,
            Icons.description_outlined,
            () => _showComingSoon(context, l10n.termsOfService),
          ),
          _buildActionTile(
            context,
            l10n.privacyPolicy,
            Icons.privacy_tip_outlined,
            () => _showComingSoon(context, l10n.privacyPolicy),
          ),
          _buildActionTile(
            context,
            l10n.contactUs,
            Icons.mail_outline,
            () => _showComingSoon(context, l10n.contactUs),
          ),

          const SizedBox(height: 48),
          _buildSectionTitle(context, l10n.dangerZone),
          const SizedBox(height: 16),
          _buildActionTile(
            context,
            l10n.logOut,
            Icons.logout,
            _handleLogout,
            color: Colors.redAccent,
          ),

          const SizedBox(height: 60),
          Center(
            child: Text(
              'AiGym v1.0.0 (BETA)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            backgroundImage: _pictureUrl != null
                ? NetworkImage(_pictureUrl!)
                : null,
            child: _pictureUrl == null
                ? const Icon(Icons.person, size: 30)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  _displayEmail ?? '',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInputs(AppLocalizations l10n) {
    return Column(
      children: [
        CustomTextInput(
          controller: _caloriesController,
          label: l10n.calorieGoal,
          hintText: '2500 kcal',
          prefixIcon: Icons.local_fire_department,
          onChanged: (_) => _onFieldChanged(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextInput(
                controller: _proteinController,
                label: l10n.protein,
                hintText: '150g',
                onChanged: (_) => _onFieldChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextInput(
                controller: _carbsController,
                label: l10n.carbs,
                hintText: '200g',
                onChanged: (_) => _onFieldChanged(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextInput(
                controller: _fatController,
                label: l10n.fat,
                hintText: '70g',
                onChanged: (_) => _onFieldChanged(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyMetricsInputs(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: CustomTextInput(
            controller: _weightController,
            label: l10n.weightLabel,
            hintText: '80',
            prefixIcon: Icons.monitor_weight,
            onChanged: (_) => _onFieldChanged(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomTextInput(
            controller: _heightController,
            label: l10n.heightLabel,
            hintText: '180',
            prefixIcon: Icons.height,
            onChanged: (_) => _onFieldChanged(),
          ),
        ),
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

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String value, {
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildToggleTile(
    BuildContext context,
    String title,
    bool value, {
    required IconData icon,
    String? subtitle,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : null,
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
      ),
      trailing: const Icon(Icons.open_in_new, size: 16),
      onTap: onTap,
    );
  }

  String _getLanguageName(BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context, listen: false).locale;
    if (locale == null) return 'System Default';
    switch (locale.languageCode) {
      case 'en': return 'English';
      case 'ar': return 'العربية';
      case 'de': return 'Deutsch';
      case 'fr': return 'Français';
      case 'tr': return 'Türkçe';
      default: return 'English';
    }
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.selectLanguage,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildLanguageTile(context, 'English', 'en', localeProvider),
            _buildLanguageTile(context, 'العربية', 'ar', localeProvider),
            _buildLanguageTile(context, 'Deutsch', 'de', localeProvider),
            _buildLanguageTile(context, 'Français', 'fr', localeProvider),
            _buildLanguageTile(context, 'Türkçe', 'tr', localeProvider),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String name, String code, LocaleProvider provider) {
    final isSelected = provider.locale?.languageCode == code || (provider.locale == null && code == 'en');
    
    return ListTile(
      title: Text(name, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: isSelected ? Theme.of(context).colorScheme.primary : null,
        fontWeight: isSelected ? FontWeight.bold : null,
      )),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        provider.setLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(feature),
        content: Text('This $feature logic is coming soon in the next update. Stay tuned!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      final auth0 = Auth0(
        dotenv.env['AUTH0_DOMAIN']!,
        dotenv.env['AUTH0_CLIENT_ID']!,
      );
      await auth0.webAuthentication(scheme: 'aigym').logout();
      await auth0.credentialsManager.clearCredentials();
      if (mounted)
        Navigator.of(context, rootNavigator: true).pushReplacementNamed('/');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
    }
  }
}
