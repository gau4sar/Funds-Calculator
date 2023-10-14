import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../AppException.dart';
import 'base_api_services.dart';
import 'package:http/http.dart' as http;

class NetworkApiServices extends BaseApiServices {
  @override
  Future<dynamic> getApi(String url) async {
    String apiKey = dotenv.env['API_KEY'] ?? ""; // Provide a default value if not found
    final urlWithAPIKey = "$url&apikey=$apiKey";

    if (kDebugMode) {
      print(urlWithAPIKey);
    }

    dynamic responseJson;
    try {
      final response =
          await http.get(Uri.parse(urlWithAPIKey)).timeout(const Duration(seconds: 18));

      responseJson = returnResponse(response);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeOut {
      throw RequestTimeOut('Timeout');
    }

    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }

  @override
  Future<dynamic> postApi(data, String url) async {

    if (kDebugMode) {
      print(url);
      print(data);
    }

    dynamic responseJson;
    try {
      /*final response =
      await http.post(Uri.parse(url), body: jsonEncode(data)).timeout(const Duration(seconds: 10));*/
      final response =
          await http.post(Uri.parse(url), body: data).timeout(const Duration(seconds: 10));

      responseJson = returnResponse(response);
      print(responseJson);
    } on SocketException {
      throw InternetException('');
    } on RequestTimeOut {
      throw RequestTimeOut('Timeout');
    }

    if (kDebugMode) {
      print(responseJson);
    }
    return responseJson;
  }

  dynamic returnResponse(http.Response response) {
    print(response);
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw Exception400(response.body.toString());
      default:
        throw FetchDataException('Error while communication with server' +
            response.statusCode.toString());
    }
  }
}
