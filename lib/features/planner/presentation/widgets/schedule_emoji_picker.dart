import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

const scheduleEmojiOptions = [
  '📚', '☕', '🏃', '🎯', '💻', '🍽️', '😴', '🎨', '🏋️', '📖',
];

class ScheduleEmojiPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ScheduleEmojiPicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scheduleEmojiOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final emoji = scheduleEmojiOptions[index];
          final isSelected = emoji == selected;
          return GestureDetector(
            onTap: () => onChanged(emoji),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.bg,
                shape: BoxShape.circle,
                border: isSelected ? Border.all(color: AppColors.violet, width: 2) : null,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          );
        },
      ),
    );
  }
}
