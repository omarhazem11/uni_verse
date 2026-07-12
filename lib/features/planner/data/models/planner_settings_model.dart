import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/planner_settings_entity.dart';

class PlannerSettingsModel extends PlannerSettingsEntity {
  const PlannerSettingsModel({super.dayStartMinutes, super.dayEndMinutes});

  factory PlannerSettingsModel.fromEntity(PlannerSettingsEntity settings) {
    return PlannerSettingsModel(
      dayStartMinutes: settings.dayStartMinutes,
      dayEndMinutes: settings.dayEndMinutes,
    );
  }

  factory PlannerSettingsModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) return const PlannerSettingsModel();
    return PlannerSettingsModel(
      dayStartMinutes: data['dayStartMinutes'] as int? ?? 420,
      dayEndMinutes: data['dayEndMinutes'] as int? ?? 1320,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dayStartMinutes': dayStartMinutes,
      'dayEndMinutes': dayEndMinutes,
    };
  }
}
