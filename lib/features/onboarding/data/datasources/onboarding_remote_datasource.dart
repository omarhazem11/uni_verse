import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class OnboardingRemoteDataSource {
  Future<String?> getUserType();
  Future<void> setUserType(String value);
}

/// Stored as a field on the users/{uid} doc itself (not a subcollection) —
/// it's per-user account metadata, not a list of records like tasks/notes.
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  OnboardingRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> get _userDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');
    return _firestore.collection('users').doc(uid);
  }

  @override
  Future<String?> getUserType() async {
    // Try the local Firestore cache first — instant for returning users who
    // have had the doc loaded at least once. Falls through to a server read
    // only on a genuine cache miss (first-ever login on this device).
    try {
      final cached = await _userDoc.get(const GetOptions(source: Source.cache));
      if (cached.exists) return cached.data()?['userType'] as String?;
    } catch (_) {
      // Cache miss — doc not yet in local store.
    }
    final snapshot = await _userDoc.get();
    return snapshot.data()?['userType'] as String?;
  }

  @override
  Future<void> setUserType(String value) async {
    await _userDoc.set({'userType': value}, SetOptions(merge: true));
  }
}
