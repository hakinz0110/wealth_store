# wealth_store_admin

# Wealth Store Admin Panel

A comprehensive Flutter web application for managing the Wealth Store eCommerce system. This admin panel provides complete control over products, orders, users, and system settings.

## Features

- **Dashboard**: Analytics and key metrics with charts and graphs
- **Product Management**: CRUD operations for products with image uploads
- **Order Management**: View and update order statuses
- **User Management**: View customer information and order history
- **Category Management**: Organize products into categories
- **Discount Management**: Create and manage coupon codes
- **Media Management**: Upload and organize images
- **Settings**: Configure store settings and preferences
- **Activity Logs**: Track all administrative actions
- **Role-Based Access**: Secure admin-only access

## Tech Stack

- **Frontend**: Flutter (Web)
- **Backend**: Supabase (Database, Auth, Storage)
- **State Management**: Riverpod
- **Charts**: FL Chart
- **UI Components**: Material Design 3

## Project Structure

```
lib/
├── features/           # Feature-based modules
│   ├── auth/          # Authentication
│   ├── dashboard/     # Dashboard and analytics
│   ├── products/      # Product management
│   ├── orders/        # Order management
│   ├── users/         # User management
│   └── ...
├── models/            # Data models
├── services/          # API and business logic
├── shared/            # Shared utilities
│   ├── constants/     # App constants
│   ├── themes/        # App themes
│   ├── widgets/       # Reusable widgets
│   └── utils/         # Helper functions
└── main.dart          # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.8.0)
- Dart SDK
- Web browser for testing

### Installation

1. Clone the repository
2. Navigate to the admin directory:
   ```bash
   cd wealth_store_admin
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the application:
   ```bash
   flutter run -d chrome
   ```

### Building for Production

```bash
flutter build web
```

## Configuration

The app is configured to use the shared Supabase project:
- Project URL: `https://zazbfusupfoxdhfgqmno.supabase.co`
- Configuration is stored in `lib/shared/constants/app_constants.dart`

## Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Formatting

```bash
flutter format .
```

## Contributing

1. Follow the established project structure
2. Use feature-based organization
3. Write tests for new functionality
4. Follow Flutter/Dart style guidelines
5. Ensure all analysis checks pass

## License

This project is part of the Wealth Store eCommerce system.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
