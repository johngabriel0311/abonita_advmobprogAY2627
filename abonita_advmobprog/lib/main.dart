import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase
import 'firebase_options.dart';

// screens
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';

// providers
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await dotenv.load(fileName: 'assets/.env');

    print("ENV LOADED");
  } catch (e) {
    print("ENV ERROR: $e");
  }

  runApp(const AbonitaAdvMobProg());
}

class AbonitaAdvMobProg extends StatelessWidget {
  const AbonitaAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (build, child) {
          final themeModel = build.watch<ThemeProvider>();

          return MaterialApp(
            debugShowCheckedModeBanner: false,

            theme: themeModel.lightTheme,
            darkTheme: themeModel.darkTheme,

            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,

            title: 'E-Commerce App',

            // Shows the splash screen first.
            initialRoute: '/splash',

            routes: {
              // Splash screen
              '/splash': (context) => const SplashScreen(),

              // Main application
              '/home': (context) => const HomeScreen(),

              // Settings
              '/settings': (context) => const SettingsScreen(),

              // Sign in
              '/signin': (context) => const SigninScreen(),

              // Sign up
              '/signup': (context) => const SignupScreen(),
            },
          );
        },
      ),
    );
  }
}
