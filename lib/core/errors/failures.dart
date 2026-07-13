import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class TaskFailure extends Failure {
  const TaskFailure(super.message);
}

class PlannerFailure extends Failure {
  const PlannerFailure(super.message);
}

class AchievementsFailure extends Failure {
  const AchievementsFailure(super.message);
}

class NoteFailure extends Failure {
  const NoteFailure(super.message);
}