# John Gabriel Abonita

# INF231

# CTADMOBL Advance Mobile Programming

Explored how Flutter integrates user authentication, user models, API services, profile rendering, and user-specific cart data.

## Laboratory Activity 4

The user model stores the authenticated user’s information, while the user service retrieves and manages the saved data used by the screens. The ProfileScreen uses the User model and UserService to display details such as the user’s name, username, email, gender, and user ID. This updated design separates the data model, service logic, and user interface, making the application easier to organize and maintain. For the cart, the saved user data is retrieved through the UserService and the user’s ID is used to request the corresponding cart from the API. This allows the CartScreen to display the cart associated with the currently logged-in user instead of relying on a fixed user ID.
