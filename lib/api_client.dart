import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/auth_model.dart';
import 'models/cart_model.dart';
import 'models/order_model.dart';
import 'models/promotion_model.dart';

class ApiClient {
  ApiClient({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  // BACKEND SERVER URL

  static const String baseUrl ='http://10.0.2.2:8000/api';

  final registerUrl = Uri.parse('http://10.0.2.2:8000/api/register',);

  final loginUrl = Uri.parse('http://10.0.2.2:8000/api/login',);

  //Status code : 200 ok, 201 created, 400 bad request, 403 forbidden, 404 not found, 422 validation error, 500 server error, 501 unautorized access etc

  // REGISTER
  
  Future<AuthModel> register({
    required Map<String, dynamic> params,
  }) async {
    final response = await _client.post(
      registerUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(params),
    );

    print(
      'REGISTER STATUS: ${response.statusCode}',
    );

    print(
      'REGISTER RESPONSE: ${response.body}',
    );

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Invalid registration response from server.',
      );
    }

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      final auth = AuthModel.fromJson(
        Map<String, dynamic>.from(data),
      );

      await saveToken(auth.token);

      return auth;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(
        data['message'] ??
            'Registration failed',
      );
    }

    throw Exception('Registration failed');
  }

  // LOGIN

  Future<AuthModel> login({
    required Map<String, dynamic> params,
  }) async {
    final response = await _client.post(
      loginUrl,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(params),
    );

    print(
      'LOGIN STATUS: ${response.statusCode}',
    );

    print(
      'LOGIN RESPONSE: ${response.body}',
    );

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Invalid login response from server.',
      );
    }

    if (response.statusCode == 200) {
      final auth = AuthModel.fromJson(
        Map<String, dynamic>.from(data),
      );

      await saveToken(auth.token);

      if (auth.user.name.isNotEmpty) {
        await saveUsername(
          auth.user.name,
        );
      }

      return auth;
    }

    if (data is Map<String, dynamic>) {
      throw Exception(
        data['message'] ??
            'Login failed',
      );
    }

    throw Exception('Login failed');
  }

  // USERNAME

  Future<void> saveUsername(
    String username,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'user_name',
      username,
    );
  }

  Future<String?> getUsername() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('user_name');
  }

  Future<void> removeUsername() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('user_name');
  }

  // LOGOUT

  Future<void> logout({
    required String token,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
      'LOGOUT STATUS: ${response.statusCode}',
    );

    print(
      'LOGOUT RESPONSE: ${response.body}',
    );

    await removeToken();
    await removeUsername();

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception('Logout failed');
    }
  }

  // PRODUCTS

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

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Invalid products response from server.',
      );
    }

    if (response.statusCode == 200) {
      return data['data'] ?? [];
    }

    throw Exception(
      data['message'] ??
          'Failed to fetch products',
    );
  }

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
      return Map<String, dynamic>.from(
        data['data'],
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to fetch product',
    );
  }

  // CREATE PRODUCT

  Future<dynamic> createProduct({
    required String token,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String pic,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'pic': pic,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to create product '
      '(${response.statusCode}): '
      '${response.body}',
    );
  }

  // UPDATE PRODUCT

  Future<dynamic> updateProduct({
    required int id,
    required String token,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String pic,
  }) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'pic': pic,
      }),
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Failed to update product '
      '(${response.statusCode}): '
      '${response.body}',
    );
  }

  //1. UserModel, AuthModel, ProductModel.
  //2.store auth token after login or registration in local storage usin shared_preferences.

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
        data['message'] ??
            'Failed to delete product',
      );
    }
  }

  // TOKEN

  Future<void> saveToken(
    String token,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'token',
      token,
    );

    print('TOKEN SAVED');
  }

  Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('token');
  }

  Future<void> removeToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('token');

    print('TOKEN REMOVED');
  }

  // GET CART

  Future<CartModel> getCart({
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print(
      'GET CART STATUS: ${response.statusCode}',
    );

    print(
      'GET CART RESPONSE: ${response.body}',
    );

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Invalid cart response from server.',
      );
    }

    if (response.statusCode == 200) {
      return CartModel.fromJson(
        Map<String, dynamic>.from(
          data['data'],
        ),
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to fetch cart',
    );
  }

  // ADD PRODUCT TO CART

  Future<CartModel> addToCart({
    required int productId,
    required int quantity,
    required String token,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/cart/items'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    print(
      'ADD TO CART STATUS: ${response.statusCode}',
    );

    print(
      'ADD TO CART RESPONSE: ${response.body}',
    );

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Invalid response from server: '
        '${response.body}',
      );
    }

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      if (data is Map<String, dynamic> &&
          data['data'] is Map<String, dynamic>) {
        return CartModel.fromJson(
          Map<String, dynamic>.from(
            data['data'],
          ),
        );
      }
      return await getCart(
        token: token,
      );
    }

    if (data is Map<String, dynamic>) {
      throw Exception(
        data['message'] ??
            'Failed to add product to cart',
      );
    }

    throw Exception(
      'Failed to add product to cart '
      '(${response.statusCode})',
    );
  }

  // UPDATE CART ITEM

  Future<CartModel> updateCartItem({
    required int cartItemId,
    required int quantity,
    required String token,
  }) async {
    final response = await _client.put(
      Uri.parse(
        '$baseUrl/cart/items/$cartItemId',
      ),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'quantity': quantity,
      }),
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode == 200) {
      return CartModel.fromJson(
        Map<String, dynamic>.from(
          data['data'],
        ),
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to update cart',
    );
  }

  // REMOVE CART ITEM

  Future<CartModel> removeCartItem({
    required int cartItemId,
    required String token,
  }) async {
    final response = await _client.delete(
      Uri.parse(
        '$baseUrl/cart/items/$cartItemId',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode == 200) {
      return CartModel.fromJson(
        Map<String, dynamic>.from(
          data['data'],
        ),
      );
    }

    throw Exception(
      data['message'] ??
          'Failed to remove cart item',
    );
  }

  // CLEAR CART

  Future<void> clearCart({
    required String token,
  }) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode != 200) {
      throw Exception(
        data['message'] ??
            'Failed to clear cart',
      );
    }
  }

  // PROMOTIONS
  
  Future<List<PromotionModel>> getPromotions({
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/promotions'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode == 200) {
      final List<dynamic> promotions =
          data['data'] ?? [];

      return promotions
          .map(
            (promotion) =>
                PromotionModel.fromJson(
              Map<String, dynamic>.from(
                promotion,
              ),
            ),
          )
          .toList();
    }

    throw Exception(data['message'] ??
      'Failed to fetch promotions',
    );
  }

  Future<PromotionModel> getPromotion({
    required String code,
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse(
        '$baseUrl/promotions/$code',
      ),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode == 200) {
      return PromotionModel.fromJson(Map<String, dynamic>.from(data['data'],),);
    }

    throw Exception(
      data['message'] ??
          'Promotion not found',
    );
  }

  // ORDERS

  Future<List<OrderModel>> getOrders({
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode == 200) {
      final List<dynamic> orders =
          data['data'] ?? [];

      return orders
          .map(
            (order) => OrderModel.fromJson(
              Map<String, dynamic>.from(
                order,
              ),
            ),
          )
          .toList();
    }

    throw Exception(
      data['message'] ??
          'Failed to fetch orders',
    );
  }

  Future<OrderModel> getOrder({
    required int orderId,
    required String token,
  }) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode == 200) {
      return OrderModel.fromJson(Map<String, dynamic>.from(  data['data'],),
      );
    }

    throw Exception(data['message'] ??
      'Failed to fetch order',
    );
  }

  // CREATE ORDER / CHECKOUT

  Future<OrderModel> createOrder({
    required String token,
    required String paymentMethod,
    String? promotionCode,
  }) async {
    final Map<String, dynamic> body = {
      'payment_method': paymentMethod,
    };

    if (promotionCode != null && promotionCode.isNotEmpty) {
      body['promotion_code'] = promotionCode;
    }

    final response = await _client.post(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode == 201) {
      return OrderModel.fromJson(Map<String, dynamic>.from(data['data'],),);
    }

    throw Exception(data['message'] ??
      'Failed to create order',
    );
  }
}
