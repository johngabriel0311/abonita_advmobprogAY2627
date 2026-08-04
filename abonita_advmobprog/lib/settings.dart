import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main.dart';

// Displays the Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Builds the Settings Page Interface
  @override
  Widget build(BuildContext context) {
    final themeModel = Provider.of<ThemeModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("App State"),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  themeModel.isDark ? "Dark Mode" : "Light Mode",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(width: 20),

                Switch(
                  value: themeModel.isDark,

                  // Changes the application's theme.
                  onChanged: (_) {
                    themeModel.toggleTheme();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
