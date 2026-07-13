import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';

const _hasCompletedOnboardingCardKey = 'has_completed_onboarding_card';

/// Whether the "Getting started" card has ever reached 4/4 for this user.
/// Once true it stays true permanently (persisted to disk) so the card
/// doesn't reappear if a later condition it depends on becomes false again.
class OnboardingCardNotifier extends StateNotifier<AsyncValue<bool>> {
  final Ref _ref;

  OnboardingCardNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    state = AsyncValue.data(prefs.getBool(_hasCompletedOnboardingCardKey) ?? false);
  }

  Future<void> markCompleted() async {
    if (state.value == true) return;
    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_hasCompletedOnboardingCardKey, true);
    state = const AsyncValue.data(true);
  }
}

final onboardingCardCompletedProvider =
    StateNotifierProvider<OnboardingCardNotifier, AsyncValue<bool>>((ref) {
  return OnboardingCardNotifier(ref);
});
