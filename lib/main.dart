import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'screens/landing_screen.dart';
import 'screens/main_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
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
      title: 'Kinetix Fitness',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        // We will implement dashboard shortly, mock it for now
        '/dashboard': (context) => const MainDashboardScreen(),
      },
    );
  }
}

