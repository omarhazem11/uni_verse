import '../entities/user_type.dart';

abstract class OnboardingRepository {
  Future<UserType?> getUserType();
  Future<void> setUserType(UserType type);
}
