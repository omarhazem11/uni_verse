import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../planner/presentation/widgets/schedule_color_picker.dart';
import 'note_editor_fields.dart';
import 'note_editor_link_row.dart';
import 'note_editor_tag_section.dart';

class NoteEditorTextTab extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final String colorHex;
  final ValueChanged<String> onColorChanged;
  final String? linkedTaskId;
  final ValueChanged<String?> onLinkedTaskChanged;

  const NoteEditorTextTab({
    super.key,
    required this.titleController,
    required this.bodyController,
    required this.tags,
    required this.onTagsChanged,
    required this.colorHex,
    required this.onColorChanged,
    required this.linkedTaskId,
    required this.onLinkedTaskChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NoteEditorFields(titleController: titleController, bodyController: bodyController),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NoteEditorTagSection(tags: tags, onChanged: onTagsChanged),
              const SizedBox(height: 14),
              ScheduleColorPicker(selectedHex: colorHex, onChanged: onColorChanged),
              const SizedBox(height: 14),
              NoteEditorLinkRow(linkedTaskId: linkedTaskId, onChanged: onLinkedTaskChanged),
            ],
          ),
        ),
      ],
    );
  }
}
