# Wealth Store - Flutter E-commerce App

A Flutter mobile e-commerce application connected to Firebase backend with Firestore Database and Firebase Authentication.

## Features

- **Authentication**: Google Sign-in integration
- **Product Browsing**: View products in a grid layout with filtering by categories
- **Product Search**: Search products by name
- **Shopping Cart**: Add products to cart, manage quantities, and checkout
- **Order Management**: Place orders and view order history
- **User Profile**: View and update user information

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Firebase account
- Android Studio / VS Code

### Firebase Setup

1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/)
2. Add Android app to your Firebase project
   - Package name: `com.wealth.app.wealth_store`
   - Download `google-services.json` and place it in the `android/app` directory
3. Add Web app to your Firebase project
   - The Firebase configuration is already added to `web/index.html`
   - Make sure the Firebase configuration in `lib/main.dart` matches your project
4. Enable Google Sign-in Authentication in the Firebase Console
5. Create the following Firestore collections:
   - `users`: To store user information
   - `products`: To store product details
   - `orders`: To store order information
6. Set up Firestore security rules using the provided `firestore.rules` file

### Product Collection Structure

Add sample products to your Firestore `products` collection with the following fields:
- `name`: String (Product name)
- `imageUrl`: String (URL to product image)
- `price`: Number (Product price)
- `rating`: Number (Product rating from 0-5)
- `category`: String (e.g., "Mobile", "Headphones")
- `description`: String (Product description)

You can use the provided `sample_products.json` file to import sample products into your Firestore database.

### Running the App

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Ensure Firebase configuration is properly set up
4. Run `flutter run` to start the app on a mobile device/emulator
5. Run `flutter run -d chrome` to start the app on web

### Web Deployment

To deploy the app to Firebase Hosting:

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login to Firebase: `firebase login`
3. Initialize Firebase: `firebase init`
   - Select Hosting
   - Select your Firebase project
   - Set public directory to `build/web`
   - Configure as single-page app: Yes
4. Build the web app: `flutter build web`
5. Deploy to Firebase: `firebase deploy`

## App Structure

- `lib/models/`: Data models
- `lib/providers/`: State management using Provider
- `lib/screens/`: App screens
- `lib/widgets/`: Reusable UI components
- `lib/services/`: Firebase and other services

## Dependencies

- `firebase_core`: Firebase core functionality
- `firebase_auth`: Firebase authentication
- `cloud_firestore`: Firestore database
- `google_sign_in`: Google authentication
- `provider`: State management
- `cached_network_image`: Image caching
- `flutter_rating_bar`: Rating display
- `intl`: Date formatting

## License

This project is licensed under the MIT License.
