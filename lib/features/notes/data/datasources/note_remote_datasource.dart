import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';

abstract class NoteRemoteDataSource {
  Stream<List<NoteModel>> watchNotes();
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String noteId);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NoteRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _notesRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');
    return _firestore.collection('users').doc(uid).collection('notes');
  }

  @override
  Stream<List<NoteModel>> watchNotes() {
    return _notesRef.orderBy('updatedAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map(NoteModel.fromFirestore).toList(),
        );
  }

  @override
  Future<void> addNote(NoteModel note) async {
    await _notesRef.doc(note.id).set(note.toFirestore());
  }

  @override
  Future<void> updateNote(NoteModel note) async {
    await _notesRef.doc(note.id).update(note.toFirestore());
  }

  @override
  Future<void> deleteNote(String noteId) async {
    await _notesRef.doc(noteId).delete();
  }
}
