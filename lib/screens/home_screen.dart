import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'settings_screen.dart';

import '../services/upload_service.dart';
import '../services/settings_service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  List<PlatformFile>
      selectedFiles = [];

  Set<int>
      checkedFiles = {};

  bool isUploading = false;

  double uploadProgress = 0;

  Future<void>
      selectFiles() async {

    FilePickerResult?
        result =
            await FilePicker
                .platform
                .pickFiles(

      allowMultiple: true,

      withData: true,
    );

    if (result == null) {
      return;
    }

    setState(() {

      selectedFiles =
          result.files;

      checkedFiles.clear();
    });
  }

  Future<void>
    clearAllFiles() async {

  final result =
      await showDialog<bool>(

    context: context,

    builder: (_) =>
        AlertDialog(

      title: const Text(
        "確認",
      ),

      content: const Text(
        "選択中のファイルを全て解除しますか？",
      ),

      actions: [

        TextButton(

          onPressed: () {

            Navigator.pop(
              context,
              false,
            );
          },

          child: const Text(
            "キャンセル",
          ),
        ),

        TextButton(

          onPressed: () {

            Navigator.pop(
              context,
              true,
            );
          },

          child: const Text(
            "解除",
          ),
        ),
      ],
    ),
  );

  if (result != true) {
    return;
  }

  setState(() {

    selectedFiles.clear();

    checkedFiles.clear();
  });
  }

  Future<void>
      removeCheckedFiles() async {

    if (checkedFiles.isEmpty) {

      ScaffoldMessenger.of(
              context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "解除対象を選択してください",
          ),
        ),
      );

      return;
    }

    final result =
        await showDialog<bool>(

      context: context,

      builder: (_) =>
          AlertDialog(

        title: const Text(
          "確認",
        ),

        content: Text(
          "${checkedFiles.length}件解除しますか？",
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(
                context,
                false,
              );
            },

            child: const Text(
              "キャンセル",
            ),
          ),

          TextButton(

            onPressed: () {

              Navigator.pop(
                context,
                true,
              );
            },

            child: const Text(
              "解除",
            ),
          ),
        ],
      ),
    );

    if (result != true) {
      return;
    }

    setState(() {

      selectedFiles =
          selectedFiles
              .asMap()
              .entries
              .where(

                (e) =>

                    !checkedFiles
                        .contains(
                            e.key),
              )
              .map(
                (e) => e.value,
              )
              .toList();

      checkedFiles.clear();
    });
  }
  
  Future<void>
      uploadFiles() async {

    if (selectedFiles.isEmpty) {

      if (!mounted) return;

      ScaffoldMessenger.of(
              context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "ファイルを選択してください",
          ),
        ),
      );

      return;
    }

    final settings =
        await SettingsService()
            .loadSettings();

    final pingResult =
        await ApiService().ping(

      settings.serverIp,

      settings.port,
    );

    if (!pingResult) {

      if (!mounted) return;

      showDialog(

        context: context,

        builder: (_) =>
            const AlertDialog(

          title: Text(
            "接続エラー",
          ),

          content: Text(
            "サーバーに接続できません",
          ),
        ),
      );

      return;
    }

    int success = 0;

    int failed = 0;

    setState(() {

      isUploading = true;

      uploadProgress = 0;
    });

    List<PlatformFile>
        successFiles = [];
        
    for (final file
        in selectedFiles) {

      try {

        final result =
            await UploadService()
                .uploadFile(

          file: file,

          ip: settings.serverIp,

          port: settings.port,
        );

        if (result) {

          success++;

          successFiles.add(
              file);

        } else {

          failed++;
        }

        setState(() {

          uploadProgress =
              (success + failed) /
              selectedFiles.length;
        });

      } catch (_) {

        failed++;
      }
    }

    setState(() {

      selectedFiles.removeWhere(

        (file) =>
            successFiles
                .contains(file),
      );

        checkedFiles.clear();

        isUploading = false;

        uploadProgress = 0;
    });

    if (!mounted) return;

    showDialog(

      context: context,

      builder: (_) =>
          AlertDialog(

        title: const Text(
          "送信結果",
        ),

        content: Text(

          "成功 : $success 件\n"
          "失敗 : $failed 件",
        ),

        actions: [

          TextButton(

            onPressed: () {

              Navigator.pop(
                context,
              );
            },

            child: const Text(
              "OK",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "iPhone Transfer",
        ),
      ),

      body: Padding(

        padding:
            const EdgeInsets.all(
                20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,

          children: [

            const SizedBox(
              height: 20,
            ),

            const Text(
              "選択ファイル",
              style: TextStyle(
                fontSize: 20,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Card(

              child: Padding(

                padding:
                    const EdgeInsets.all(
                        20),

                child: Column(

                  children: [

                    Text(
                      "${selectedFiles.length}件",

                      style:
                          const TextStyle(
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(

              onPressed:
                      isUploading
                          ? null
                          : selectFiles,

              child: const Text(
                "ファイル選択",
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton(

              onPressed:
                  isUploading
                      ? null
                      : uploadFiles,

              child: const Text(
                "送信",
              ),
            ),

            if (isUploading) ...[

              const SizedBox(
                height: 10,
              ),

              LinearProgressIndicator(
                value: uploadProgress,
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                "${(uploadProgress * 100).toStringAsFixed(0)}%",
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(
              height: 10,
            ),

            ElevatedButton(

              onPressed:
                  isUploading
                      ? null
                      : removeCheckedFiles,

              child: const Text(
                "選択解除",
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton(

              onPressed:
                  isUploading
                      ? null
                      : clearAllFiles,

              child: const Text(
                "全解除",
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Expanded(

              child:
                  ListView.builder(

                itemCount:
                    selectedFiles
                        .length,

                itemBuilder:
                    (context,
                        index) {

                  final file =
                      selectedFiles[
                          index];

                  return Card(

                    child:
                        ListTile(

                      leading:

                      Checkbox(

                          value:
                              checkedFiles
                                  .contains(index),

                          onChanged:
                              (value) {

                            setState(() {

                              if (value == true) {

                                checkedFiles.add(
                                  index,
                                );

                              } else {

                                checkedFiles.remove(
                                  index,
                                );
                              }
                            });
                        },
                      ),

                      title: Text(
                        file.name,
                      ),

                      subtitle: Text(
                        "${file.size} bytes",
                      ),

                      trailing:
                          IconButton(

                        icon:
                            const Icon(
                          Icons.delete,
                        ),

                        onPressed: () async {

                          final result =
                              await showDialog<bool>(

                            context: context,

                            builder: (_) =>
                                AlertDialog(

                              title: const Text(
                                "確認",
                              ),

                              content: Text(
                                "${file.name}\nを解除しますか？",
                              ),

                              actions: [

                                TextButton(

                                  onPressed: () {

                                    Navigator.pop(
                                      context,
                                      false,
                                    );
                                  },

                                  child: const Text(
                                    "キャンセル",
                                  ),
                                ),

                                TextButton(

                                  onPressed: () {

                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },

                                  child: const Text(
                                    "解除",
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (result != true) {
                            return;
                          }

                          setState(() {

                            selectedFiles.removeAt(
                              index,
                            );

                            checkedFiles.clear();
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            OutlinedButton(

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) =>
                        const SettingsScreen(),
                  ),
                );
              },

              child: const Text(
                "設定",
              ),
            ),
          ],
        ),
      ),
    );
  }
}