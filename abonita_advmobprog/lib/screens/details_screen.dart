import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/product_model.dart';
import '../widgets/custom_text.dart';

/// Displays the selected product details.
class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  /// Builds the product details interface.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displays the product image.
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                product.thumbnail,
                width: double.infinity,
                height: 250.h,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(height: 20.h),

            // Displays the product name.
            CustomText(
              text: product.title,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 8.h),

            // Displays the product brand.
            CustomText(text: product.brand, fontSize: 16.sp),

            SizedBox(height: 8.h),

            // Displays the product category.
            CustomText(text: product.category, fontSize: 16.sp),

            SizedBox(height: 12.h),

            // Displays the product price.
            CustomText(
              text: "\$${product.price}",
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),

            SizedBox(height: 12.h),

            // Displays the product rating.
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 6.w),
                Text(product.rating.toString()),
              ],
            ),

            SizedBox(height: 20.h),

            // Displays the product description.
            CustomText(text: product.description, fontSize: 16.sp),

            SizedBox(height: 20.h),

            // Displays the available stock.
            CustomText(text: "Stock: ${product.stock}", fontSize: 16.sp),
          ],
        ),
      ),
    );
  }
}
