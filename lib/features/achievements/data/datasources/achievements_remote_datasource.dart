import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/streak_calculator.dart';
import '../models/user_progress_model.dart';

abstract class AchievementsRemoteDataSource {
  Stream<UserProgressModel> watchProgress();
  Future<void> recordAppOpen();
  Future<void> recordTabVisit(String tabName);
  Future<void> recordTaskCompleted({required bool wasEarly});
  Future<void> recordPlannerItemAdded({required DateTime itemDate});
  Future<void> recordDuplicateDayUsed();
  Future<void> unlockBadgesAndAwardPoints(Map<String, DateTime> newUnlocks, int pointsToAdd);
}

class AchievementsRemoteDataSourceImpl implements AchievementsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AchievementsRemoteDataSourceImpl({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> get _doc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');
    return _firestore.collection('users').doc(uid).collection('progress').doc('summary');
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _mondayOf(DateTime d) {
    final day = _dateOnly(d);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  @override
  Stream<UserProgressModel> watchProgress() {
    // Deliberately read-only — UserProgressModel.fromFirestore already
    // falls back to defaults when the doc doesn't exist, so there's no
    // need to write anything back here. An earlier version wrote the
    // initial doc on first observation, which meant any screen watching
    // this stream while account deletion was wiping it would immediately
    // recreate it via this same snapshot listener, resurrecting the doc
    // moments after it was deleted. The doc still gets created lazily by
    // the record*/unlock* methods below (.set with merge, or .update on a
    // doc those callers ensure exists first), same as before.
    return _doc.snapshots().map(UserProgressModel.fromFirestore);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getDoc() async {
    try {
      return await _doc.get(const GetOptions(source: Source.cache));
    } catch (_) {
      return _doc.get();
    }
  }

  @override
  Future<void> recordAppOpen() async {
    final snapshot = await _getDoc();
    final current = UserProgressModel.fromFirestore(snapshot);
    final today = _dateOnly(DateTime.now());

    final update = computeStreakUpdate(
      lastActiveDate: current.lastActiveDate,
      currentStreak: current.currentStreak,
      longestStreak: current.longestStreak,
      today: today,
    );
    if (!update.changed) return; // already recorded today — no-op

    await _doc.set({
      'currentStreak': update.currentStreak,
      'longestStreak': update.longestStreak,
      'lastActiveDate': Timestamp.fromDate(today),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordTabVisit(String tabName) async {
    await _doc.set({
      'visitedTabs': FieldValue.arrayUnion([tabName]),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordTaskCompleted({required bool wasEarly}) async {
    await _doc.set({
      'tasksCompletedCount': FieldValue.increment(1),
      if (wasEarly) 'tasksCompletedEarlyCount': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordPlannerItemAdded({required DateTime itemDate}) async {
    final snapshot = await _getDoc();
    final data = snapshot.data() ?? {};
    final weekKey = _mondayOf(itemDate).toIso8601String().split('T').first;
    final dateKey = _dateOnly(itemDate).toIso8601String().split('T').first;

    final weekDates = Map<String, dynamic>.from(data['scheduledWeekDates'] as Map? ?? {});
    final thisWeek = Set<String>.from(weekDates[weekKey] as List? ?? const []);
    thisWeek.add(dateKey);
    weekDates[weekKey] = thisWeek.toList();

    final currentMax = data['maxScheduledDaysInAWeek'] as int? ?? 0;
    final newMax = thisWeek.length > currentMax ? thisWeek.length : currentMax;

    await _doc.set({
      'plannerItemsCount': FieldValue.increment(1),
      'scheduledWeekDates': weekDates,
      'maxScheduledDaysInAWeek': newMax,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> recordDuplicateDayUsed() async {
    await _doc.set({'hasUsedDuplicateDay': true}, SetOptions(merge: true));
  }

  @override
  Future<void> unlockBadgesAndAwardPoints(Map<String, DateTime> newUnlocks, int pointsToAdd) async {
    final updates = <String, dynamic>{'totalPoints': FieldValue.increment(pointsToAdd)};
    for (final entry in newUnlocks.entries) {
      updates['badgeUnlockedAt.${entry.key}'] = Timestamp.fromDate(entry.value);
    }
    // Ensure the doc exists first — a merge-set is a harmless no-op if it
    // already does. The update() below is required (not set merge:true)
    // for the dotted keys to be interpreted as nested-map paths rather
    // than one literal field name containing a dot, but update() throws
    // NOT_FOUND on a doc that doesn't exist yet, so it can't stand alone.
    await _doc.set({}, SetOptions(merge: true));
    await _doc.update(updates);
  }
}
