import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Small tab attached to the toolbar's edge that shows/hides it — split out
/// purely to keep note_editor_draw_tab.dart under the line-count budget.
class ToolbarToggleHandle extends StatelessWidget {
  final bool visible;
  final VoidCallback onTap;

  const ToolbarToggleHandle({super.key, required this.visible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.violet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
        onTap: onTap,
        child: SizedBox(
          width: 20,
          height: 44,
          child: Icon(
            visible ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
