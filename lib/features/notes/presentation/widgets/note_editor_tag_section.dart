import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import 'tag_chip.dart';

class NoteEditorTagSection extends StatelessWidget {
  final List<String> tags;
  final ValueChanged<List<String>> onChanged;

  const NoteEditorTagSection({super.key, required this.tags, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          TagChip(
            label: tag,
            isSelected: true,
            onRemove: () => onChanged(tags.where((t) => t != tag).toList()),
          ),
        GestureDetector(
          onTap: () => _promptNewTag(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              '+ New tag',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.violet),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _promptNewTag(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('New tag', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Chemistry'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && !tags.contains(result)) {
      onChanged([...tags, result]);
    }
  }
}
