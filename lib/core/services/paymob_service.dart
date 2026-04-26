import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymobService {
  final String apiKey = "YOUR_API_KEY";
  final String integrationId = "YOUR_INTEGRATION_ID";

  Future<String> getAuthToken() async {
    final response = await http.post(
      Uri.parse("https://accept.paymobsolutions.com/api/auth/tokens"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"api_key": apiKey}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)["token"];
    } else {
      throw Exception("Failed to get auth token");
    }
  }

  Future<String> createOrder(String authToken, double amount) async {
    final response = await http.post(
      Uri.parse("https://accept.paymobsolutions.com/api/ecommerce/orders"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken"
      },
      body: jsonEncode({
        "amount_cents": (amount * 100).toInt(),
        "currency": "EGP",
        "items": [],
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)["id"].toString();
    } else {
      throw Exception("Failed to create order");
    }
  }

  Future<String> getPaymentLink(String authToken, String orderId) async {
    final response = await http.post(
      Uri.parse("https://accept.paymobsolutions.com/api/acceptance/payment_keys"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken"
      },
      body: jsonEncode({
        "amount_cents": 10000, // Example: 100 EGP
        "currency": "EGP",
        "order_id": orderId,
        "integration_id": integrationId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body)["token"];
    } else {
      throw Exception("Failed to get payment link");
    }
  }
}