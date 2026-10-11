import 'package:flutter/material.dart';

import '../data/data_source_label.dart';

/// Brand and transport-mode colours. Mode colours are also paired with an icon
/// everywhere they appear, so colour is never the only signal.
abstract final class AppColors {
  static const brand = Color(0xFF0B5FA5); // harbour blue
  static const accent = Color(0xFFF29F05); // marigold, for the chosen option

  static const localTrain = Color(0xFF1565C0);
  static const metro = Color(0xFF6A1B9A);
  static const bus = Color(0xFFC62828);
  static const auto = Color(0xFF2E7D32);
  static const taxi = Color(0xFFF9A825);
  static const walk = Color(0xFF546E7A);

  static Color forSource(DataSourceKind kind, ColorScheme scheme) =>
      switch (kind) {
        DataSourceKind.live => const Color(0xFF2E7D32),
        DataSourceKind.official => scheme.primary,
        DataSourceKind.scheduled => scheme.secondary,
        DataSourceKind.estimate => const Color(0xFFB26A00),
        DataSourceKind.community => const Color(0xFF7B1FA2),
        DataSourceKind.unknown => scheme.outline,
      };
}
