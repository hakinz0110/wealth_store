# Technology Stack & Build System

## Core Framework
- **Flutter**: Cross-platform UI framework (SDK >=3.2.0 <4.0.0)
- **Dart**: Programming language with null safety

## Backend & Services
- **Supabase**: Backend-as-a-Service (BaaS)
  - Authentication (email/password, OAuth)
  - PostgreSQL database with Row-Level Security (RLS)
  - Storage buckets for images and assets
  - Real-time subscriptions

## State Management & Architecture
- **Riverpod**: Primary state management solution
  - `flutter_riverpod` for providers
  - `riverpod_annotation` for code generation
  - `riverpod_generator` for build-time generation
- **flutter_hooks**: UI state management and lifecycle

## Navigation & Routing
- **go_router**: Declarative routing with type safety
- **responsive_framework**: Responsive design breakpoints

## UI & Design System
- **Material Design 3**: UI components and theming
- **Inter Font Family**: Typography (Regular, Medium, SemiBold, Bold)
- **flutter_animate**: Animations and transitions
- **motion**: Advanced motion effects
- **shimmer**: Loading state animations

## Data & Serialization
- **freezed**: Immutable data classes with code generation
- **json_annotation** + **json_serializable**: JSON serialization
- **build_runner**: Code generation orchestration

## Media & Assets
- **flutter_svg**: SVG image support
- **cached_network_image**: Image caching and optimization
- **image_picker**: Camera and gallery access

## Storage & Persistence
- **flutter_secure_storage**: Secure credential storage
- **shared_preferences**: Local app preferences

## Device Features
- **speech_to_text**: Voice search functionality
- **share_plus**: Native sharing capabilities
- **permission_handler**: Runtime permissions
- **connectivity_plus**: Network connectivity monitoring
- **package_info_plus**: App version and build info

## Development Tools
- **flutter_lints**: Dart/Flutter linting rules
- **flutter_test**: Unit and widget testing framework

## Common Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build

# Watch for changes and regenerate
dart run build_runner watch

# Run app in development
flutter run

# Run with specific flavor/environment
flutter run --dart-define=IS_DEVELOPMENT=true
```

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Build & Deploy
```bash
# Build for Android
flutter build apk --release
flutter build appbundle --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release

# Build for Desktop
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

### Code Generation
```bash
# Generate all code (Riverpod, Freezed, JSON)
dart run build_runner build --delete-conflicting-outputs

# Clean generated files
dart run build_runner clean
```

## Environment Configuration
- Use `.env` files for environment-specific variables
- `SUPABASE_URL` and `SUPABASE_ANON_KEY` required
- `IS_DEVELOPMENT` flag for development features