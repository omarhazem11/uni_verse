import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<String?> getUserType();
  Future<void> setUserType(String value);
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  static const _userTypeKey = 'user_type';

  final SharedPreferences prefs;

  OnboardingLocalDataSourceImpl({required this.prefs});

  @override
  Future<String?> getUserType() async => prefs.getString(_userTypeKey);

  @override
  Future<void> setUserType(String value) async {
    await prefs.setString(_userTypeKey, value);
  }
}
