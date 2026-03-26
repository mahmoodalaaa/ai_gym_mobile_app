import 'package:flutter/material.dart';

class WeeklyPlanScreen extends StatelessWidget {
  const WeeklyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Plan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week 4 / 12',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'Hypertrophy Phase',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          _buildDayCard(
            context,
            day: 'MONDAY',
            date: '21',
            title: 'Lower Body Strength',
            status: 'COMPLETED',
            isCompleted: true,
            imageUrl:
                'https://images.unsplash.com/photo-1574680096145-d05b474e2155?q=80&w=800&auto=format&fit=crop',
          ),
          const SizedBox(height: 24),
          _buildDayCard(
            context,
            day: 'TUESDAY',
            date: '22',
            title: 'Upper Body Strength',
            status: 'COMPLETED',
            isCompleted: true,
            imageUrl:
                'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?q=80&w=800&auto=format&fit=crop',
          ),
          const SizedBox(height: 24),
          _buildDayCard(
            context,
            day: 'WEDNESDAY',
            date: '23',
            title: 'Active Recovery',
            status: 'REST DAY',
            isCompleted: true,
            isRest: true,
          ),
          const SizedBox(height: 24),
          _buildDayCard(
            context,
            day: 'THURSDAY',
            date: '24',
            title: 'Heavy Back & Biceps',
            status: 'UP NEXT',
            isNext: true,
            imageUrl:
                'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=800&auto=format&fit=crop',
          ),
          const SizedBox(height: 24),
          _buildDayCard(
            context,
            day: 'FRIDAY',
            date: '25',
            title: 'Full Leg Hypertrophy',
            status: 'PENDING',
            imageUrl:
                'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=800&auto=format&fit=crop',
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context, {
    required String day,
    required String date,
    required String title,
    required String status,
    bool isCompleted = false,
    bool isNext = false,
    bool isRest = false,
    String? imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isRest) {
          Navigator.pushNamed(context, '/workout_detail');
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // Date part
        SizedBox(
          width: 60,
          child: Column(
            children: [
              Text(
                day.substring(0, 3), // MON, TUE...
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: isNext
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Card part
        Expanded(
          child: Container(
            height: 140,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isRest
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.surfaceContainerLow,
              border: isRest
                  ? Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: isRest
                ? Center(
                    // Rest day layout
                    child: Text(
                      'Active Recovery',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      if (imageUrl != null)
                        Positioned.fill(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            color: Colors.black.withOpacity(
                              isCompleted ? 0.7 : 0.4,
                            ),
                            colorBlendMode: BlendMode.darken,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green.withOpacity(0.2)
                                    : isNext
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                    : Theme.of(
                                        context,
                                      ).colorScheme.surface.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: isCompleted
                                          ? Colors.green
                                          : isNext
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.surface
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                    ),
                              ),
                            ),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    decorationColor: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        ],
      ),
    );
  }
}
