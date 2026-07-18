import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/schedule_item_entity.dart';
import '../providers/planner_provider.dart';
import '../utils/schedule_color.dart';
import 'add_schedule_item_sheet.dart';
import 'block_preview_card.dart';

class ScheduleItemBlock extends ConsumerWidget {
  final ScheduleItemEntity item;

  const ScheduleItemBlock({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = colorFromHex(item.colorHex);

    return GestureDetector(
      onTap: () => showBlockPreview(
        context,
        emoji: item.emoji,
        title: item.title,
        color: color,
        subtitle: '${formatTimeOfDay(item.startTime)} – ${formatTimeOfDay(item.endTime)}',
        onOpen: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddScheduleItemSheet(existingItem: item),
        ),
      ),
      onLongPress: () => _confirmDelete(context, ref),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final short = constraints.maxHeight < 30;
          // Horizontal padding is 10 on each side.
          final availableWidth = constraints.maxWidth - 20;

          final style = GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          );

          // Measure whether the full title fits in one line.
          final tp = TextPainter(
            text: TextSpan(text: '${item.emoji} ${item.title}', style: style),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: availableWidth);

          final fits = !tp.didExceedMaxLines;

          if (!fits) {
            // Title doesn't fit — emoji pinned to top-left, rest solid color.
            return Container(
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              alignment: Alignment.topLeft,
              child: Text(item.emoji, style: const TextStyle(fontSize: 12)),
            );
          }

          return Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: short ? 3 : 6),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.topLeft,
            child: Text('${item.emoji} ${item.title}', style: style),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete this item?', style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text("This can't be undone.", style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.coral)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(plannerActionsProvider.notifier).deleteItem(item.id);
    }
  }
}
