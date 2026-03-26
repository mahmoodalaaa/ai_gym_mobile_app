import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'screens/landing_screen.dart';
import 'screens/main_dashboard_screen.dart';
import 'screens/active_workout_screen.dart';
import 'screens/adjust_workout_plan_screen.dart';
import 'screens/ai_coach_screen.dart';
import 'screens/enhanced_workout_detail_screen.dart';
import 'screens/performance_tracking_screen.dart';
import 'screens/profile_settings_screen.dart';
import 'screens/weekly_plan_screen.dart';
import 'screens/workout_detail_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await NotificationService().init();
  
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: 42),
      ],
      child: const AiGymApp(),
    ),
  );
}

class AiGymApp extends StatelessWidget {
  const AiGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GYM AI',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        '/dashboard': (context) => const MainDashboardScreen(),
        '/active_workout': (context) => const ActiveWorkoutScreen(),
        '/adjust_workout': (context) => const AdjustWorkoutPlanScreen(),
        '/ai_coach': (context) => const AiCoachScreen(),
        '/enhanced_workout': (context) => const EnhancedWorkoutDetailScreen(),
        '/performance': (context) => const PerformanceTrackingScreen(),
        '/profile': (context) => const ProfileSettingsScreen(),
        '/weekly_plan': (context) => const WeeklyPlanScreen(),
        '/workout_detail': (context) => const WorkoutDetailScreen(),
      },
    );
  }
}

