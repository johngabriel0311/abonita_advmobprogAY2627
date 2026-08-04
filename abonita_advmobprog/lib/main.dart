import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => ThemeModel(), child: const MyApp()),
  );
}

/// App State
/// Stores the application's theme.
class ThemeModel with ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeModel.isDark ? ThemeData.dark() : ThemeData.light(),
      home: const NavigationPage(),
    );
  }
}

/// Controls the Bottom Navigation Bar
class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  void _changePage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildPage() {
    if (_selectedIndex == 0) {
      // NEW HomePage every time
      return MyHomePage(key: UniqueKey());
    }

    return const SettingsPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _changePage,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

/// Ephemeral State
/// Counter only exists while this widget exists.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Text("Ephemeral State"),

            const SizedBox(height: 20),

            const Text("You have pushed the button this many times:"),

            Text(
              "$_counter",
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}
