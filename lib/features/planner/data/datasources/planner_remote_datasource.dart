import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/planner_settings_model.dart';
import '../models/schedule_item_model.dart';

abstract class PlannerRemoteDataSource {
  Stream<List<ScheduleItemModel>> watchItemsForDate(DateTime date);
  Stream<List<ScheduleItemModel>> watchItemsInRange(DateTime start, DateTime end);
  Future<void> addItem(ScheduleItemModel item);
  Future<void> updateItem(ScheduleItemModel item);
  Future<void> deleteItem(String itemId);
  Future<void> duplicateItemsToDate(DateTime sourceDate, List<DateTime> targetDates);
  Stream<PlannerSettingsModel> watchSettings();
  Future<void> updateSettings(PlannerSettingsModel settings);
}

class PlannerRemoteDataSourceImpl implements PlannerRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PlannerRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _itemsRef =>
      _firestore.collection('users').doc(_uid).collection('schedule_items');

  DocumentReference<Map<String, dynamic>> get _settingsDoc =>
      _firestore.collection('users').doc(_uid).collection('settings').doc('planner');

  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  @override
  Stream<List<ScheduleItemModel>> watchItemsForDate(DateTime date) {
    return watchItemsInRange(date, date);
  }

  @override
  Stream<List<ScheduleItemModel>> watchItemsInRange(DateTime start, DateTime end) {
    return _itemsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfDay(start)))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endOfDay(end)))
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs.map(ScheduleItemModel.fromFirestore).toList();
      items.sort((a, b) => a.startTime.compareTo(b.startTime));
      return items;
    });
  }

  @override
  Future<void> addItem(ScheduleItemModel item) async {
    await _itemsRef.doc(item.id).set(item.toFirestore());
  }

  @override
  Future<void> updateItem(ScheduleItemModel item) async {
    await _itemsRef.doc(item.id).update(item.toFirestore());
  }

  @override
  Future<void> deleteItem(String itemId) async {
    await _itemsRef.doc(itemId).delete();
  }

  @override
  Future<void> duplicateItemsToDate(DateTime sourceDate, List<DateTime> targetDates) async {
    final query = _itemsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfDay(sourceDate)))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endOfDay(sourceDate)));
    QuerySnapshot<Map<String, dynamic>> sourceSnapshot;
    try {
      // Use cached query results (populated by the active stream listener on
      // the planner page). Never fall back to server — that hangs offline.
      sourceSnapshot = await query.get(const GetOptions(source: Source.cache));
    } catch (_) {
      return; // source items not in cache — nothing to copy
    }
    final sourceItems = sourceSnapshot.docs.map(ScheduleItemModel.fromFirestore).toList();
    if (sourceItems.isEmpty) return;

    final batch = _firestore.batch();

    for (final targetDate in targetDates) {
      final dayOffset = _startOfDay(targetDate).difference(_startOfDay(sourceDate));

      // Fetch items already on the target date so we can skip conflicting ones.
      List<ScheduleItemModel> existingItems = [];
      try {
        final targetSnapshot = await _itemsRef
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfDay(targetDate)))
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endOfDay(targetDate)))
            .get(const GetOptions(source: Source.cache));
        existingItems = targetSnapshot.docs.map(ScheduleItemModel.fromFirestore).toList();
      } catch (_) {
        // No cache for this date — assume empty and copy everything.
      }

      for (final item in sourceItems) {
        final newStart = item.startTime.add(dayOffset);
        final newEnd = item.endTime.add(dayOffset);

        // Skip if the new item's time range overlaps any existing item on the
        // target date — prevents stacking duplicates on top of each other.
        final conflicts = existingItems.any(
          (e) => newStart.isBefore(e.endTime) && e.startTime.isBefore(newEnd),
        );
        if (conflicts) continue;

        final newId = const Uuid().v4();
        batch.set(
          _itemsRef.doc(newId),
          ScheduleItemModel(
            id: newId,
            title: item.title,
            description: item.description,
            date: _startOfDay(targetDate),
            startTime: newStart,
            endTime: newEnd,
            colorHex: item.colorHex,
            emoji: item.emoji,
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
      }
    }
    // Don't await — writes to local cache synchronously, server sync happens
    // in background. Stream listeners see the new items immediately.
    batch.commit();
  }

  @override
  Stream<PlannerSettingsModel> watchSettings() {
    // Deliberately read-only — PlannerSettingsModel.fromFirestore already
    // falls back to defaults when the doc doesn't exist. Writing the
    // defaults back here (as an earlier version did) meant any screen
    // watching this stream during account deletion would immediately
    // recreate the doc the instant it was deleted, via this same snapshot
    // listener. The doc is still created properly whenever the user
    // actually changes a setting, via updateSettings()'s full set().
    return _settingsDoc.snapshots().map(PlannerSettingsModel.fromFirestore);
  }

  @override
  Future<void> updateSettings(PlannerSettingsModel settings) async {
    await _settingsDoc.set(settings.toFirestore());
  }
}
