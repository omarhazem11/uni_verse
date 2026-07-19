import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../planner/presentation/utils/schedule_color.dart';

/// Small building-block widgets shared by [DrawingToolbar] — kept separate
/// so the toolbar's own file stays under the line-count budget.

class ToolButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const ToolButton({super.key, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: selected ? AppColors.violet : AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, size: 20, color: selected ? Colors.white : AppColors.ink),
          ),
        ),
      ),
    );
  }
}

class DrawingColorSwatch extends StatelessWidget {
  final String hex;
  final bool selected;
  final VoidCallback onTap;

  const DrawingColorSwatch({super.key, required this.hex, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colorFromHex(hex),
            shape: BoxShape.circle,
            border: selected ? Border.all(color: AppColors.ink, width: 2) : null,
          ),
        ),
      ),
    );
  }
}

class WidthPreset extends StatelessWidget {
  final double width;
  final bool selected;
  final VoidCallback onTap;

  const WidthPreset({super.key, required this.width, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: selected ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 40,
            child: Center(
              child: Container(
                width: width + 4,
                height: width + 4,
                decoration: BoxDecoration(
                  color: selected ? AppColors.violet : AppColors.muted,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
