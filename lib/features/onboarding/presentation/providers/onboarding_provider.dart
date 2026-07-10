import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/onboarding_local_datasource.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/user_type.dart';
import '../../domain/repositories/onboarding_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final onboardingRepositoryProvider =
    FutureProvider<OnboardingRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return OnboardingRepositoryImpl(
    localDataSource: OnboardingLocalDataSourceImpl(prefs: prefs),
  );
});

// User's saved onboarding choice — null means the question hasn't been asked yet.
final userTypeProvider = FutureProvider<UserType?>((ref) async {
  final repository = await ref.watch(onboardingRepositoryProvider.future);
  return repository.getUserType();
});

class OnboardingNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> chooseUserType(UserType type) async {
    state = const AsyncValue.loading();
    final repository = await _ref.read(onboardingRepositoryProvider.future);
    await repository.setUserType(type);
    _ref.invalidate(userTypeProvider);
    state = const AsyncValue.data(null);
  }
}

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, AsyncValue<void>>((ref) {
  return OnboardingNotifier(ref);
});
