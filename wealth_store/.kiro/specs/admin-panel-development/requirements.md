# Requirements Document

## Introduction

This document outlines the requirements for developing a comprehensive admin panel (`wealth_store_admin`) for the Flutter eCommerce system. The admin panel will be a separate Flutter application that shares the same Supabase backend with the customer app (`wealth_store`). The admin panel will provide complete administrative control over products, orders, users, content, and system settings while maintaining proper security through role-based access control.

## Requirements

### Requirement 1: Admin Authentication System

**User Story:** As an admin user, I want to securely log into the admin panel using my credentials, so that I can access administrative functions while ensuring unauthorized users cannot access the system.

#### Acceptance Criteria

1. WHEN an admin enters valid email and password THEN the system SHALL authenticate using Supabase Auth and verify the user has 'admin' role
2. WHEN a user without 'admin' role attempts to login THEN the system SHALL deny access and display appropriate error message
3. WHEN authentication is successful THEN the system SHALL redirect to the dashboard and maintain session state
4. WHEN an admin logs out THEN the system SHALL clear all session data and redirect to login screen
5. IF a user is not authenticated THEN the system SHALL redirect all protected routes to the login screen

### Requirement 2: Product Management System

**User Story:** As an admin, I want to manage all products in the system including adding, editing, and deleting products with images, so that I can maintain an up-to-date product catalog for customers.

#### Acceptance Criteria

1. WHEN an admin views the products page THEN the system SHALL display all products in a paginated data table with search and filter capabilities
2. WHEN an admin adds a new product THEN the system SHALL allow input of name, price, stock, category, and image upload to Supabase Storage
3. WHEN an admin edits a product THEN the system SHALL pre-populate the form with existing data and allow modifications
4. WHEN an admin deletes a product THEN the system SHALL show confirmation dialog and remove the product from database and associated images from storage
5. WHEN product stock is below a threshold THEN the system SHALL display low-stock warnings in the product list
6. WHEN an admin uploads a product image THEN the system SHALL validate file type, compress if needed, and store in Supabase Storage

### Requirement 3: Category Management System

**User Story:** As an admin, I want to create and manage product categories, so that products can be properly organized and customers can easily browse by category.

#### Acceptance Criteria

1. WHEN an admin views categories THEN the system SHALL display all categories with product count for each
2. WHEN an admin creates a category THEN the system SHALL validate the name is unique and save to database
3. WHEN an admin edits a category THEN the system SHALL update the category name and reflect changes in associated products
4. WHEN an admin deletes a category THEN the system SHALL check for associated products and either prevent deletion or reassign products
5. WHEN creating or editing products THEN the system SHALL provide a dropdown of available categories for selection

### Requirement 4: Order Management System

**User Story:** As an admin, I want to view and manage all customer orders including updating order status, so that I can fulfill orders efficiently and keep customers informed.

#### Acceptance Criteria

1. WHEN an admin views orders THEN the system SHALL display all orders with customer info, items, total, and current status
2. WHEN an admin updates order status THEN the system SHALL save the new status and optionally notify the customer
3. WHEN an admin views order details THEN the system SHALL show complete order information including customer details and ordered items
4. WHEN an admin filters orders THEN the system SHALL allow filtering by status, date range, and customer
5. IF order status changes THEN the system SHALL log the change in activity logs with timestamp and admin info

### Requirement 5: User Management System

**User Story:** As an admin, I want to view all registered users and their basic information, so that I can understand the customer base and provide support when needed.

#### Acceptance Criteria

1. WHEN an admin views users THEN the system SHALL display all users with email, registration date, and order count
2. WHEN an admin views user details THEN the system SHALL show user profile and order history
3. WHEN an admin searches users THEN the system SHALL filter by email or registration date
4. WHEN displaying user data THEN the system SHALL respect privacy by not showing sensitive information like passwords
5. IF a user has suspicious activity THEN the system SHALL highlight the user for admin review

### Requirement 6: Dashboard and Analytics

**User Story:** As an admin, I want to see key business metrics and analytics on a dashboard, so that I can make informed decisions about the business.

#### Acceptance Criteria

1. WHEN an admin accesses the dashboard THEN the system SHALL display metric cards showing Sales Total, Average Order Value, Total Orders, and Visitors with percentage changes
2. WHEN viewing analytics THEN the system SHALL show a Weekly Sales bar chart and Orders Status donut chart with color-coded segments
3. WHEN dashboard loads THEN the system SHALL display a Recent Orders table with order details, status, and amounts
4. WHEN viewing metrics THEN the system SHALL use the clean card-based layout with blue accent colors matching the reference design
5. IF data is loading THEN the system SHALL show appropriate loading indicators while maintaining the visual layout

### Requirement 7: Discount and Coupon Management

**User Story:** As an admin, I want to create and manage discount coupons, so that I can run promotional campaigns and track their effectiveness.

#### Acceptance Criteria

1. WHEN an admin creates a coupon THEN the system SHALL allow setting code, discount type (percentage/fixed), value, and expiry date
2. WHEN an admin views coupons THEN the system SHALL display all coupons with usage statistics and status
3. WHEN a coupon expires THEN the system SHALL automatically mark it as inactive
4. WHEN an admin edits a coupon THEN the system SHALL validate the changes and update the database
5. IF a coupon reaches usage limit THEN the system SHALL automatically deactivate it

### Requirement 8: Content Management System

**User Story:** As an admin, I want to manage banners and promotional content for the customer app, so that I can control the visual presentation and marketing messages.

#### Acceptance Criteria

1. WHEN an admin uploads banners THEN the system SHALL store images in Supabase Storage and save metadata to database
2. WHEN an admin manages banners THEN the system SHALL allow setting priority order for display sequence
3. WHEN an admin deletes a banner THEN the system SHALL remove both database record and storage file
4. WHEN banners are displayed THEN the system SHALL respect the priority order set by admin
5. IF banner upload fails THEN the system SHALL show clear error message and allow retry

### Requirement 9: Settings and Configuration

**User Story:** As an admin, I want to configure store settings like currency, shipping fees, and contact information, so that the customer app reflects the correct business information.

#### Acceptance Criteria

1. WHEN an admin accesses settings THEN the system SHALL display current store configuration
2. WHEN an admin updates settings THEN the system SHALL validate inputs and save changes to database
3. WHEN settings are changed THEN the system SHALL immediately reflect changes in the customer app
4. WHEN configuring shipping THEN the system SHALL allow setting default fees and tax rates
5. IF settings are invalid THEN the system SHALL prevent saving and show validation errors

### Requirement 10: Activity Logging and Audit Trail

**User Story:** As an admin, I want to track all administrative actions in the system, so that there is an audit trail for security and accountability purposes.

#### Acceptance Criteria

1. WHEN an admin performs any action THEN the system SHALL log the action with timestamp, admin ID, and details
2. WHEN viewing activity logs THEN the system SHALL display chronological list of all admin actions
3. WHEN filtering logs THEN the system SHALL allow filtering by admin, action type, and date range
4. WHEN critical actions occur THEN the system SHALL ensure logs cannot be modified or deleted by regular admins
5. IF suspicious activity is detected THEN the system SHALL highlight it in the activity log

### Requirement 11: Data Import and Export

**User Story:** As an admin, I want to import products via CSV and export various data sets, so that I can efficiently manage large amounts of data and create backups.

#### Acceptance Criteria

1. WHEN an admin uploads a CSV file THEN the system SHALL validate format and import products with proper error handling
2. WHEN importing products THEN the system SHALL show progress and report any failed imports with reasons
3. WHEN an admin exports data THEN the system SHALL generate CSV files for products, orders, and users
4. WHEN export is requested THEN the system SHALL allow selecting date ranges and specific data fields
5. IF import fails THEN the system SHALL provide detailed error report and allow correction

### Requirement 12: Role-Based Access Control

**User Story:** As a system administrator, I want to ensure only authorized admin users can access the admin panel, so that sensitive business data and operations are protected.

#### Acceptance Criteria

1. WHEN a user attempts to access admin features THEN the system SHALL verify the user has 'admin' role in the database
2. WHEN database queries are made THEN Supabase RLS policies SHALL enforce admin-only access to sensitive data
3. WHEN an admin session expires THEN the system SHALL automatically log out and require re-authentication
4. WHEN unauthorized access is attempted THEN the system SHALL log the attempt and deny access
5. IF user role changes THEN the system SHALL immediately update access permissions