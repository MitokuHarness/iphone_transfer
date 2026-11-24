import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class UploadService {

  Future<bool> uploadFile({

    required PlatformFile file,

    required String ip,

    required int port,

  }) async {

    try {

      if (file.bytes == null) {
        return false;
      }

      final request =
          http.MultipartRequest(

        "POST",

        Uri.parse(
          "http://$ip:$port/api/upload",
        ),
      );

      request.files.add(

        http.MultipartFile.fromBytes(

          "file",

          file.bytes!,

          filename: file.name,
        ),
      );

      final response =
          await request
              .send()
              .timeout(

                const Duration(
                  seconds: 30,
                ),
              );

      if (response.statusCode !=
          200) {

        return false;
      }

      return true;

    } catch (_) {

      return false;
    }
  }
}