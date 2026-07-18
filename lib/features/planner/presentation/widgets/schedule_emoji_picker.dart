import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

const defaultScheduleEmoji = '📚';

const _presetEmojis = [
  '📚', '☕', '🏃', '🎯', '💻', '🍽️', '😴', '🎨', '🏋️', '📖',
];

// Strips every character that is plain ASCII (letters, digits, punctuation).
// Emojis are multi-byte Unicode and always have rune values > 127, so they
// pass through; regular keyboard text is silently discarded.
class _EmojiOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = String.fromCharCodes(
      newValue.text.runes.where((r) => r > 127),
    );
    return newValue.copyWith(
      text: filtered,
      selection: TextSelection.collapsed(offset: filtered.length),
    );
  }
}

class ScheduleEmojiPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ScheduleEmojiPicker({super.key, required this.selected, required this.onChanged});

  Future<void> _openKeyboard(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick an emoji'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Switch to the emoji keyboard and tap an emoji.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36),
              maxLength: 8,
              inputFormatters: [_EmojiOnlyFormatter()],
              decoration: const InputDecoration(
                hintText: '😊',
                counterText: '',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.violet, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      onChanged(result);
    }
  }

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

          // If the user previously picked a custom emoji not in the presets, keep showing it
          if (!_presetEmojis.contains(selected))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _EmojiChip(emoji: selected, selected: true),
            ),

          // + button — opens the keyboard-based picker
          GestureDetector(
            onTap: () => _openKeyboard(context),
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
