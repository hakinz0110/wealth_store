# Firebase Setup Guide for Wealth Store App

This guide will help you set up Firebase for your Wealth Store application correctly.

## Step 1: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click on "Add project" or select an existing project
3. Follow the setup wizard to create your Firebase project

## Step 2: Configure Firebase for Android

1. In the Firebase Console, click on the Android icon (</>) to add an Android app
2. Enter the package name: `com.wealth.app.wealth_store`
3. Register the app
4. Download the `google-services.json` file
5. Place the `google-services.json` file in the `android/app/` directory of your Flutter project

## Step 3: Configure Firebase for Web

1. In the Firebase Console, click on the Web icon (</>) to add a web app
2. Register your app with a nickname (e.g., "Wealth Store Web")
3. Copy the Firebase configuration object that looks like this:

```javascript
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID"
};
```

4. Update the Firebase configuration in `lib/services/firebase_options.dart`:

```dart
static FirebaseOptions get web => const FirebaseOptions(
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_AUTH_DOMAIN",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_STORAGE_BUCKET",
  messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
  appId: "YOUR_APP_ID",
);
```

## Step 4: Enable Google Sign-In

1. In the Firebase Console, go to "Authentication"
2. Click on the "Sign-in method" tab
3. Enable "Google" as a sign-in provider
4. Configure the OAuth consent screen if prompted
5. Add your domain to the authorized domains list if you're deploying to a custom domain

## Step 5: Set Up Firestore Database

1. In the Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Start in production mode or test mode (you can adjust security rules later)
4. Choose a location for your database
5. Create the following collections:
   - `users`: To store user information
   - `products`: To store product details
   - `orders`: To store order information

## Step 6: Import Sample Products

1. In the Firebase Console, go to "Firestore Database"
2. Click on the "products" collection (create it if it doesn't exist)
3. Use the Firebase Console UI to add documents based on the `sample_products.json` file
4. Alternatively, you can use the Firebase Admin SDK or a tool like Firestore Bulk Loader to import the data

## Step 7: Set Up Firestore Security Rules

1. In the Firebase Console, go to "Firestore Database"
2. Click on the "Rules" tab
3. Copy the contents of the `firestore.rules` file from your project
4. Paste the rules into the editor
5. Click "Publish"

## Troubleshooting

If you encounter authentication errors:

1. Make sure your Firebase configuration values are correct in both `firebase_options.dart` and `web/index.html`
2. Verify that Google Sign-In is properly enabled in the Firebase Console
3. Check that your OAuth consent screen is properly configured
4. For web, ensure your domain is added to the authorized domains list
5. Check the browser console for any JavaScript errors
6. Review the Flutter console output for any error messages

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview/)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)