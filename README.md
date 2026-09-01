# John Gabriel Abonita

# INF231

# CTADMOBL Advance Mobile Programming

Explored how Flutter handles cart data through API integration, navigation, and state management using Provider and getById.

## Lab Activity Instance

- Laboratory Activity 1 - The setState() is used to manage temporary or local data within a single widget, making it suitable for simple features like the counter that is stateful. In contrast, Provider is used to manage shared data that can be accessed by multiple widgets throughout the application, such as the light and dark theme. In this activity, the counter uses setState() and resets when the Home page is recreated, demonstrating ephemeral state. Meanwhile, the theme uses Provider and remains the same even after switching between pages, demonstrating app state.

- Laboratory Activity 2 - The Service retrieves data from the API and converts it into Model objects that represent each product. These model objects are then passed to the Screen, which uses them to display the product information to the user. This interaction allows the application to separate data retrieval from the user interface, making each component responsible for a specific task. As a result, the application becomes more organized, easier to understand, and simpler to maintain as it grows.

- Laboratory Activity 3 - The cart model represents the cart information retrieved from the API and provides the data needed for displaying each product. Services handle the communication with the API and retrieve the appropriate cart data, which is then passed to the cart screen for rendering. Users can select any cart item, making it possible to navigate directly to the same details_screen.dart used for viewing individual product information. This updated design pattern separates the data, service, and interface responsibilities, making the application easier to organize and maintain. Using getById at the Cart endpoint allows the application to retrieve a specific user's cart through their user ID instead of loading unrelated cart data.
