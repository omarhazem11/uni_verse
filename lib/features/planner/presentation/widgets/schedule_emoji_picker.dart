import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'emoji_keyboard.dart';

const defaultScheduleEmoji = '📚';

const _presetEmojis = [
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
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Preset options
          for (final emoji in _presetEmojis)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(emoji),
                child: _EmojiChip(emoji: emoji, selected: emoji == selected),
              ),
            ),

          // If user previously picked a custom emoji, keep it visible
          if (!_presetEmojis.contains(selected))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _EmojiChip(emoji: selected, selected: true),
            ),

          // + button — opens the full emoji keyboard
          GestureDetector(
            onTap: () => EmojiKeyboard.show(context, onChanged),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, size: 20, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiChip extends StatelessWidget {
  final String emoji;
  final bool selected;

  const _EmojiChip({required this.emoji, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
        border: selected ? Border.all(color: AppColors.violet, width: 2) : null,
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}
