import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';

class SettingsService {

  Future<AppSettings> loadSettings() async {

    final prefs =
        await SharedPreferences.getInstance();

    return AppSettings(
      serverIp: prefs.getString(
              "server_ip") ??
          "192.168.1.78",

      port: prefs.getInt(
              "port") ??
          8080,

      deleteMode: prefs.getString(
              "delete_mode") ??
          "ask",
    );
  }

  Future<void> saveSettings(
      AppSettings settings) async {

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      "server_ip",
      settings.serverIp,
    );

    await prefs.setInt(
      "port",
      settings.port,
    );

    await prefs.setString(
      "delete_mode",
      settings.deleteMode,
    );
  }
}