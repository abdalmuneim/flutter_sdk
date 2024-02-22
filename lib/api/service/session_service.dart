import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:geideapay/api/response/direct_session_api_response.dart';
import 'package:geideapay/api/service/base_service.dart';
import 'package:geideapay/api/service/contracts/session_service_contract.dart';
import 'package:geideapay/common/exceptions.dart';
import 'package:geideapay/common/my_strings.dart';
import 'package:geideapay/common/extensions.dart';
import 'package:http/http.dart' as http;

class SessionService with BaseApiService implements SessionServiceContract {
  @override
  Future<DirectSessionApiResponse> createSession(Map<String, Object?>? fields,
      String publicKey, String apiPassword, String baseUrl) async {
    genHeaders(publicKey, apiPassword);
    var url = 'https://api.merchant.geidea.net/payment-intent/api/v2/direct/session';

    http.Response response = await http.post(url.toUri(),
        body: jsonEncode(fields), headers: headers);
    var body = response.body;

    var statusCode = response.statusCode;

    switch (statusCode) {
      case HttpStatus.ok:
        Map<String, dynamic> responseBody = json.decode(body);
        return DirectSessionApiResponse.fromMap(responseBody);
      case HttpStatus.gatewayTimeout:
        throw AuthenticationException('Gateway timeout error');
      case HttpStatus.badRequest:
        Map<String, dynamic> responseBody = json.decode(body);
        throw AuthenticationException(responseBody["title"]);

      default:
        throw AuthenticationException(Strings.unKnownResponse);
    }
  }
}
