import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/planner_settings_entity.dart';
import '../../domain/entities/schedule_item_entity.dart';
import '../../domain/repositories/planner_repository.dart';
import '../datasources/planner_remote_datasource.dart';
import '../models/planner_settings_model.dart';
import '../models/schedule_item_model.dart';

class PlannerRepositoryImpl implements PlannerRepository {
  final PlannerRemoteDataSource remoteDataSource;

  PlannerRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ScheduleItemEntity>> watchItemsForDate(DateTime date) {
    return remoteDataSource.watchItemsForDate(date);
  }

  @override
  Stream<List<ScheduleItemEntity>> watchItemsInRange(DateTime start, DateTime end) {
    return remoteDataSource.watchItemsInRange(start, end);
  }

  @override
  Future<Either<Failure, void>> addItem(ScheduleItemEntity item) async {
    try {
      await remoteDataSource.addItem(ScheduleItemModel.fromEntity(item));
      return const Right(null);
    } catch (e) {
      return Left(PlannerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateItem(ScheduleItemEntity item) async {
    try {
      await remoteDataSource.updateItem(ScheduleItemModel.fromEntity(item));
      return const Right(null);
    } catch (e) {
      return Left(PlannerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async {
    try {
      await remoteDataSource.deleteItem(itemId);
      return const Right(null);
    } catch (e) {
      return Left(PlannerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> duplicateItemsToDate(
    DateTime sourceDate,
    List<DateTime> targetDates,
  ) async {
    try {
      await remoteDataSource.duplicateItemsToDate(sourceDate, targetDates);
      return const Right(null);
    } catch (e) {
      return Left(PlannerFailure(e.toString()));
    }
  }

  @override
  Stream<PlannerSettingsEntity> watchSettings() {
    return remoteDataSource.watchSettings();
  }

  @override
  Future<Either<Failure, void>> updateSettings(PlannerSettingsEntity settings) async {
    try {
      await remoteDataSource.updateSettings(PlannerSettingsModel.fromEntity(settings));
      return const Right(null);
    } catch (e) {
      return Left(PlannerFailure(e.toString()));
    }
  }
}
