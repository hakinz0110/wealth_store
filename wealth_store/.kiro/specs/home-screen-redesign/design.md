# Home Screen Redesign Design Document

## Overview

This design document outlines the comprehensive redesign of the home screen to match a modern eCommerce layout that emphasizes product discovery through visual categories, prominent search functionality, and featured promotional content. The design maintains the existing color scheme while implementing a new structured layout that improves user engagement and product discoverability.

## Architecture

### Layout Structure
The new home screen follows a vertical scrolling layout with distinct sections:
1. **Header Section**: Personalized greeting and notifications
2. **Search Section**: Prominent search bar for product discovery
3. **Categories Section**: Horizontal scrolling category icons
4. **Featured Banner**: Large promotional content area
5. **Popular Products**: Grid-based product showcase

### Design Principles
- **Hierarchy**: Clear visual hierarchy with proper spacing and typography
- **Discoverability**: Easy access to categories and search functionality
- **Engagement**: Featured content and promotional banners
- **Consistency**: Maintains existing color scheme and design tokens
- **Performance**: Optimized loading and smooth animations

## Components and Interfaces

### 1. Header Section

#### Personalized Greeting Header
**Purpose**: Welcome users and provide quick access to notifications

**Design Specifications**:
- **Layout**: Horizontal row with greeting text and notification icon
- **Greeting Text**: 
  - Primary text: "Good day for shopping" (subtitle style)
  - User name: Large, bold typography using existing heading styles
  - Color: Uses current primary text color from theme
- **Notification Icon**:
  - Position: Top-right corner of header
  - Icon: Bell or notification icon with badge support
  - Badge: Red circular badge with white text for unread count
  - Touch target: Minimum 44dp for accessibility
- **Spacing**: 
  - Vertical padding: 16dp top, 8dp bottom
  - Horizontal padding: 16dp left/right
- **Background**: Transparent, uses app background color

### 2. Search Section

#### Prominent Search Bar
**Purpose**: Primary entry point for product search

**Design Specifications**:
- **Container**:
  - Width: Full width minus 32dp horizontal margins
  - Height: 48dp
  - Border radius: 24dp (fully rounded)
  - Background: Surface color with slight elevation
  - Border: 1dp border using outline color
- **Content Layout**:
  - Leading icon: Search icon (24dp) with 12dp left padding
  - Placeholder text: "Search in Store" using body text style
  - Text color: On-surface variant for placeholder
- **Interactive States**:
  - Default: Outlined appearance
  - Focused: Elevated shadow and primary color accent
  - Typing: Real-time suggestions overlay
- **Spacing**: 16dp vertical margin from header and categories

### 3. Categories Section

#### Popular Categories Display
**Purpose**: Visual category navigation for product discovery

**Design Specifications**:
- **Section Header**:
  - Title: "Popular Categories" using heading H4 style
  - Margin: 24dp top, 16dp bottom
  - Color: Primary text color
- **Category Grid**:
  - Layout: Horizontal scrolling row
  - Item spacing: 16dp between items
  - Padding: 16dp horizontal margins
- **Category Item Design**:
  - Container: 64dp x 64dp circular background
  - Background: Surface color with elevation
  - Icon: 32dp category-specific icons
  - Label: Category name below icon, caption text style
  - Touch target: Expanded to 80dp x 80dp for accessibility
- **Categories to Include**:
  - Sports (sports icon)
  - Furniture (chair icon)
  - Electronics (phone icon)
  - Clothes (shirt icon)
  - Animals (pet icon)
  - Shoes (shoe icon)

### 4. Featured Banner Section

#### Promotional Content Banner
**Purpose**: Highlight featured products and promotions

**Design Specifications**:
- **Container**:
  - Width: Full width minus 32dp horizontal margins
  - Height: 200dp
  - Border radius: 16dp
  - Background: Gradient or solid color based on content
- **Content Layout**:
  - Image area: Right side, 40% of width
  - Text area: Left side, 60% of width
  - Padding: 20dp internal padding
- **Text Content**:
  - Brand/Category: Small caption text
  - Main title: Large, bold heading (e.g., "SNEAKERS OF THE WEEK")
  - Color: High contrast text over background
- **Image Treatment**:
  - Product image with transparent background
  - Positioned to overlap slightly with text area
  - Aspect ratio maintained with proper scaling
- **Page Indicators**:
  - Position: Bottom center, 12dp from bottom
  - Style: Dots with active/inactive states
  - Active: Primary color, 8dp diameter
  - Inactive: Surface variant, 6dp diameter
- **Spacing**: 24dp vertical margin from categories and products

### 5. Popular Products Section

#### Product Grid Display
**Purpose**: Showcase popular products with pricing and wishlist functionality

**Design Specifications**:
- **Section Header**:
  - Layout: Horizontal row with title and "View all" link
  - Title: "Popular Products" using heading H4 style
  - View all: Tertiary button style with arrow icon
  - Margin: 24dp top, 16dp bottom
- **Product Grid**:
  - Layout: 2-column grid on mobile, responsive on larger screens
  - Spacing: 16dp between items
  - Aspect ratio: 4:5 for product cards
- **Product Card Design**:
  - Container: Rounded corners (12dp), subtle elevation
  - Image area: Top 60% of card height
  - Content area: Bottom 40% with padding
  - Discount badge: Top-left overlay, yellow background
  - Wishlist icon: Top-right overlay, heart icon
- **Card Content**:
  - Product image: Centered with proper scaling
  - Product name: Body text, 2 lines maximum
  - Price: Bold text using primary color
  - Discount: Strike-through original price if applicable
- **Interactive Elements**:
  - Tap: Navigate to product detail
  - Heart icon: Toggle wishlist status
  - Hover effects: Subtle scale and shadow changes

## Data Models

### Home Screen State
```dart
class HomeScreenState {
  final bool isLoading;
  final String? error;
  final List<Category> categories;
  final List<Banner> featuredBanners;
  final List<Product> popularProducts;
  final int unreadNotifications;
  final String userName;
}
```

### Category Model
```dart
class Category {
  final String id;
  final String name;
  final String iconName;
  final String route;
}
```

### Featured Banner Model
```dart
class FeaturedBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String targetRoute;
  final Color backgroundColor;
}
```

## Error Handling

### Loading States
- **Categories**: Skeleton loaders with circular placeholders
- **Banners**: Rectangular skeleton with shimmer effect
- **Products**: Grid skeleton matching final layout
- **Search**: Disabled state with loading indicator

### Error States
- **Network Errors**: Retry button with friendly message
- **Empty Categories**: Show default categories with offline icons
- **No Products**: Engaging empty state with browse suggestions
- **Banner Failures**: Hide banner section gracefully

### Fallback Behavior
- **Missing User Name**: Use "User" as default
- **No Notifications**: Hide notification badge
- **Category Icons**: Use default icon if specific icon unavailable
- **Product Images**: Show placeholder image with product name

## Testing Strategy

### Visual Testing
- **Layout Consistency**: Verify spacing and alignment across screen sizes
- **Color Compliance**: Ensure existing color scheme is maintained
- **Typography**: Validate text styles match design specifications
- **Interactive States**: Test hover, focus, and pressed states

### Functional Testing
- **Navigation**: Verify all tap targets navigate correctly
- **Search**: Test search functionality and suggestions
- **Wishlist**: Validate heart icon toggle behavior
- **Responsive**: Test layout adaptation across devices

### Performance Testing
- **Loading Speed**: Measure time to first meaningful paint
- **Scroll Performance**: Ensure 60fps during scrolling
- **Image Loading**: Test progressive image loading
- **Animation Smoothness**: Validate staggered animations

## Implementation Considerations

### Responsive Breakpoints
- **Mobile (< 600dp)**: 2-column product grid, single-row categories
- **Tablet (600-1200dp)**: 3-column product grid, expanded categories
- **Desktop (> 1200dp)**: 4-column product grid, full category display

### Animation Specifications
- **Staggered Loading**: 100ms delay between elements
- **Fade Transitions**: 300ms duration with ease-out curve
- **Scale Effects**: 150ms duration for interactive feedback
- **Scroll Animations**: Parallax effects for banner section

### Accessibility Considerations
- **Semantic Labels**: Proper labels for all interactive elements
- **Focus Management**: Logical tab order throughout screen
- **Color Contrast**: Maintain WCAG AA compliance
- **Touch Targets**: Minimum 44dp for all interactive elements
- **Screen Reader**: Proper announcements for dynamic content