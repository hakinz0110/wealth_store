
# Flutter eCommerce App - Staged Product Requirements Document (PRD)

This version of the PRD is organized into executable stages in order of development priority.

---

STAGE 1: Project Initialization
- Setup Flutter project with required packages (`pubspec.yaml`)
- Configure Supabase (auth, DB, storage)
- Initialize folder structure (`features`, `shared`, `widgets`, `providers`, `screens`)
- Add `.env` support for `SUPABASE_URL` and `SUPABASE_ANON_KEY`
- Setup dark/light theme toggles, fonts, and global `ThemeData`

STAGE 2: Supabase Backend Setup
- Create database schema: `users`, `products`, `categories`, `orders`, `cart_items`, `wishlist_items`
- Configure Supabase Storage buckets: `product-images`, `user-avatars`, `app-assets`
- Enable Row-Level Security (RLS) policies for `users`, `cart_items`, and `orders`
- Test Supabase API connection from Flutter

STAGE 3: Authentication Module
- Splash + Onboarding flow
- Register, Login, and Forgot Password screens
- Supabase auth integration (`signUp`, `signIn`, `resetPasswordForEmail`)
- Social login (Google at minimum)
- `authProvider` using Riverpod

STAGE 4: Main Navigation Framework
- Setup `go_router` for navigation
- Implement top head navigation bar and bottom navbar
- Integrate routing to Home, Categories, Cart, Feed, Account, Help screens
- Setup responsive framework and test on different breakpoints

STAGE 5: Product Core (Frontend + Backend Queries)
- Product Listing screen with filters and sorting
- Product Details screen with:
  - Gallery carousel
  - Price, reviews, stock
  - Add to cart, wishlist, share
- Supabase queries for `products`, `categories`, `wishlist_items`

STAGE 6: Cart & Checkout Flow
- Cart screen with quantity control and subtotal
- Checkout screen with:
  - Address input
  - Payment method selection
  - Order summary
- Payment screen stub (can integrate later)
- Supabase queries for `cart_items` and `orders`

STAGE 7: Orders Module
- Order Confirmation screen
- My Orders + Order Details screen
- Reorder, cancel, return actions
- Supabase subscriptions for real-time status updates

STAGE 8: Account & Profile Management
- Profile screen with:
  - User info
  - Avatar upload via Supabase Storage
  - Edit profile
- Address management screen
- Settings screen (theme, language, etc.)

STAGE 9: Discovery & Engagement
- Search screen with suggestions
- Favorites/Wishlist
- Feed screen (promo/news)
- Notifications screen with read/unread

STAGE 10: UI/UX Design System
- Build components: Buttons, Cards, Inputs
- Integrate design tokens (colors, typography, spacing)
- Shimmer loading, motion/animations, state feedback (e.g., empty state, error)

STAGE 11: Performance Optimization
- Image optimization via Supabase CDN
- Cached images using `cached_network_image`
- Pagination and infinite scroll
- Loading state placeholders with shimmer

STAGE 12: Testing, Analytics & Deployment
- Unit tests (auth, cart, product logic)
- Widget & integration tests
- Firebase Performance Monitoring + Analytics
- Android/iOS build config
- AppConfig class with proper environment switch
