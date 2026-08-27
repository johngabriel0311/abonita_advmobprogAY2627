import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// screens
import 'product_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

// services
import '../services/user_service.dart';

// widgets
import '../widgets/custom_text.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, this.username = ''});

  // Creates the state for the home screen.
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Manages the pages and bottom navigation.
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final PageController _pageController = PageController();

  String _firstName = 'Profile';

  // Loads the saved user's first name.
  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Retrieves the saved user data.
  Future<void> _loadUser() async {
    final user = await UserService().getUser();

    if (!mounted) return;

    setState(() {
      _firstName = user.firstName;
    });
  }

  // Changes the current page.
  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });

    _pageController.jumpToPage(value);
  }

  // Opens the chat page.
  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Center(child: Text('Chat Page'))),
      ),
    );
  }

  // Builds the home screen interface.
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 2,
          backgroundColor: const Color(0xFF354591),
          foregroundColor: Colors.white,

          title: (_selectedIndex == 0)
              ? Image.asset('assets/images/nubdexchange_logo.png', scale: 11.sp)
              : CustomText(
                  text: (_selectedIndex == 1)
                      ? 'Cart'
                      : (_selectedIndex == 2)
                      ? _firstName
                      : 'Home',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),

          actions: [
            IconButton(
              icon: Icon(Icons.settings, size: 24.sp),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),

        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,

          children: const [ProductScreen(), CartScreen(), ProfileScreen()],

          onPageChanged: (page) {
            setState(() {
              _selectedIndex = page;
            });
          },
        ),

        // Enhancement 2:
        // Displays the Chat button as a FloatingActionButton.
        // The button is hidden when the Cart screen is active.
        floatingActionButton: _selectedIndex == 1
            ? null
            : FloatingActionButton(
                onPressed: _openChat,
                backgroundColor: const Color(0xFFFFC325),
                foregroundColor: const Color(0xFF354591),
                child: const Icon(Icons.chat),
              ),

        // Positions the Chat button at the bottom-right.
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,

          onTap: _onTappedBar,

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],

          currentIndex: _selectedIndex,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
