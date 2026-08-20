import 'package:flutter/material.dart';

import '../models/product_model.dart';

// Enhancement 3:
// Stores cart items for the current app session only.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// Manages products added to the cart during the current session.
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  // Returns all products currently in the session cart.
  List<CartItem> get items => List.unmodifiable(_items);

  // Returns the total number of products in the cart.
  int get itemCount {
    int count = 0;

    for (final item in _items) {
      count += item.quantity;
    }

    return count;
  }

  // Adds a product to the session cart.
  // If the product is already in the cart,
  // its quantity is increased instead.
  void addToCart(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
  }

  // Increases the quantity of a product.
  void increaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  // Decreases the quantity of a product.
  void decreaseQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  // Gets the quantity of a specific product.
  int getQuantity(int productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index == -1) {
      return 0;
    }

    return _items[index].quantity;
  }

  // Removes a product completely from the session cart.
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);

    notifyListeners();
  }

  // Clears all session cart products.
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
