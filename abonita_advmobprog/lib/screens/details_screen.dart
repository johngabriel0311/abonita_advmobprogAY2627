import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';

/// Displays the selected product details.
class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  /// Creates the state for the product details screen.
  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

/// Manages the product details and quantity.
class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _quantity = 1;

  /// Increases the selected quantity.
  void _increaseQuantity() {
    setState(() {
      if (_quantity < widget.product.stock) {
        _quantity++;
      }
    });
  }

  /// Decreases the selected quantity.
  void _decreaseQuantity() {
    setState(() {
      if (_quantity > 1) {
        _quantity--;
      }
    });
  }

  /// Builds the product details interface.
  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final double totalPrice = product.price * _quantity;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFF354591),
        foregroundColor: Colors.white,
        elevation: 0,

        title: Text(
          'Product',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [IconButton(icon: const Icon(Icons.share), onPressed: () {})],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Displays the main product image.
                  Container(
                    width: double.infinity,
                    height: 270.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CachedNetworkImage(
                        imageUrl: product.thumbnail,
                        fit: BoxFit.contain,

                        // Shows a loading indicator while the image loads.
                        placeholder: (context, url) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },

                        // Shows an icon if the image fails to load.
                        errorWidget: (context, url, error) {
                          return Icon(
                            Icons.broken_image,
                            size: 40.sp,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Displays product badges.
                  Row(
                    children: [
                      if (product.stock > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E9F5),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'In Stock',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF354591),
                            ),
                          ),
                        ),

                      SizedBox(width: 8.w),

                      if (product.discountPercentage > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE7A3),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFC325),
                            ),
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Displays the product name.
                  Text(
                    product.title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  // Displays the rating and review count.
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFC325)),

                      SizedBox(width: 5.w),

                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Displays the product price.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF354591),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      if (product.discountPercentage > 0)
                        Text(
                          '\$${(product.price / (1 - product.discountPercentage / 100)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.sp,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                    ],
                  ), // <-- THIS WAS MISSING

                  SizedBox(height: 4.h),

                  Text(
                    'Stock: ${product.stock}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),

                  SizedBox(height: 6.h),

                  SizedBox(height: 16.h),

                  const Divider(),

                  SizedBox(height: 10.h),

                  // Displays the product description.
                  Text(
                    product.description,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Displays category information.
                  Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 18.sp,
                        color: const Color(0xFF354591),
                      ),

                      SizedBox(width: 8.w),

                      Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        product.category,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Displays the brand information.
                  Row(
                    children: [
                      Icon(
                        Icons.sell_outlined,
                        size: 18.sp,
                        color: const Color(0xFF354591),
                      ),

                      SizedBox(width: 8.w),

                      Text(
                        'Brand',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        product.brand,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Displays the shipping information.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 18.sp,
                        color: const Color(0xFF354591),
                      ),

                      SizedBox(width: 8.w),

                      Text(
                        'Shipping',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(width: 20.w),

                      Expanded(
                        child: Text(
                          product.shippingInformation,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom quantity and add-to-basket section.
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Quantity controls.
                Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F4),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1 ? _decreaseQuantity : null,
                        icon: const Icon(Icons.remove),
                      ),

                      Text(
                        _quantity.toString(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: _quantity < product.stock
                            ? _increaseQuantity
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 10.w),

                // Add to cart button.
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        // Enhancement 3:
                        // Adds the selected product and quantity to the cart using the cart functionality.
                        context.read<CartProvider>().addToCart(
                          product,
                          quantity: _quantity,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} added to basket'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF354591),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined),
                          SizedBox(width: 8.w),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
