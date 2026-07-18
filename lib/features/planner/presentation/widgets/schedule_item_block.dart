import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/schedule_item_entity.dart';
import '../providers/planner_provider.dart';
import '../utils/schedule_color.dart';
import 'add_schedule_item_sheet.dart';

class ScheduleItemBlock extends ConsumerWidget {
  final ScheduleItemEntity item;

  const ScheduleItemBlock({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = colorFromHex(item.colorHex);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddScheduleItemSheet(existingItem: item),
      ),
      onLongPress: () => _confirmDelete(context, ref),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final short = constraints.maxHeight < 30;
          return Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: short ? 3 : 6),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.topLeft,
            child: Text(
              '${item.emoji} ${item.title}',
              maxLines: short ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
            ),
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
