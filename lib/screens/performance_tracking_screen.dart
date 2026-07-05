import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../core/widgets/stat_card.dart';
import '../services/user_service.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../providers/workout_provider.dart';

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

  double? getBmi(double weight) {
    if (_profile?.height == null || weight == 0.0) return null;
    double h = _profile!.height!;
    if (!_isMetric) {
      return (703 * weight) / (h * h);
    } else {
      double heightInMeters = h / 100;
      return weight / (heightInMeters * heightInMeters);
    }
  }

  String getBmiCategory(double? bmi) {
    if (bmi == null) return '--';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal Weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color getBmiColor(double? bmi) {
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

    final workoutProvider = Provider.of<WorkoutProvider>(context);

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
            _buildWeeklyVolumeChart(workoutProvider),
            const SizedBox(height: 32),
            _buildHabitTracker(workoutProvider),
            const SizedBox(height: 48),
            _buildBodyCompositionSection(workoutProvider),
            const SizedBox(height: 32),
            _buildWeightHistorySection(workoutProvider),
            const SizedBox(height: 48),
            _buildNutritionSection(),
            const SizedBox(height: 40),
            _buildProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyVolumeChart(WorkoutProvider provider) {
    final volumeMap = provider.getPastSevenDaysVolume();
    final weeklyLoad = volumeMap.values.fold(0.0, (a, b) => a + b);
    
    double maxVolume = volumeMap.values.fold(0.0, (a, b) => a > b ? a : b);
    if (maxVolume == 0) maxVolume = 1.0;

    final todayWeekday = DateTime.now().weekday;
    final volumeUnit = _isMetric ? 'kg' : 'lbs';

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
                  Text(
                    weeklyLoad > 1000
                        ? '${(weeklyLoad / 1000).toStringAsFixed(1)}k $volumeUnit'
                        : '${weeklyLoad.toStringAsFixed(0)} $volumeUnit',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
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
              _buildChartBar('M', volumeMap[1]! / maxVolume, isToday: todayWeekday == 1),
              _buildChartBar('T', volumeMap[2]! / maxVolume, isToday: todayWeekday == 2),
              _buildChartBar('W', volumeMap[3]! / maxVolume, isToday: todayWeekday == 3),
              _buildChartBar('T', volumeMap[4]! / maxVolume, isToday: todayWeekday == 4),
              _buildChartBar('F', volumeMap[5]! / maxVolume, isToday: todayWeekday == 5),
              _buildChartBar('S', volumeMap[6]! / maxVolume, isToday: todayWeekday == 6),
              _buildChartBar('S', volumeMap[7]! / maxVolume, isToday: todayWeekday == 7),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(String day, double heightFactor, {bool isToday = false}) {
    final double adjustedHeightFactor = heightFactor < 0.05 ? 0.05 : heightFactor;
    return Column(
      children: [
        Container(
          width: 24,
          height: 120 * adjustedHeightFactor,
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

  Widget _buildHabitTracker(WorkoutProvider provider) {
    final trainedDays = provider.getWeeklyTrainedDays();

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
              _buildDayCircle('M', trainedDays.contains(1)),
              _buildDayCircle('T', trainedDays.contains(2)),
              _buildDayCircle('W', trainedDays.contains(3)),
              _buildDayCircle('T', trainedDays.contains(4)),
              _buildDayCircle('F', trainedDays.contains(5)),
              _buildDayCircle('S', trainedDays.contains(6)),
              _buildDayCircle('S', trainedDays.contains(7)),
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

  Widget _buildBodyCompositionSection(WorkoutProvider provider) {
    final weightUnit = _isMetric ? 'kg' : 'lbs';
    final heightUnit = _isMetric ? 'cm' : 'in';
    
    final latestWeight = provider.weightHistory.isNotEmpty ? provider.weightHistory.first.weight : (_profile?.weight ?? 0.0);
    final bmi = getBmi(latestWeight);
    final bmiVal = bmi?.toStringAsFixed(1) ?? '--';
    final bmiCategory = getBmiCategory(bmi);
    final bmiColor = getBmiColor(bmi);

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
                  _buildMetricInfo('Weight', '${latestWeight > 0 ? latestWeight.toStringAsFixed(1) : '--'} $weightUnit'),
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
                  _buildMetricInfo('BMI', bmiVal, valueColor: bmiColor),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: bmiColor),
                  const SizedBox(width: 8),
                  Text(
                    'Category: $bmiCategory',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: bmiColor,
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

  Widget _buildWeightHistorySection(WorkoutProvider provider) {
    final weightUnit = _isMetric ? 'kg' : 'lbs';
    final logs = provider.weightHistory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BODY WEIGHT LOGS',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 2,
          ),
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
                'LOG HISTORY',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              if (logs.isEmpty)
                Text(
                  'No weight logs recorded yet. Tap on your weight card on the Dashboard to log your first weight!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: logs.length > 5 ? 5 : logs.length,
                  separatorBuilder: (context, index) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    final dateStr = '${log.date.day}/${log.date.month}/${log.date.year}';
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${log.weight.toStringAsFixed(1)} $weightUnit',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    );
                  },
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
