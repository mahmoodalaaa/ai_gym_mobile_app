import 'package:flutter/material.dart';
import 'package:auth0_flutter/auth0_flutter.dart' hide UserProfile;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../core/widgets/stat_card.dart';
import 'performance_tracking_screen.dart';
import 'ai_coach_screen.dart';
import 'profile_settings_screen.dart';
import 'workout_detail_screen.dart';
import 'weekly_plan_screen.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../providers/workout_provider.dart';
import '../l10n/app_localizations.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomeContent(),
    PerformanceTrackingScreen(),
    AiCoachScreen(),
    ProfileSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _pages),

          // Glassmorphic Bottom Nav
          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  UserProfile? _profile;
  String? _pictureUrl;
  bool _isLoading = true;
  bool _isMetric = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final userService = UserService();
      final auth0 = Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!);
      
      final results = await Future.wait([
        userService.fetchCurrentUser(),
        auth0.credentialsManager.credentials(),
        SharedPreferences.getInstance(),
      ]);

      final profile = results[0] as UserProfile;
      final credentials = results[1] as Credentials;
      final prefs = results[2] as SharedPreferences;

      if (mounted) {
        setState(() {
          _profile = profile;
          _pictureUrl = credentials.user.pictureUrl?.toString();
          _isMetric = prefs.getBool('is_metric') ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final workoutProvider = Provider.of<WorkoutProvider>(context);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
          children: [
            _buildHeader(context),
            const SizedBox(height: 40),
            _buildTodaysWorkout(context),
            const SizedBox(height: 40),
            _buildQuickStats(context),
            const SizedBox(height: 40),
            _buildWorkoutStatsOverview(context, workoutProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    const days = [
      'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'
    ];
    final formattedDate = '${days[now.weekday - 1]}, ${now.day}';

    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.welcomeBack,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          backgroundImage: _pictureUrl != null ? NetworkImage(_pictureUrl!) : null,
          child: _pictureUrl == null ? const Icon(Icons.person) : null,
        ),
      ],
    );
  }

  Widget _buildTodaysWorkout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = Provider.of<WorkoutProvider>(context, listen: false);
    final template = provider.templates.isNotEmpty ? provider.templates.first : null;

    if (template == null) return const SizedBox.shrink();

    int totalSets = 0;
    for (var ex in template.exercises) {
      totalSets += ex.defaultSets;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.todaysProgram,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyPlanScreen()),
                );
              },
              child: Text(
                l10n.viewWeek,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
          ),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  template.imageUrl,
                  fit: BoxFit.cover,
                  color: Colors.black.withValues(alpha: 0.4),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
              // Content overlay
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            template.category,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.timer_outlined,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${template.estimatedDurationMinutes} MIN',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Text(
                      template.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${template.exercises.length} movements • $totalSets sets',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutDetailScreen(template: template),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.8),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                        ),
                        child: Text(l10n.startWorkout),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final workoutProvider = Provider.of<WorkoutProvider>(context);
    final latestWeight = workoutProvider.weightHistory.isNotEmpty ? workoutProvider.weightHistory.first.weight : (_profile?.weight ?? 0.0);
    final weight = latestWeight > 0 ? latestWeight.toStringAsFixed(1) : '--';
    final height = _profile?.height?.toString() ?? '--';
    final weightUnit = _isMetric ? 'kg' : 'lbs';
    final heightUnit = _isMetric ? 'cm' : 'in';
    final calories = _profile?.dailyCalories?.toString() ?? '--';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.vitalsTargets,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showLogWeightDialog(context),
                child: StatCard(
                  title: l10n.weightLabel,
                  value: weight,
                  subtitle: 'current ($weightUnit) • tap to log',
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: l10n.heightLabel,
                value: height,
                subtitle: 'current ($heightUnit)',
                icon: Icons.height,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: StatCard(
            title: l10n.calorieGoal,
            value: calories,
            subtitle: 'target energy intake',
            icon: Icons.local_fire_department_outlined,
          ),
        ),
        const SizedBox(height: 16),
        _buildMacrosBar(context),
      ],
    );
  }

  Widget _buildMacrosBar(BuildContext context) {
    final p = _profile?.dailyProtein ?? 0;
    final c = _profile?.dailyCarbs ?? 0;
    final f = _profile?.dailyFat ?? 0;

    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.macroTargets,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroInfo(l10n.protein, '${p}G', Theme.of(context).colorScheme.primary),
              _buildMacroInfo(l10n.carbs, '${c}G', Colors.orangeAccent),
              _buildMacroInfo(l10n.fat, '${f}G', Colors.lightBlueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showLogWeightDialog(BuildContext context) {
    final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
    final latestWeight = workoutProvider.weightHistory.isNotEmpty ? workoutProvider.weightHistory.first.weight : (_profile?.weight ?? 0.0);
    final controller = TextEditingController(
      text: latestWeight > 0 ? latestWeight.toString() : '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(
          'Log Body Weight',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your current weight (${_isMetric ? 'kg' : 'lbs'}):',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.headlineMedium,
              decoration: InputDecoration(
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixText: _isMetric ? 'kg' : 'lbs',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final double? newWeight = double.tryParse(controller.text);
              if (newWeight != null && newWeight > 0) {
                Provider.of<WorkoutProvider>(context, listen: false).logWeight(
                  newWeight,
                  currentProfile: _profile,
                );
                if (_profile != null) {
                  setState(() {
                    _profile = _profile!.copyWith(weight: newWeight);
                  });
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Weight logged successfully: $newWeight ${_isMetric ? 'kg' : 'lbs'}'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStatsOverview(BuildContext context, WorkoutProvider provider) {
    final workoutsCount = provider.completedWorkoutsCount;
    final totalVolume = provider.totalVolume;
    final recentSessions = provider.completedWorkouts.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORKOUT TRACKER SUMMARY',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Completed',
                value: '$workoutsCount',
                subtitle: 'workouts completed',
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Total Volume',
                value: totalVolume > 1000
                    ? '${(totalVolume / 1000).toStringAsFixed(1)}k'
                    : '${totalVolume.toStringAsFixed(0)}',
                subtitle: 'kg lifted',
                icon: Icons.fitness_center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RECENT ACTIVITY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              if (recentSessions.isEmpty)
                Text(
                  'No workouts completed yet. Start your first session to track your progress!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ...recentSessions.map((session) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${session.durationMinutes} min • ${session.exercises.length} movements',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${session.date.day}/${session.date.month}',
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
