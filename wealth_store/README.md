# Flutter eCommerce App

A production-ready eCommerce mobile app built with Flutter and Supabase.

## Features Implemented

### Stage 8: Account & Profile Management
- Profile screen with avatar upload via Supabase Storage
- Edit profile functionality with form validation
- Address management (add, edit, delete, set default)
- Settings screen with theme and language preferences

### Stage 9: Discovery & Engagement
- Search screen with text and voice search capabilities
- Search history management
- Wishlist screen with sharing functionality
- Feed screen for promotions and news
- Notifications screen with real-time updates

### Stage 10: UI/UX Design System
- Shimmer loading effects for better loading states
- Skeleton loaders for content placeholders
- Animated list items for smooth transitions
- Base screen components for consistent UI
- Motion effects with flutter_animate

### Stage 11: Performance Optimization
- Image optimization via Supabase CDN parameters
- Cached network images for faster loading
- Pagination and infinite scroll for product lists
- Memory-efficient image loading with size specifications

## Tech Stack

- **Flutter**: UI framework
- **Supabase**: Backend as a Service (Auth, Database, Storage)
- **Riverpod**: State management
- **go_router**: Navigation
- **flutter_hooks**: UI state management
- **flutter_animate**: Animations
- **shimmer**: Loading effects
- **motion**: Motion effects
- **responsive_framework**: Responsive design
- **cached_network_image**: Image caching
- **shared_preferences**: Local storage

## Architecture

The app follows a feature-first architecture with clean separation of concerns:

```
lib/
  ├── core/              # Core utilities and constants
  ├── features/          # Feature modules
  │   ├── auth/          # Authentication
  │   ├── cart/          # Shopping cart
  │   ├── feed/          # Promotions and news feed
  │   ├── home/          # Home screen
  │   ├── notifications/ # User notifications
  │   ├── orders/        # Order management
  │   ├── products/      # Product catalog
  │   ├── profile/       # User profile
  │   ├── search/        # Search functionality
  │   └── wishlist/      # Wishlist management
  ├── router/            # App navigation
  └── shared/            # Shared models and widgets
```

Each feature follows a layered architecture:
- **data**: Repositories and data sources
- **domain**: Business logic and state management
- **presentation**: UI components and screens

## Getting Started

1. Clone the repository
2. Run `flutter pub get`
3. Create a `.env` file with your Supabase credentials:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```
4. Run `flutter run`
