import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/planner_settings_entity.dart';
import '../entities/schedule_item_entity.dart';

abstract class PlannerRepository {
  Stream<List<ScheduleItemEntity>> watchItemsForDate(DateTime date);
  Stream<List<ScheduleItemEntity>> watchItemsInRange(DateTime start, DateTime end);
  Future<Either<Failure, void>> addItem(ScheduleItemEntity item);
  Future<Either<Failure, void>> updateItem(ScheduleItemEntity item);
  Future<Either<Failure, void>> deleteItem(String itemId);

  /// Copies all items from [sourceDate] to each of [targetDates], keeping
  /// the same times/colors/emojis but generating new IDs.
  Future<Either<Failure, void>> duplicateItemsToDate(
    DateTime sourceDate,
    List<DateTime> targetDates,
  );

  Stream<PlannerSettingsEntity> watchSettings();
  Future<Either<Failure, void>> updateSettings(PlannerSettingsEntity settings);
}
