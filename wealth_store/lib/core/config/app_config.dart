class AppConfig {
  // App Information
  static const String appName = 'Wealth Store';
  static const String appVersion = '1.0.0';
  
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://zazbfusupfoxdhfgqmno.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InphemJmdXN1cGZveGRoZmdxbW5vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE3MzU3NjksImV4cCI6MjA2NzMxMTc2OX0.lQnP3HVDXcINFPavWYzgto84v2vx7jI25nfrlQBJqhA',
  );
  
  // Environment Configuration
  static const bool isDevelopment = bool.fromEnvironment(
    'IS_DEVELOPMENT',
    defaultValue: true,
  );
  
  // Table Names
  static const String usersTable = 'users';
  static const String productsTable = 'products';
  static const String categoriesTable = 'categories';
  static const String ordersTable = 'orders';
  static const String bannersTable = 'banners';
  static const String couponsTable = 'coupons';
  
  // Storage Buckets
  static const String productImagesBucket = 'product-images';
  static const String bannerImagesBucket = 'banner-images';
  static const String booksBucket = 'books';
  static const String clothingsBucket = 'clothings';
  static const String phonesBucket = 'phones';
  static const String categoryIconsBucket = 'category-icons';
  static const String customerAvatarsBucket = 'customer-avatars';
  static const String adminAvatarsBucket = 'admin-avatars';
  static const String projectImagesBucket = 'project-images';
  static const String brandLogosBucket = 'brand-logos';
  static const String userAvatarsBucket = 'user-avatars';
  static const String mediaBucket = 'media';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  
  // User Roles
  static const String adminRole = 'admin';
  static const String managerRole = 'manager';
  static const String customerRole = 'customer';
} 