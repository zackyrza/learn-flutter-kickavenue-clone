import 'package:dio/dio.dart';
import 'package:kickavenue_clone/helper/database.dart';

class Api {
  final dio = Dio();
  late String apiPath;

  Api() {
    apiPath = 'https://api.kickavenue.com';
  }

  Api.elasticSearch()
      : apiPath =
            'https://ecngcyc9sa.execute-api.ap-southeast-1.amazonaws.com/prod/search';

  Future<Map<String, dynamic>> request(String url) async {
    try {
      Response response;
      response = await dio.get('$apiPath/$url');
      return response.data;
    } catch (e) {
      return {
        'error': 'There is some error happening, please try again later',
      };
    }
  }

  Future<Map<String, dynamic>> getWithAuth(String url) async {
    final String token = await LocalStorage.instance.get('token');
    try {
      Response response;
      response = await dio.get('$apiPath/$url',
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ));
      return response.data;
    } catch (e) {
      return {
        'error': 'There is some error happening, please try again later',
      };
    }
  }

  Future<Map<String, dynamic>> post(
      String url, Map<String, dynamic> data) async {
    try {
      Response response;
      response = await dio.post('$apiPath/$url', data: data);
      return response.data;
    } catch (e) {
      return {
        'error': 'There is some error happening, please try again later',
      };
    }
  }
}
