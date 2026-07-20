import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Shown at the top of the inbox when the OS has notifications turned off
/// for this app — reminders would silently never arrive otherwise, so this
/// is surfaced as an actionable alert rather than a silent no-op.
class NotificationsDisabledBanner extends StatelessWidget {
  const NotificationsDisabledBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tileAmberBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tileAmberIcon),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_off_rounded, color: AppColors.tileAmberText, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications are turned off',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.tileAmberText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "You won't get task reminders until you turn them back on.",
                  style: TextStyle(color: AppColors.tileAmberText, fontSize: 12.5, height: 1.3),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: NotificationService.openNotificationSettings,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.tileAmberText,
                      side: BorderSide(color: AppColors.tileAmberText.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Turn on', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
