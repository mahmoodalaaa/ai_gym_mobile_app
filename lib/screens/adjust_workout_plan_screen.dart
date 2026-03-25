import 'package:flutter/material.dart';

class AdjustWorkoutPlanScreen extends StatelessWidget {
  const AdjustWorkoutPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Workout'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Customize', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Select alternatives for your workout based on available equipment or preferences.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 40),

          _buildAdjustmentGroup(context, 'C1', 'Barbell Row', [
            _AdjustmentOption('Barbell Row', isSelected: true),
            _AdjustmentOption('Dumbbell Row'),
            _AdjustmentOption('Machine Row'),
            _AdjustmentOption('T-Bar Row'),
          ]),
          const SizedBox(height: 32),

          _buildAdjustmentGroup(context, 'C2', 'Dumbbell Curl', [
            _AdjustmentOption('Dumbbell Curl'),
            _AdjustmentOption('Barbell Curl', isSelected: true),
            _AdjustmentOption('Cable Curl'),
          ]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.surface,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: Text(
              'SAVE CHANGES',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdjustmentGroup(
    BuildContext context,
    String letter,
    String title,
    List<_AdjustmentOption> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                letter,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            const SizedBox(width: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: options.map((opt) {
              return RadioListTile<String>(
                value: opt.name,
                groupValue: options
                    .firstWhere(
                      (e) => e.isSelected,
                      orElse: () => options.first,
                    )
                    .name,
                onChanged: (val) {},
                title: Text(opt.name),
                activeColor: Theme.of(context).colorScheme.primaryContainer,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AdjustmentOption {
  final String name;
  final bool isSelected;
  _AdjustmentOption(this.name, {this.isSelected = false});
}
