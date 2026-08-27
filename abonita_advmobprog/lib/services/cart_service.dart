import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/cart.dart';

class CartService {
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(Uri.parse('$host/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List cartsJson = data['carts'] ?? [];

      return cartsJson.map((json) => Cart.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load carts');
    }
  }

  // Enhancement 3:
  // Retrieves the cart belonging to the currently authenticated user using their user ID.
  Future<Cart?> getCartByUserId(int userId) async {
    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List cartsJson = data['carts'] ?? [];

      if (cartsJson.isEmpty) {
        return null;
      }

      return Cart.fromJson(cartsJson.first);
    } else {
      throw Exception('Failed to load user cart');
    }
  }
}
