import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../services/settings_service.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState
    extends State<SettingsScreen> {

  final _ipController =
      TextEditingController();

  final _portController =
      TextEditingController();

  String deleteMode = "ask";

  @override
  void initState() {

    super.initState();

    loadSettings();
  }

  Future<void> loadSettings() async {

    final settings =
        await SettingsService()
            .loadSettings();

    _ipController.text =
        settings.serverIp;

    _portController.text =
        settings.port.toString();

    setState(() {

      deleteMode =
          settings.deleteMode;
    });
  }

  Future<void> saveSettings() async {

    final settings =
        AppSettings(
      serverIp:
          _ipController.text,

      port: int.tryParse(
              _portController.text) ??
          8080,

      deleteMode:
          deleteMode,
    );

    await SettingsService()
        .saveSettings(
            settings);

    if (!mounted) return;

    ScaffoldMessenger.of(
            context)
        .showSnackBar(
      const SnackBar(
        content:
            Text("保存しました"),
      ),
    );
  }

  Future<void>
      testConnection() async {

    bool result = false;

    try {

      result =
          await ApiService().ping(
        _ipController.text,
        int.parse(
          _portController.text,
        ),
      );

    } catch (e) {

      print(e);
    }

    print(
        "PING RESULT = $result");

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
            "接続テスト"),
        content: Text(
          result
              ? "接続成功"
              : "接続失敗",
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "設定",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
                20),

        child: ListView(
          children: [

            TextField(
              controller:
                  _ipController,

              decoration:
                  const InputDecoration(
                labelText:
                    "サーバーIP",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  _portController,

              keyboardType:
                  TextInputType
                      .number,

              decoration:
                  const InputDecoration(
                labelText:
                    "ポート",
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              "送信後処理",
            ),

            RadioListTile(
              value: "delete",
              groupValue:
                  deleteMode,

              title: const Text(
                  "削除する"),

              onChanged: (v) {

                setState(() {

                  deleteMode =
                      v!;
                });
              },
            ),

            RadioListTile(
              value: "keep",
              groupValue:
                  deleteMode,

              title: const Text(
                  "削除しない"),

              onChanged: (v) {

                setState(() {

                  deleteMode =
                      v!;
                });
              },
            ),

            RadioListTile(
              value: "ask",
              groupValue:
                  deleteMode,

              title: const Text(
                  "毎回確認"),

              onChanged: (v) {

                setState(() {

                  deleteMode =
                      v!;
                });
              },
            ),

            ElevatedButton(
              onPressed:
                  testConnection,

              child: const Text(
                "接続テスト",
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton(
              onPressed:
                  saveSettings,

              child:
                  const Text(
                "保存",
              ),
            ),
          ],
        ),
      ),
    );
  }
}