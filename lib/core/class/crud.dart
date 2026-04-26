// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/functions/checkinternet.dart';
import 'package:http/http.dart' as http;

class Crud {
  Future<Either<StatusRequest, Map>> postData(String linkurl, Map data) async {
    if (await checkInternet()) {
      final Map<String, String> bodyMap = data.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );

      print("Sending data: $bodyMap");
      // Ensure proper URL-encoding and UTF-8 charset (important for non-ASCII comments)
      final String bodyString = bodyMap.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      print("Raw body: $bodyString");
      var response = await http.post(Uri.parse(linkurl),
          body: bodyString,
          headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'});

      final String responseText = _decodeResponseBody(response);

      print("Response status: ${response.statusCode}");
      print("Response body: $responseText");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final decoded = jsonDecode(responseText);

          // --------------- أهم جزء هنا ----------------
          // لو الناتج List → حوّله إلى Map حتى لا ينهار باقي التطبيق
          if (decoded is List) {
            return Right({"data": decoded});
          }

          // لو Map → رجّعه كما هو
          if (decoded is Map) {
            return Right(decoded);
          }

          // أي نوع آخر → رجّعه جوه Map
          return Right({"data": decoded});
        } catch (e) {
          print("JSON decode error: $e");
          return const Left(StatusRequest.serverfailure);
        }
      } else {
        return const Left(StatusRequest.serverfailure);
      }
    } else {
      return const Left(StatusRequest.offlinefailure);
    }
  }

  String _decodeResponseBody(http.Response response) {
    try {
      return utf8.decode(response.bodyBytes);
    } catch (_) {
      return response.body;
    }
  }
}
