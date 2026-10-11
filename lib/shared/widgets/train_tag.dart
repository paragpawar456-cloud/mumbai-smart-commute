import 'package:flutter/material.dart';

/// A small coloured label such as "Fast" or "AC".
class TrainTag extends StatelessWidget {
  const TrainTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Color.lerp(color, Colors.black, 0.2),
                fontWeight: FontWeight.w700)),
      );
}
