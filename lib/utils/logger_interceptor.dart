import 'package:http_interceptor/http_interceptor.dart';

class LoggerInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    print("Request to: ${data.url}");
    print("Request body: ${data.body}");
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    print("Response status: ${data.statusCode}");
    print("Response body: ${data.body}");
    return data;
  }
}
