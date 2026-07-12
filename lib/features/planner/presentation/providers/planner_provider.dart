import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/planner_remote_datasource.dart';
import '../../data/repositories/planner_repository_impl.dart';
import '../../domain/entities/planner_settings_entity.dart';
import '../../domain/entities/schedule_item_entity.dart';
import '../../domain/repositories/planner_repository.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

final plannerRemoteDataSourceProvider = Provider<PlannerRemoteDataSource>((ref) {
  return PlannerRemoteDataSourceImpl();
});

final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return PlannerRepositoryImpl(remoteDataSource: ref.watch(plannerRemoteDataSourceProvider));
});

// Drives the day view — always kept date-only (midnight) so family
// providers keyed off it compare equal across a given day.
final selectedDateProvider = StateProvider<DateTime>((ref) => dateOnly(DateTime.now()));

final dayItemsProvider = StreamProvider.family<List<ScheduleItemEntity>, DateTime>((ref, date) {
  return ref.watch(plannerRepositoryProvider).watchItemsForDate(dateOnly(date));
});

// Keyed by a month anchor (any date within the target month) — used for
// the calendar's dot indicators.
final monthItemsProvider = StreamProvider.family<List<ScheduleItemEntity>, DateTime>((ref, monthAnchor) {
  final start = DateTime(monthAnchor.year, monthAnchor.month, 1);
  final end = DateTime(monthAnchor.year, monthAnchor.month + 1, 0);
  return ref.watch(plannerRepositoryProvider).watchItemsInRange(start, end);
});

final plannerSettingsProvider = StreamProvider<PlannerSettingsEntity>((ref) {
  return ref.watch(plannerRepositoryProvider).watchSettings();
});

// Whether the student has ever added a schedule item at all (any date) —
// drives the dashboard's getting-started progress. A decade-wide range is
// a pragmatic proxy for "all time" without adding a dedicated repository
// method just for this existence check.
final hasAnyScheduleItemsProvider = StreamProvider<bool>((ref) {
  final start = DateTime(DateTime.now().year - 5);
  final end = DateTime(DateTime.now().year + 5);
  return ref.watch(plannerRepositoryProvider).watchItemsInRange(start, end).map((items) => items.isNotEmpty);
});

class PlannerActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final PlannerRepository _repository;

  PlannerActionsNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<bool> addItem({
    required String title,
    String? description,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    required String colorHex,
    required String emoji,
  }) {
    final item = ScheduleItemEntity(
      id: const Uuid().v4(),
      title: title,
      description: description,
      date: dateOnly(date),
      startTime: startTime,
      endTime: endTime,
      colorHex: colorHex,
      emoji: emoji,
      createdAt: DateTime.now(),
    );
    return _run(() => _repository.addItem(item));
  }

  Future<bool> updateItem(ScheduleItemEntity item) => _run(() => _repository.updateItem(item));

  Future<bool> deleteItem(String itemId) => _run(() => _repository.deleteItem(itemId));

  Future<bool> duplicateItemsToDate(DateTime sourceDate, List<DateTime> targetDates) {
    return _run(() => _repository.duplicateItemsToDate(sourceDate, targetDates));
  }

  Future<bool> updateSettings(PlannerSettingsEntity settings) {
    return _run(() => _repository.updateSettings(settings));
  }

  Future<bool> _run(Future<Either<Failure, void>> Function() action) async {
    state = const AsyncValue.loading();
    final result = await action();
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

final plannerActionsProvider =
    StateNotifierProvider<PlannerActionsNotifier, AsyncValue<void>>((ref) {
  return PlannerActionsNotifier(ref.watch(plannerRepositoryProvider));
});
