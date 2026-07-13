import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/note_provider.dart';
import 'tag_chip.dart';

class NotesTagFilterRow extends ConsumerWidget {
  const NotesTagFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesStreamProvider).value ?? [];
    final tags = notes.expand((n) => n.tags).toSet().toList()..sort();
    if (tags.isEmpty) return const SizedBox.shrink();

    final selected = ref.watch(noteTagFilterProvider);

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          TagChip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => ref.read(noteTagFilterProvider.notifier).state = null,
          ),
          const SizedBox(width: 8),
          for (final tag in tags) ...[
            TagChip(
              label: tag,
              isSelected: tag == selected,
              onTap: () => ref.read(noteTagFilterProvider.notifier).state = tag == selected ? null : tag,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
