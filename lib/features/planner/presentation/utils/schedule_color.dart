import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

String _toHex(Color c) => '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

/// Derived from AppColors directly so the picker can never drift out of
/// sync with the palette's actual values.
final plannerColorPalette = <String>[
  _toHex(AppColors.coral),
  _toHex(AppColors.violet),
  _toHex(AppColors.mint),
  _toHex(AppColors.amber),
  _toHex(AppColors.skyBlue),
  _toHex(AppColors.pink),
];

Color colorFromHex(String hex) {
  final clean = hex.replaceFirst('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}
