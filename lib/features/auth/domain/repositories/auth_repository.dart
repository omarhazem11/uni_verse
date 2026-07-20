import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithFacebook();
  Future<Either<Failure, void>> signOut();

  /// Permanently deletes the current user's Firestore data and Firebase
  /// Auth account. Re-authenticates via Google Sign-In first if Firebase
  /// requires a recent login for the deletion to proceed.
  Future<Either<Failure, void>> deleteAccount();
  Stream<UserEntity?> get authStateChanges;
}
