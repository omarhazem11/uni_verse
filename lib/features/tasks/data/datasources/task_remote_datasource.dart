import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> watchTasks();
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> toggleComplete(String taskId, bool isCompleted);
  Future<void> deleteTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  TaskRemoteDataSourceImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _tasksRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('No authenticated user');
    return _firestore.collection('users').doc(uid).collection('tasks');
  }

  @override
  Stream<List<TaskModel>> watchTasks() {
    return _tasksRef.snapshots().map((snapshot) {
      final tasks = snapshot.docs.map(TaskModel.fromFirestore).toList();
      // Firestore can't null-sort a `dueDate` field cleanly, so tasks
      // without a due date are sorted client-side to the end instead.
      tasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      return tasks;
    });
  }

  @override
  Future<void> addTask(TaskModel task) async {
    await _tasksRef.doc(task.id).set(task.toFirestore());
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    await _tasksRef.doc(task.id).update(task.toFirestore());
  }

  @override
  Future<void> toggleComplete(String taskId, bool isCompleted) async {
    await _tasksRef.doc(taskId).update({'isCompleted': isCompleted});
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }
}
