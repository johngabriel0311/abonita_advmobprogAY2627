# John Gabriel Abonita
# INF231
# CTADMOBL Advance Mobile Programming

Discussing how the model, services and screen interact with each other to render the API endpoint and how they relate to the new design pattern of the activity. 

## Lab Activity Instance

- Laboratory Activity 1 - The setState() is used to manage temporary or local data within a single widget, making it suitable for simple features like the counter that is stateful. In contrast, Provider is used to manage shared data that can be accessed by multiple widgets throughout the application, such as the light and dark theme. In this activity, the counter uses setState() and resets when the Home page is recreated, demonstrating ephemeral state. Meanwhile, the theme uses Provider and remains the same even after switching between pages, demonstrating app state.

- Laboratory Activity 2 - The Service retrieves data from the API and converts it into Model objects that represent each product. These model objects are then passed to the Screen, which uses them to display the product information to the user. This interaction allows the application to separate data retrieval from the user interface, making each component responsible for a specific task. As a result, the application becomes more organized, easier to understand, and simpler to maintain as it grows.
