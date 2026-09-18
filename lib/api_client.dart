import 'dart:convert';

import 'package:http/http.dart' as http;


class ApiClient {

ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

//define backend server url
final registerUrl = Uri.parse("http://10.0.2.2:8000/api/register");
final loginUrl = Uri.parse("http://10.0.2.2:8000/api/login");
static const String baseUrl = 'http://10.0.2.2:8000/api';

/*
params: {
"key":value,
"key":value
}
status code : 200 ok, 201 created, 500 server error, 404 not found, 501 unautorized access, 
*/

Future<void> register({required Map<String, dynamic> params}) async{

  final response = await _client.post(registerUrl, headers: {
    "Accept":"application/json",
    "Content-Type":"application/json",
  }, body: jsonEncode(params));

  if (response.statusCode < 200 || response.statusCode > 201) {
    final message = "Server error";
            final responseData = jsonDecode(response.body);

    print(responseData["message"]);

    try {
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);
      }
    } catch (e) {
      print(e);
    }
  }
}

  Future<dynamic> login({required Map<String, dynamic> params}) async {

    try {
      final response = await _client.post(loginUrl, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },body: jsonEncode(params));

      print('LOGIN STATUS: ${response.statusCode}');
      print('LOGIN RESPONSE: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(
        data['message'] ?? 'Login failed',
      );
    } catch (e) {
      print('LOGIN ERROR: $e');
    }
  }

  // GET ALL PRODUCTS

Future<List<dynamic>> getProducts({
  required String token,
}) async {
  final response = await _client.get(
    Uri.parse('$baseUrl/products'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data['data'] ?? [];
  }

  throw Exception(
    data['message'] ?? 'Failed to fetch products',
  );
}

// GET SINGLE PRODUCT

Future<Map<String, dynamic>> getProduct({
  required int id,
  required String token,
}) async {
  final response = await _client.get(
    Uri.parse('$baseUrl/products/$id'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return Map<String, dynamic>.from(data['data']);
  }

  throw Exception(
    data['message'] ?? 'Failed to fetch product',
  );
}


 // this model should extend equatable. 

//1. UserModel, AuthModel, ProductModel.

//store auth token after login or registration in local storage usin shared_preferences.

// DELETE PRODUCT
Future<void> deleteProduct({
  required int id,
  required String token,
}) async {
  final response = await _client.delete(
    Uri.parse('$baseUrl/products/$id'),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode != 200) {
    throw Exception(
      data['message'] ?? 'Failed to delete product',
    );
  }
}
}