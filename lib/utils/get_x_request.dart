import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

class HttpUtils extends GetConnect {
  static final _instance = HttpUtils._internal();

  factory HttpUtils() => _instance;
  HttpUtils._internal();

  void init({
    required String baseUrl,
    Map<String, String> header = const {'Content-Type': 'application/json'},
  }) {
    httpClient.baseUrl = baseUrl;
    httpClient.timeout = Duration(seconds: 1);

    // 请求拦截
    httpClient.addRequestModifier<void>((Request request) {
      print('-------${request.url}---------');
      // request.headers['Token'] = '';
      header.forEach((key, value) {
        request.headers[key] = value;
      });
      return request;
    });

    // 响应拦截
    httpClient.addResponseModifier((Request request, Response response) {
      print(response.statusCode);
      print(response.body);
      // 不等于200
      if (response.statusCode != 200) {
        // AppException stateException = AppException.create(error)
      }
      return response;
    });

    print("request初始化");
  }

  Future<Response<dynamic>> xGet({
    required String url,
    Map<String, String> params = const {},
    Map<String, String> query = const {},
    Map<String, String> header = const {},
  }) async {
    return get(url, query: query, headers: header);
  }

  Future<Response<dynamic>> xPost({
    required String url,
    Map<String, String> params = const {},
    Map<String, String> query = const {},
    Map<String, String> header = const {},
  }) async {
    return get(url, query: query, headers: header);
  }
}
