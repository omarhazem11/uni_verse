import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/planner_settings_entity.dart';
import '../providers/planner_provider.dart';
import 'day_boundary_time_button.dart';
import 'schedule_save_button.dart';
import 'schedule_sheet_field_label.dart';
import 'schedule_sheet_header.dart';

const minimumDayLengthMinutes = 120; // at least 2 hours

class DaySettingsSheet extends ConsumerStatefulWidget {
  final PlannerSettingsEntity settings;

  const DaySettingsSheet({super.key, required this.settings});

  @override
  ConsumerState<DaySettingsSheet> createState() => _DaySettingsSheetState();
}

class _DaySettingsSheetState extends ConsumerState<DaySettingsSheet> {
  late int _startMinutes = widget.settings.dayStartMinutes;
  late int _endMinutes = widget.settings.dayEndMinutes;

  bool get _valid => _endMinutes - _startMinutes >= minimumDayLengthMinutes;

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(plannerActionsProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const ScheduleSheetHeader(title: 'Day Settings'),
                const SizedBox(height: 18),
                const ScheduleSheetFieldLabel('Day starts at'),
                DayBoundaryTimeButton(
                  minutes: _startMinutes,
                  onChanged: (m) => setState(() => _startMinutes = m),
                ),
                const SizedBox(height: 16),
                const ScheduleSheetFieldLabel('Day ends at'),
                DayBoundaryTimeButton(
                  minutes: _endMinutes,
                  onChanged: (m) => setState(() => _endMinutes = m),
                ),
                if (!_valid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Your day must be at least 2 hours long',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.coral),
                    ),
                  ),
                const SizedBox(height: 24),
                ScheduleSaveButton(saving: saving, enabled: _valid, onPressed: _save),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_valid) return;
    final success = await ref.read(plannerActionsProvider.notifier).updateSettings(
          widget.settings.copyWith(dayStartMinutes: _startMinutes, dayEndMinutes: _endMinutes),
        );
    if (success && mounted) Navigator.pop(context);
  }
}
