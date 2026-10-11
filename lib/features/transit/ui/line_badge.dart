import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/models.dart';

Color lineColor(TransitLine line) {
  final hex = line.color;
  if (hex != null && RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
    return Color(int.parse('FF${hex.substring(1)}', radix: 16));
  }
  return line.mode == TransitMode.metro ? AppColors.metro : AppColors.localTrain;
}

IconData lineIcon(TransitLine line) => switch (line.mode) {
      TransitMode.metro => Icons.subway,
      TransitMode.mono => Icons.tram,
      TransitMode.suburban => Icons.train,
    };

class LineBadge extends StatelessWidget {
  const LineBadge({super.key, required this.line, this.compact = false});

  final TransitLine line;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = lineColor(line);
    return Semantics(
      label: line.nameEn,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(lineIcon(line), size: 14, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              compact ? line.id : line.nameEn,
              style: const TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
