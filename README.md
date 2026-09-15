# John Gabriel Abonita

# INF231

# CTADMOBL Advance Mobile Programming

Explored how Flutter integrates user authentication, user models, API services, profile rendering, and user-specific cart data.

## Lab Activity Instance

- Laboratory Activity 1 - The setState() is used to manage temporary or local data within a single widget, making it suitable for simple features like the counter that is stateful. In contrast, Provider is used to manage shared data that can be accessed by multiple widgets throughout the application, such as the light and dark theme. In this activity, the counter uses setState() and resets when the Home page is recreated, demonstrating ephemeral state. Meanwhile, the theme uses Provider and remains the same even after switching between pages, demonstrating app state.

- Laboratory Activity 2 - The Service retrieves data from the API and converts it into Model objects that represent each product. These model objects are then passed to the Screen, which uses them to display the product information to the user. This interaction allows the application to separate data retrieval from the user interface, making each component responsible for a specific task. As a result, the application becomes more organized, easier to understand, and simpler to maintain as it grows.

- Laboratory Activity 3 - The cart model represents the cart information retrieved from the API and provides the data needed for displaying each product. Services handle the communication with the API and retrieve the appropriate cart data, which is then passed to the cart screen for rendering. Users can select any cart item, making it possible to navigate directly to the same details_screen.dart used for viewing individual product information. This updated design pattern separates the data, service, and interface responsibilities, making the application easier to organize and maintain. Using getById at the Cart endpoint allows the application to retrieve a specific user's cart through their user ID instead of loading unrelated cart data.

- Laboratory Activity 4 - The user model stores the authenticated user’s information, while the user service retrieves and manages the saved data used by the screens. The ProfileScreen uses the User model and UserService to display details such as the user’s name, username, email, gender, and user ID. This updated design separates the data model, service logic, and user interface, making the application easier to organize and maintain. For the cart, the saved user data is retrieved through the UserService and the user’s ID is used to request the corresponding cart from the API. This allows the CartScreen to display the cart associated with the currently logged-in user instead of relying on a fixed user ID.

- Laboratory Activity 5 - The workflow starts with Sign In, where the app first checks the DummyJSON API and then Firebase Authentication if DummyJSON login fails. During Sign Up, Firebase creates the user account while the UserService saves the user's additional information such as name, age, contact number, username, and email under the user's Firebase UID. The main idea of UserService is to handle authentication and manage user data in one place, including login, signup, profile data, password changes, logout, and account deletion. The benefit of using Firebase is that it provides a more reliable authentication system and keeps each user's profile information associated with their own account, allowing the data to be restored when they log in again.
