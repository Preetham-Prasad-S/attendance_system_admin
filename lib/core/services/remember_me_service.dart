import 'package:shared_preferences/shared_preferences.dart';

class RememberMeService {
  final SharedPreferences _sharedPreferences;

  static const String _key = "remember_me";

  RememberMeService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  Future<void> setRememberMe(bool value) async {
    await _sharedPreferences.setBool(_key, value);
  }

  bool getRememberme() {
    return _sharedPreferences.getBool(_key) ?? false;
  }

  Future<void> clear() async {
    await _sharedPreferences.remove(_key);
  }
}
