import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

// Every subcollection a user's data lives in — kept in one place so a new
// feature's collection doesn't get silently missed by account deletion.
const _userSubcollections = ['tasks', 'notes', 'schedule_items', 'settings', 'progress', 'notifications'];

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<void> deleteAccount();
  Stream<UserModel?> get authStateChanges;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email'],
              // Required on Android to obtain an ID token for Firebase Auth.
              // Without this, google_sign_in can't complete the OAuth handshake
              // and throws ApiException: 7 (NETWORK_ERROR).
              serverClientId:
                  '603293938333-hvqq5qeatp9f3he8qc8iia30h9mpmg72.apps.googleusercontent.com',
            ),
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign in aborted');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _firebaseAuth.signInWithCredential(credential);
    final user = result.user!;

    // Write a lightweight profile so the admin panel can list users by
    // name/email/join-date.  SetOptions(merge:true) ensures this never
    // overwrites fields written by other parts of the app (e.g. userType).
    await _firestore.collection('users').doc(user.uid).set(
      {
        'email': user.email,
        'displayName': user.displayName,
        // Only write createdAt once — if the field already exists, merge
        // means it is left untouched on subsequent sign-ins.
        if (result.additionalUserInfo?.isNewUser == true)
          'createdAt': DateTime.now().toIso8601String(),
      },
      SetOptions(merge: true),
    );

    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _deleteAllUserData(user.uid);

    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code != 'requires-recent-login') rethrow;
      await _reauthenticate(user);
      await user.delete();
    }

    // user.delete() only removes the Firebase Auth record — it doesn't
    // touch the Google Sign-In plugin's own cached session. Without this,
    // the device still "remembers" the Google account, so the next
    // "Continue with Google" tap can silently re-authenticate without the
    // account picker, which reads as if the deleted account never went
    // away. disconnect() (not just signOut()) also revokes this app's
    // OAuth grant on Google's side, matching what users expect from
    // "delete my account."
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // No cached Google session to disconnect (e.g. account created via
      // a different provider) — signOut() is a safe, always-available
      // fallback that still clears any local cache.
      await _googleSignIn.signOut();
    }
  }

  Future<void> _deleteAllUserData(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    for (final name in _userSubcollections) {
      await _deleteCollection(userDoc.collection(name));
    }
    // No-op if the parent doc was never directly written (subcollections
    // don't require their parent to exist), but harmless either way.
    await userDoc.delete();
  }

  Future<void> _deleteCollection(CollectionReference<Map<String, dynamic>> ref) async {
    const batchSize = 200;
    while (true) {
      final snapshot = await ref.limit(batchSize).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < batchSize) return;
    }
  }

  Future<void> _reauthenticate(User user) async {
    final googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Re-authentication was cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(
          (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
        );
  }
}
