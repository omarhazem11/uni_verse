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
    final sourceSnapshot = await _itemsRef
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startOfDay(sourceDate)))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_endOfDay(sourceDate)))
        .get();
    final sourceItems = sourceSnapshot.docs.map(ScheduleItemModel.fromFirestore).toList();

    final batch = _firestore.batch();
    for (final targetDate in targetDates) {
      final dayOffset = _startOfDay(targetDate).difference(_startOfDay(sourceDate));
      for (final item in sourceItems) {
        final newId = const Uuid().v4();
        final newItem = ScheduleItemModel(
          id: newId,
          title: item.title,
          description: item.description,
          date: _startOfDay(targetDate),
          startTime: item.startTime.add(dayOffset),
          endTime: item.endTime.add(dayOffset),
          colorHex: item.colorHex,
          emoji: item.emoji,
          createdAt: DateTime.now(),
        );
        batch.set(_itemsRef.doc(newId), newItem.toFirestore());
      }
    }
    await batch.commit();
  }

  @override
  Stream<PlannerSettingsModel> watchSettings() {
    return _settingsDoc.snapshots().asyncMap((snapshot) async {
      if (!snapshot.exists) {
        const defaults = PlannerSettingsModel();
        await _settingsDoc.set(defaults.toFirestore());
        return defaults;
      }
      return PlannerSettingsModel.fromFirestore(snapshot);
    });
  }

  @override
  Future<void> updateSettings(PlannerSettingsModel settings) async {
    await _settingsDoc.set(settings.toFirestore());
  }
}
