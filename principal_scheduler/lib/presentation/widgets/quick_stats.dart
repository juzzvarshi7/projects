import 'package:flutter/material.dart';

class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class QuickStats extends StatelessWidget {
  final List<StatItem> stats;

  const QuickStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < stats.length - 1 ? 12 : 0,
            ),
            child: _buildStatCard(context, stat),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(BuildContext context, StatItem stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stat.color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: stat.color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}