import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

// Displays the application settings.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Builds the settings screen interface.
  @override
  Widget build(BuildContext context) {
    final themeModel = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Displays the settings section title.
            const Text("App State"),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Displays the current theme mode.
                Text(
                  themeModel.isDark ? "Dark Mode" : "Light Mode",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(width: 20),

                // Switches between light and dark mode.
                Switch(
                  value: themeModel.isDark,
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
