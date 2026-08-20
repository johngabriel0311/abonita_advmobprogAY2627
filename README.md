# John Gabriel Abonita
# INF231
# CTADMOBL Advance Mobile Programming

Learned the differences between ephemeral (local) state and app state in Flutter, and how to manage them effectively in a Flutter application.

## Laboratory Activity 1

The setState() is used to manage temporary or local data within a single widget, making it suitable for simple features like the counter that is stateful. In contrast, Provider is used to manage shared data that can be accessed by multiple widgets throughout the application, such as the light and dark theme. In this activity, the counter uses setState() and resets when the Home page is recreated, demonstrating ephemeral state. Meanwhile, the theme uses Provider and remains the same even after switching between pages, demonstrating app state.
