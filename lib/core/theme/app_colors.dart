import 'package:flutter/material.dart';

import '../data/data_source_label.dart';

/// Brand and transport-mode colours. Mode colours are also paired with an icon
/// everywhere they appear, so colour is never the only signal.
abstract final class AppColors {
  static const brand = Color(0xFF0B4FA3); // harbour blue
  static const brandDeep = Color(0xFF082F6B);
  static const brandBright = Color(0xFF1E88E5);
  static const accent = Color(0xFFF29F05); // marigold, for the chosen option

  /// Page background in light mode: a cool off-white so white cards stand out.
  static const canvas = Color(0xFFF3F6FB);

  static const localTrain = Color(0xFF1565C0);
  static const metro = Color(0xFF6A1B9A);
  static const bus = Color(0xFFD32F2F);
  static const auto = Color(0xFF2E7D32);
  static const taxi = Color(0xFFF59E0B);
  static const walk = Color(0xFF546E7A);

  /// Header gradient used on Home and journey screens.
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandDeep, brand, brandBright],
  );

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
