import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// models
import '../models/cart.dart';
import '../models/product_model.dart';

// services
import '../services/cart_service.dart';

// providers
import '../providers/cart_provider.dart';

// widgets
import '../widgets/custom_text.dart';

// screens
import 'details_screen.dart';

// Enhancement 1:
// Displays the user's shopping cart.
class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({super.key, this.userId = 1});

  // Creates the state for the cart screen.
  @override
  State<CartScreen> createState() => _CartScreenState();
}

// Manages the cart items and quantities.
class _CartScreenState extends State<CartScreen> {
  late final Future<List<Cart>> _cartsFuture;

  // Keeps API cart quantities in memory during the app session.
  static final Map<int, int> _apiQuantities = {};

  @override
  void initState() {
    super.initState();

    // Enhancement 3:
    // Retrieves the carts from the DummyJSON Cart API.
    _cartsFuture = CartService().getAllCarts();
  }

  // Gets the complete product information from the API.
  Future<Product> _getProduct(int productId) async {
    final response = await http.get(
      Uri.parse('https://dummyjson.com/products/$productId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load product details');
    }

    return Product.fromJson(jsonDecode(response.body));
  }

  // Opens the selected product details screen.
  Future<void> _openProductDetails(int productId) async {
    try {
      final product = await _getProduct(productId);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load product details.')),
      );
    }
  }

  // Gets the current quantity of an API cart product.
  int _getApiQuantity(dynamic product) {
    return _apiQuantities[product.id] ?? product.quantity;
  }

  // Increases the quantity of an API cart product.
  void _increaseApiQuantity(dynamic product) {
    final currentQuantity = _getApiQuantity(product);

    setState(() {
      _apiQuantities[product.id] = currentQuantity + 1;
    });
  }

  // Decreases the quantity of an API cart product.
  void _decreaseApiQuantity(dynamic product) {
    final currentQuantity = _getApiQuantity(product);

    if (currentQuantity <= 1) {
      return;
    }

    setState(() {
      _apiQuantities[product.id] = currentQuantity - 1;
    });
  }

  // Builds the cart screen interface.
  @override
  Widget build(BuildContext context) {
    // Watches the session cart so the screen updates
    // whenever a product or quantity changes.
    final sessionCart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),
      body: FutureBuilder<List<Cart>>(
        future: _cartsFuture,
        builder: (context, snapshot) {
          // Shows a loading indicator while the cart loads.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Shows an error if the API request fails.
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
              ),
            );
          }

          final carts = snapshot.data ?? [];

          // Enhancement 3:
          // Gets only the cart belonging to the current user.
          final userCarts = carts
              .where((cart) => cart.userId == widget.userId)
              .toList();

          final Cart? apiCart = userCarts.isNotEmpty ? userCarts.first : null;

          // Shows an empty cart message if there are
          // no API products and no session products.
          if (apiCart == null && sessionCart.items.isEmpty) {
            return Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 8.h),
                  children: [
                    // API cart products fetched from the DummyJSON API
                    if (apiCart != null)
                      ...apiCart.products.map((product) {
                        final quantity = _getApiQuantity(product);

                        final itemTotal = product.price * quantity;

                        return _buildApiCartItem(product, quantity, itemTotal);
                      }),

                    // Cart products added during the current session
                    ...sessionCart.items.map((item) {
                      final product = item.product;

                      final quantity = item.quantity;

                      final itemTotal = product.price * quantity;

                      return _buildSessionCartItem(
                        product,
                        quantity,
                        itemTotal,
                      );
                    }),
                  ],
                ),
              ),

              // Cart totals and checkout button.
              _buildCartSummary(apiCart, sessionCart),
            ],
          );
        },
      ),
    );
  }

  // Enhancement 1:
  // Makes each cart item clickable and opens the product detail screen when selected.
  Widget _buildApiCartItem(dynamic product, int quantity, double itemTotal) {
    return GestureDetector(
      onTap: () {
        _openProductDetails(product.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product image.
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: product.thumbnail,
                width: 75.w,
                height: 85.h,
                fit: BoxFit.contain,
                placeholder: (context, url) {
                  return SizedBox(
                    width: 75.w,
                    height: 85.h,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorWidget: (context, url, error) {
                  return SizedBox(
                    width: 75.w,
                    height: 85.h,
                    child: Icon(Icons.broken_image, size: 28.sp),
                  );
                },
              ),
            ),

            SizedBox(width: 10.w),

            // Product information.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.title,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFC325),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    '${product.discountPercentage.toStringAsFixed(0)}% off • \$${itemTotal.toStringAsFixed(2)} total',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 6.w),

            // API cart quantity controls.
            _buildApiQuantityControls(product, quantity),
          ],
        ),
      ),
    );
  }

  // Builds a product added during the current session.
  Widget _buildSessionCartItem(
    Product product,
    int quantity,
    double itemTotal,
  ) {
    return GestureDetector(
      onTap: () {
        _openProductDetails(product.id);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product image.
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: product.thumbnail,
                width: 75.w,
                height: 85.h,
                fit: BoxFit.contain,
                placeholder: (context, url) {
                  return SizedBox(
                    width: 75.w,
                    height: 85.h,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorWidget: (context, url, error) {
                  return SizedBox(
                    width: 75.w,
                    height: 85.h,
                    child: Icon(Icons.broken_image, size: 28.sp),
                  );
                },
              ),
            ),

            SizedBox(width: 10.w),

            // Product information.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: product.title,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFC325),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    '${product.discountPercentage.toStringAsFixed(0)}% off • \$${itemTotal.toStringAsFixed(2)} total',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 6.w),

            // Session cart quantity controls.
            _buildSessionQuantityControls(product.id, quantity),
          ],
        ),
      ),
    );
  }

  // Builds quantity controls for API cart products.
  Widget _buildApiQuantityControls(dynamic product, int quantity) {
    return Column(
      children: [
        SizedBox(
          width: 34.w,
          height: 32.h,
          child: ElevatedButton(
            onPressed: () {
              _increaseApiQuantity(product);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC325),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
            child: Icon(Icons.add, size: 18.sp),
          ),
        ),

        SizedBox(height: 5.h),

        Text(
          quantity.toString(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 5.h),

        SizedBox(
          width: 34.w,
          height: 32.h,
          child: ElevatedButton(
            onPressed: quantity > 1
                ? () {
                    _decreaseApiQuantity(product);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8E7ED),
              disabledBackgroundColor: const Color(0xFFE8E7ED),
              foregroundColor: Colors.black,
              disabledForegroundColor: Colors.grey,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
            child: Icon(Icons.remove, size: 18.sp),
          ),
        ),
      ],
    );
  }

  // Builds quantity controls for session products.
  Widget _buildSessionQuantityControls(int productId, int quantity) {
    return Column(
      children: [
        SizedBox(
          width: 34.w,
          height: 32.h,
          child: ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().increaseQuantity(productId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC325),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
            child: Icon(Icons.add, size: 18.sp),
          ),
        ),

        SizedBox(height: 5.h),

        Text(
          quantity.toString(),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 5.h),

        SizedBox(
          width: 34.w,
          height: 32.h,
          child: ElevatedButton(
            onPressed: quantity > 1
                ? () {
                    context.read<CartProvider>().decreaseQuantity(productId);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE8E7ED),
              disabledBackgroundColor: const Color(0xFFE8E7ED),
              foregroundColor: Colors.black,
              disabledForegroundColor: Colors.grey,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
            child: Icon(Icons.remove, size: 18.sp),
          ),
        ),
      ],
    );
  }

  // Builds the cart summary and checkout button.
  Widget _buildCartSummary(Cart? cart, CartProvider sessionCart) {
    double subtotal = 0;
    double discountedTotal = 0;

    // Calculates totals from the API cart.
    if (cart != null) {
      for (final product in cart.products) {
        final quantity = _getApiQuantity(product);

        subtotal += product.price * quantity;

        discountedTotal +=
            (product.discountedTotal / product.quantity) * quantity;
      }
    }

    // Calculates totals from session products.
    for (final item in sessionCart.items) {
      final product = item.product;
      final quantity = item.quantity;

      subtotal += product.price * quantity;

      discountedTotal += product.price * quantity;
    }

    final discount = subtotal - discountedTotal;

    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 14.h),
      color: const Color(0xFFF9F7FF),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),

              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFC325),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discount:',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),

              Text(
                '-\$${discount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFC325),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order confirmed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC325),
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Confirm Order',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
