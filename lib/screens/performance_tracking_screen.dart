import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/widgets/stat_card.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';

class PerformanceTrackingScreen extends StatefulWidget {
  const PerformanceTrackingScreen({super.key});

  @override
  State<PerformanceTrackingScreen> createState() => _PerformanceTrackingScreenState();
}

class _PerformanceTrackingScreenState extends State<PerformanceTrackingScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isMetric = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userService = UserService();
      final prefs = await SharedPreferences.getInstance();
      final profile = await userService.fetchCurrentUser();

      if (mounted) {
        setState(() {
          _profile = profile;
          _isMetric = prefs.getBool('is_metric') ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading performance data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double? get _bmi {
    if (_profile?.weight == null || _profile?.height == null) return null;
    
    double w = _profile!.weight!;
    double h = _profile!.height!;

    if (!_isMetric) {
      // Imperial BMI: 703 * lbs / in^2
      return (703 * w) / (h * h);
    } else {
      // Metric BMI: kg / m^2
      double heightInMeters = h / 100;
      return w / (heightInMeters * heightInMeters);
    }
  }

  String get _bmiCategory {
    final bmi = _bmi;
    if (bmi == null) return '--';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    final bmi = _bmi;
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          children: [
            _buildWeeklyVolumeChart(),
            const SizedBox(height: 32),
            _buildHabitTracker(),
            const SizedBox(height: 48),
            _buildBodyCompositionSection(),
            const SizedBox(height: 48),
            _buildNutritionSection(),
            const SizedBox(height: 40),
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyVolumeChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY TRAINING LOAD',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('42,500 kg', style: Theme.of(context).textTheme.displaySmall),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.show_chart, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar('M', 0.45),
              _buildChartBar('T', 0.7),
              _buildChartBar('W', 0.2),
              _buildChartBar('T', 0.85, isToday: true),
              _buildChartBar('F', 0.5),
              _buildChartBar('S', 0.3),
              _buildChartBar('S', 0.1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double heightFactor, {bool isToday = false}) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isToday ? [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORKOUT CONSISTENCY',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayCircle('M', true),
              _buildDayCircle('T', true),
              _buildDayCircle('W', false),
              _buildDayCircle('T', true),
              _buildDayCircle('F', false),
              _buildDayCircle('S', false),
              _buildDayCircle('S', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayCircle(String day, bool isDone) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDone
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDone
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: isDone
              ? Icon(Icons.check, size: 20, color: Theme.of(context).colorScheme.onPrimaryContainer)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isDone
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildBodyCompositionSection() {
    final weightUnit = _isMetric ? 'kg' : 'lbs';
    final heightUnit = _isMetric ? 'cm' : 'in';
    final bmiVal = _bmi?.toStringAsFixed(1) ?? '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BODY COMPOSITION',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surfaceContainerLow,
                Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricInfo('Weight', '${_profile?.weight ?? '--'} $weightUnit'),
                  Container(
                    width: 2,
                    height: 40,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  _buildMetricInfo('Height', '${_profile?.height ?? '--'} $heightUnit'),
                  Container(
                    width: 2,
                    height: 40,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  _buildMetricInfo('BMI', bmiVal, valueColor: _bmiColor),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: _bmiColor),
                  const SizedBox(width: 8),
                  Text(
                    'Category: $_bmiCategory',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _bmiColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricInfo(String label, String value, {Color? valueColor}) {
    return Column(
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
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NUTRITION ADHERENCE',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Daily Calories',
                value: '${_profile?.dailyCalories ?? '--'}',
                subtitle: 'Target kcal',
                icon: Icons.local_fire_department,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMacroBreakdown(),
      ],
    );
  }

  Widget _buildMacroBreakdown() {
    final p = _profile?.dailyProtein ?? 1; // Avoid divide by zero
    final c = _profile?.dailyCarbs ?? 1;
    final f = _profile?.dailyFat ?? 1;

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
            'Target Macro Split',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: p, child: Container(color: Theme.of(context).colorScheme.primary)),
                  Expanded(flex: c, child: Container(color: Colors.orangeAccent)),
                  Expanded(flex: f, child: Container(color: Colors.lightBlueAccent)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroLegend('Protein', '${p}g', Theme.of(context).colorScheme.primary),
              _buildMacroLegend('Carbs', '${c}g', Colors.orangeAccent),
              _buildMacroLegend('Fat', '${f}g', Colors.lightBlueAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your profile data is successfully synced. Update your vitals in settings to see progress over time.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
