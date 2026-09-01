import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

// models
import '../models/product_model.dart';

// services
import '../services/product_service.dart';

// widgets
import '../widgets/custom_text.dart';

// screens
import 'details_screen.dart';

// Displays the product list screen.
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  // Creates the state for the product screen.
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

// Manages the product list, search, and category filtering.
class _ProductScreenState extends State<ProductScreen> {
  late final Future<List<Product>> _productsFuture;

  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];

  String _selectedCategory = 'All';

  // Loads all products and categories when the screen starts.
  @override
  void initState() {
    super.initState();

    _productsFuture = ProductService().getAllProducts();

    _productsFuture.then((products) {
      if (!mounted) return;

      setState(() {
        _allProducts = products;
        _filteredProducts = products;

        _categories = products
            .map((product) => product.category)
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList();

        _categories.sort();
      });
    });
  }

  // Filters the product list based on the search input.
  void _searchProducts(String query) {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final matchesSearch = product.title.toLowerCase().contains(
          query.toLowerCase(),
        );

        final matchesCategory =
            _selectedCategory == 'All' || product.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // Filters the products by the selected category.
  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;

      final searchQuery = _searchController.text.toLowerCase();

      _filteredProducts = _allProducts.where((product) {
        final matchesSearch = product.title.toLowerCase().contains(searchQuery);

        final matchesCategory =
            category == 'All' || product.category == category;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // Returns an icon based on the product category.
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.apps;

      case 'beauty':
        return Icons.face;

      case 'fragrances':
        return Icons.local_florist;

      case 'furniture':
        return Icons.chair;

      case 'groceries':
        return Icons.shopping_basket;

      case 'laptops':
        return Icons.laptop;

      case 'mens-shirts':
        return Icons.checkroom;

      case 'mens-shoes':
        return Icons.directions_walk;

      case 'mens-watches':
        return Icons.watch;

      case 'mobile-accessories':
        return Icons.phone_android;

      case 'motorcycle':
        return Icons.two_wheeler;

      case 'skin-care':
        return Icons.spa;

      case 'smartphones':
        return Icons.smartphone;

      case 'sports-accessories':
        return Icons.sports_soccer;

      case 'sunglasses':
        return Icons.wb_sunny;

      case 'tablets':
        return Icons.tablet;

      case 'tops':
        return Icons.checkroom;

      case 'vehicle':
        return Icons.directions_car;

      case 'womens-bags':
        return Icons.shopping_bag;

      case 'womens-dresses':
        return Icons.dry_cleaning;

      case 'womens-jewellery':
        return Icons.diamond;

      case 'womens-shoes':
        return Icons.shopping_bag;

      case 'womens-watches':
        return Icons.watch;

      default:
        return Icons.category;
    }
  }

  // Formats category names for display.
  String _formatCategoryName(String category) {
    if (category == 'All') {
      return 'All';
    }

    return category
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Clears the search controller when the screen is disposed.
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Builds the product screen interface.
  @override
  Widget build(BuildContext context) {
    // -----------------------------------------
    // THEME COLORS
    // -----------------------------------------

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color primaryColor = const Color(0xFF354591);

    final Color yellowColor = const Color(0xFFFFD41C);

    final Color categoryCircleColor = isDarkMode
        ? const Color(0xFFE9E9E9)
        : Colors.grey.shade200;

    final Color categoryTextColor = isDarkMode ? Colors.white : Colors.black87;

    final Color searchTextColor = isDarkMode ? Colors.white : Colors.black87;

    final Color searchHintColor = isDarkMode ? Colors.white70 : Colors.black54;

    final Color searchBorderColor = isDarkMode
        ? Colors.white54
        : Colors.black54;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------
            // SEARCH BAR
            // -----------------------------------------
            TextField(
              controller: _searchController,

              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: searchTextColor,
              ),

              cursorColor: isDarkMode ? yellowColor : primaryColor,

              onChanged: _searchProducts,

              decoration: InputDecoration(
                hintText: 'Search products...',

                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.sp,
                  color: searchHintColor,
                ),

                prefixIcon: Icon(Icons.search, color: searchHintColor),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: searchBorderColor, width: 1.2),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? yellowColor : primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),

            SizedBox(height: 14.h),

            // -----------------------------------------
            // CATEGORIES
            // -----------------------------------------
            SizedBox(
              height: 80.h,

              child: _categories.isEmpty
                  ? const SizedBox()
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,

                      itemCount: _categories.length + 1,

                      separatorBuilder: (context, index) =>
                          SizedBox(width: 14.w),

                      itemBuilder: (context, index) {
                        final category = index == 0
                            ? 'All'
                            : _categories[index - 1];

                        final isSelected = _selectedCategory == category;

                        return GestureDetector(
                          onTap: () {
                            _selectCategory(category);
                          },

                          child: SizedBox(
                            width: 65.w,

                            child: Column(
                              children: [
                                // -----------------------------------------
                                // CATEGORY ICON
                                // -----------------------------------------
                                Container(
                                  width: 52.w,
                                  height: 52.w,

                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,

                                    color: isSelected
                                        ? primaryColor
                                        : categoryCircleColor,
                                  ),

                                  child: Icon(
                                    _getCategoryIcon(category),

                                    size: 24.sp,

                                    color: isSelected
                                        ? Colors.white
                                        : primaryColor,
                                  ),
                                ),

                                SizedBox(height: 6.h),

                                // -----------------------------------------
                                // CATEGORY NAME
                                // -----------------------------------------
                                Text(
                                  _formatCategoryName(category),

                                  textAlign: TextAlign.center,

                                  maxLines: 2,

                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontFamily: 'Poppins',

                                    fontSize: 10.sp,

                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,

                                    color: isSelected
                                        ? (isDarkMode
                                              ? yellowColor
                                              : primaryColor)
                                        : categoryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(height: 4.h),

            // -----------------------------------------
            // PRODUCTS
            // -----------------------------------------
            FutureBuilder<List<Product>>(
              future: _productsFuture,

              builder: (context, snapshot) {
                // Shows a loading indicator while products load.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),

                      child: CircularProgressIndicator(
                        color: isDarkMode ? yellowColor : primaryColor,
                      ),
                    ),
                  );
                }

                // Displays an error if the API request fails.
                if (snapshot.hasError) {
                  return Center(
                    child: CustomText(
                      text: 'Error: ${snapshot.error}',
                      fontSize: 14.sp,
                    ),
                  );
                }

                final products = snapshot.data ?? [];

                // Displays a message when the API returns no products.
                if (products.isEmpty) {
                  return Center(
                    child: CustomText(
                      text: 'No products found.',
                      fontSize: 14.sp,
                    ),
                  );
                }

                // Displays a message when search or category filtering
                // has no results.
                if (_filteredProducts.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.r),

                      child: CustomText(
                        text: 'No products found.',
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,

                  physics: const NeverScrollableScrollPhysics(),

                  itemCount: _filteredProducts.length,

                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,

                    crossAxisSpacing: 10.w,

                    mainAxisSpacing: 10.h,

                    childAspectRatio: 0.70,
                  ),

                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(12.r),

                      // Opens the selected product details.
                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailsScreen(product: product),
                          ),
                        );
                      },

                      child: Card(
                        elevation: 2,

                        clipBehavior: Clip.antiAlias,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            // -----------------------------------------
                            // PRODUCT IMAGE
                            // -----------------------------------------
                            Expanded(
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: double.infinity,

                                    height: double.infinity,

                                    child: CachedNetworkImage(
                                      imageUrl: product.thumbnail,

                                      fit: BoxFit.cover,

                                      width: double.infinity,

                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: isDarkMode
                                              ? yellowColor
                                              : primaryColor,
                                        ),
                                      ),

                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.broken_image, size: 24.sp),
                                    ),
                                  ),

                                  // -----------------------------------------
                                  // DISCOUNT BADGE
                                  // -----------------------------------------
                                  if (product.discountPercentage > 0)
                                    Positioned(
                                      top: 8.h,
                                      left: 8.w,

                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 7.w,
                                          vertical: 4.h,
                                        ),

                                        decoration: BoxDecoration(
                                          color: yellowColor,

                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),

                                        child: Text(
                                          '${product.discountPercentage.toStringAsFixed(0)}% OFF',

                                          style: TextStyle(
                                            fontFamily: 'Poppins',

                                            fontSize: 10.sp,

                                            fontWeight: FontWeight.bold,

                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // -----------------------------------------
                            // PRODUCT INFORMATION
                            // -----------------------------------------
                            Padding(
                              padding: EdgeInsets.all(8.r),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  // Product name.
                                  CustomText(
                                    text: product.title,

                                    fontSize: 14.sp,

                                    fontWeight: FontWeight.bold,

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  SizedBox(height: 4.h),

                                  // Product price.
                                  CustomText(
                                    text:
                                        '\$${product.price.toStringAsFixed(2)}',

                                    fontSize: 13.sp,

                                    fontWeight: FontWeight.w600,
                                  ),

                                  SizedBox(height: 4.h),

                                  // Product rating.
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,

                                        color: yellowColor,

                                        size: 16.sp,
                                      ),

                                      SizedBox(width: 4.w),

                                      CustomText(
                                        text: product.rating.toStringAsFixed(1),

                                        fontSize: 12.sp,

                                        fontWeight: FontWeight.w500,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
