class ApiEndpoints {
  // Base URLs
  static const String supabaseUrl = 'https://zazbfusupfoxdhfgqmno.supabase.co';
  static const String restApiUrl = '$supabaseUrl/rest/v1';
  static const String authUrl = '$supabaseUrl/auth/v1';
  static const String storageUrl = '$supabaseUrl/storage/v1';
  
  // Authentication endpoints
  static const String signIn = '$authUrl/token?grant_type=password';
  static const String signOut = '$authUrl/logout';
  static const String refreshToken = '$authUrl/token?grant_type=refresh_token';
  static const String user = '$authUrl/user';
  
  // Database table endpoints
  static const String users = '$restApiUrl/users';
  static const String products = '$restApiUrl/products';
  static const String categories = '$restApiUrl/categories';
  static const String orders = '$restApiUrl/orders';
  static const String banners = '$restApiUrl/banners';
  static const String discounts = '$restApiUrl/discounts';
  static const String activityLogs = '$restApiUrl/activity_logs';
  
  // Storage endpoints
  static const String productImagesStorage = '$storageUrl/object/product-images';
  static const String bannerImagesStorage = '$storageUrl/object/banner-images';
  
  // RPC (Remote Procedure Call) endpoints for custom functions
  static const String rpcBase = '$restApiUrl/rpc';
  static const String getDashboardMetrics = '$rpcBase/get_dashboard_metrics';
  static const String getOrderStatistics = '$rpcBase/get_order_statistics';
  static const String getTopProducts = '$rpcBase/get_top_products';
}