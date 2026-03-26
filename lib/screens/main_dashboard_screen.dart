import 'package:flutter/material.dart';
import '../core/widgets/bottom_nav_bar.dart';
import '../core/widgets/stat_card.dart';
import 'performance_tracking_screen.dart';
import 'ai_coach_screen.dart';
import 'profile_settings_screen.dart';
import 'workout_detail_screen.dart';
import 'weekly_plan_screen.dart';
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          
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

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          _buildHeader(context),
          const SizedBox(height: 40),
          _buildTodaysWorkout(context),
          const SizedBox(height: 40),
          _buildQuickStats(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    final formattedDate = '${days[now.weekday - 1]}, ${now.day}';

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
              'Ready to pull?',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ],
        ),
        FutureBuilder<Credentials>(
          future: Auth0(dotenv.env['AUTH0_DOMAIN']!, dotenv.env['AUTH0_CLIENT_ID']!).credentialsManager.credentials(),
          builder: (context, snapshot) {
            String? imageUrl;
            if (snapshot.hasData && snapshot.data?.user.pictureUrl != null) {
              imageUrl = snapshot.data!.user.pictureUrl.toString();
            }
            return CircleAvatar(
              radius: 24,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
              backgroundImage: imageUrl != null 
                  ? NetworkImage(imageUrl) 
                  : const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150&q=80'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodaysWorkout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TODAY\'S PROGRAM',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyPlanScreen()));
              },
              child: Text(
                'View Week', 
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
                  'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800&auto=format&fit=crop',
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'HYPERTROPHY',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.timer_outlined, color: Theme.of(context).colorScheme.onSurface),
                        const SizedBox(width: 4),
                        Text('60 MIN', style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                    const SizedBox(height: 60),
                    Text(
                      'Heavy Back & Biceps',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '6 movements • 24 sets',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutDetailScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                        ),
                        child: const Text('START WORKOUT'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THIS WEEK',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Volume',
                value: '12.4k',
                subtitle: 'kg lifted',
                icon: Icons.fitness_center,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Workouts',
                value: '4',
                subtitle: 'completed',
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
