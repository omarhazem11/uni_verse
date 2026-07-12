import 'package:equatable/equatable.dart';

class PlannerSettingsEntity extends Equatable {
  final int dayStartMinutes; // minutes from midnight, default 420 (7:00 AM)
  final int dayEndMinutes; // default 1320 (10:00 PM)

  const PlannerSettingsEntity({
    this.dayStartMinutes = 420,
    this.dayEndMinutes = 1320,
  });

  PlannerSettingsEntity copyWith({int? dayStartMinutes, int? dayEndMinutes}) {
    return PlannerSettingsEntity(
      dayStartMinutes: dayStartMinutes ?? this.dayStartMinutes,
      dayEndMinutes: dayEndMinutes ?? this.dayEndMinutes,
    );
  }

  @override
  List<Object?> get props => [dayStartMinutes, dayEndMinutes];
}
