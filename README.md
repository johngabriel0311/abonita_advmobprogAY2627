# John Gabriel Abonita

# INF231

# CTADMOBL Advance Mobile Programming

Explored how Flutter handles cart data through API integration, navigation, and state management using Provider and getById.

## Laboratory Activity 3

The cart model represents the cart information retrieved from the API and provides the data needed for displaying each product. Services handle the communication with the API and retrieve the appropriate cart data, which is then passed to the cart screen for rendering. Users can select any cart item, making it possible to navigate directly to the same details_screen.dart used for viewing individual product information. This updated design pattern separates the data, service, and interface responsibilities, making the application easier to organize and maintain. Using getById at the Cart endpoint allows the application to retrieve a specific user's cart through their user ID instead of loading unrelated cart data.
