import 'package:http/http.dart'
    as http;

class ApiService {

  Future<bool> ping(
    String ip,
    int port,
  ) async {

    try {

      final response =
          await http
              .get(
                Uri.parse(
                  "http://$ip:$port/ping",
                ),
              )
              .timeout(
                const Duration(
                  seconds: 5,
                ),
              );

      return response.statusCode
          == 200;

    } catch (_) {

      return false;
    }
  }
}