import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/cart.dart';

class CartService {
  // Retrieves all carts from DummyJSON.
  Future<List<Cart>> getAllCarts() async {
    final response = await http.get(Uri.parse('$host/carts'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List cartsJson = data['carts'] ?? [];

      return cartsJson
          .map((json) => Cart.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load carts');
    }
  }

  // Enhancement 3:
  // Retrieves the cart belonging to the currently
  // authenticated DummyJSON user using their user ID.
  Future<Cart?> getCartByUserId(int userId) async {
    // Firebase-created accounts do not have a
    // DummyJSON numeric user ID.
    //
    // In this case, there is no API cart to retrieve.
    // Returning null allows CartScreen to display
    // products stored in CartProvider instead.
    if (userId <= 0) {
      return null;
    }

    final response = await http.get(Uri.parse('$host/carts/user/$userId'));

    // A successful response means DummyJSON returned
    // the user's carts.
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      final List cartsJson = data['carts'] ?? [];

      // The user does not have a cart.
      if (cartsJson.isEmpty) {
        return null;
      }

      return Cart.fromJson(cartsJson.first as Map<String, dynamic>);
    }

    // If DummyJSON does not have a cart for this user,
    // treat it as an empty API cart instead of an error.
    if (response.statusCode == 404) {
      return null;
    }

    throw Exception('Failed to load user cart');
  }
}
