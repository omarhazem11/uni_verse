import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

const defaultScheduleEmoji = '📚';

class ScheduleEmojiPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const ScheduleEmojiPicker({super.key, required this.selected, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Choose an emoji'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 36),
          maxLength: 8,
          decoration: const InputDecoration(
            hintText: '😊',
            counterText: '',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('OK', style: TextStyle(color: AppColors.violet, fontWeight: FontWeight.w700)),
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
    return GestureDetector(
      onTap: () => _pick(context),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.violet, width: 2),
              borderRadius: BorderRadius.circular(14),
              color: AppColors.violet.withValues(alpha: 0.07),
            ),
            alignment: Alignment.center,
            child: Text(selected, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tap to change',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
