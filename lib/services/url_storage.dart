import 'package:shared_preferences/shared_preferences.dart';

class UrlStorage {
  static const _key = 'api_base_url';

  Future<String?> load() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  Future<void> save(String url) async =>
      (await SharedPreferences.getInstance()).setString(_key, url);
}
