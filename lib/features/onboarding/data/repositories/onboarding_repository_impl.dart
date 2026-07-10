import '../../domain/entities/user_type.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<UserType?> getUserType() async {
    final value = await localDataSource.getUserType();
    return UserType.fromStorageValue(value);
  }

  @override
  Future<void> setUserType(UserType type) async {
    await localDataSource.setUserType(type.storageValue);
  }
}
