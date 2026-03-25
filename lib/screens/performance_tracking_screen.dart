import 'package:flutter/material.dart';
import '../core/widgets/stat_card.dart';

class PerformanceTrackingScreen extends StatelessWidget {
  const PerformanceTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        children: [
          // Total Volume Lifted Chart Mock
          _buildChartSection(context),
          const SizedBox(height: 48),

          Text(
            'KEY METRICS',
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
                  title: 'Squat 1RM',
                  value: '140',
                  subtitle: '+5kg this month',
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Bench 1RM',
                  value: '105',
                  subtitle: '+2.5kg this month',
                  icon: Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Deadlift 1RM',
                  value: '180',
                  subtitle: '+10kg this month',
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Bodyweight',
                  value: '82.5',
                  subtitle: '-1.2kg this month',
                  icon: Icons.monitor_weight_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),

          Text(
            'RECENT PERSONAL RECORDS',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecordItem(
            context,
            'Barbell Back Squat',
            '135kg x 3',
            '2 days ago',
          ),
          _buildRecordItem(context, 'Overhead Press', '65kg x 5', '5 days ago'),
          _buildRecordItem(
            context,
            'Pull-ups',
            'Bodyweight + 20kg x 8',
            '1 week ago',
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Volume Load',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Past 4 Weeks',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('42,500 kg', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 32),
          // Mocking a bar chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildChartBar(context, 0.4, 'W1'),
              _buildChartBar(context, 0.6, 'W2'),
              _buildChartBar(context, 0.5, 'W3'),
              _buildChartBar(context, 0.9, 'W4', isHighlighted: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(
    BuildContext context,
    double heightRatio,
    String label, {
    bool isHighlighted = false,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 150 * heightRatio,
          decoration: BoxDecoration(
            color: isHighlighted
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isHighlighted
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordItem(
    BuildContext context,
    String exercise,
    String record,
    String timeago,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events,
              color: Theme.of(context).colorScheme.primaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  record,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            timeago,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
