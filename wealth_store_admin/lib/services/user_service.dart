import '../models/user_models.dart';
import '../shared/utils/logger.dart';
import '../shared/utils/error_handler.dart';
import 'supabase_service.dart';

class UserService {
  static const String _tableName = 'users';

  // Get all users from Supabase with pagination and filters
  Future<List<User>> getUsers({
    int page = 1,
    int limit = 20,
    UserFilters? filters,
  }) async {
    try {
      Logger.info('Fetching users from Supabase - Page: $page, Limit: $limit');
      
      var query = SupabaseService.client
          .from(_tableName)
          .select('*');

      // Apply filters
      if (filters != null) {
        if (filters.searchQuery != null && filters.searchQuery!.isNotEmpty) {
          query = query.or('email.ilike.%${filters.searchQuery}%,full_name.ilike.%${filters.searchQuery}%');
        }
        
        if (filters.role != null) {
          query = query.eq('role', filters.role!);
        }
        
        if (filters.isActive != null) {
          query = query.eq('is_active', filters.isActive!);
        }
        
        if (filters.isVerified != null) {
          query = query.eq('email_verified', filters.isVerified!);
        }
      }

      // Exclude admin users from regular user list
      query = query.neq('role', 'admin');

      // Apply sorting
      if (filters?.sortBy != null) {
        String orderColumn;
        switch (filters!.sortBy!) {
          case UserSortBy.email:
            orderColumn = 'email';
            break;
          case UserSortBy.name:
            orderColumn = 'full_name';
            break;
          case UserSortBy.role:
            orderColumn = 'role';
            break;
          case UserSortBy.createdAt:
          default:
            orderColumn = 'created_at';
            break;
        }
        
        query = query.order(orderColumn, ascending: filters.sortOrder == SortOrder.ascending);
      } else {
        query = query.order('created_at', ascending: false);
      }

      // Apply pagination
      final offset = (page - 1) * limit;
      query = query.range(offset, offset + limit - 1);

      final response = await query;
      return response.map<User>((json) => User.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get users', e, stackTrace);
      rethrow;
    }
  }

  // Get user by ID from Supabase
  Future<User?> getUserById(String id) async {
    try {
      Logger.info('Fetching user by ID: $id');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('id', id)
          .single();

      return User.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get user by ID', e, stackTrace);
      return null;
    }
  }

  // Get user by email from Supabase
  Future<User?> getUserByEmail(String email) async {
    try {
      Logger.info('Fetching user by email: $email');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('email', email)
          .single();

      return User.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get user by email', e, stackTrace);
      return null;
    }
  }

  // Update user status (active/inactive/banned)
  Future<User> updateUserStatus(String id, UserStatus status, {String? reason}) async {
    try {
      Logger.info('Updating user status: $id to ${status.value}');

      final updateData = {
        'status': status.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (reason != null) {
        updateData['status_reason'] = reason;
      }

      final response = await SupabaseService.client
          .from(_tableName)
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      Logger.info('User status updated successfully: $id');
      return User.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update user status', e, stackTrace);
      rethrow;
    }
  }

  // Update user role
  Future<User> updateUserRole(String id, String role) async {
    try {
      Logger.info('Updating user role: $id to $role');

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'role': role,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('User role updated successfully: $id');
      return User.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Update user role', e, stackTrace);
      rethrow;
    }
  }

  // Get user order history
  Future<List<UserOrder>> getUserOrderHistory(String userId) async {
    try {
      Logger.info('Fetching order history for user: $userId');
      
      final response = await SupabaseService.client
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<UserOrder>((json) => UserOrder.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get user order history', e, stackTrace);
      rethrow;
    }
  }

  // Get user statistics
  Future<UserStats> getUserStats(String userId) async {
    try {
      Logger.info('Fetching user statistics: $userId');
      
      // Get order statistics
      final ordersResponse = await SupabaseService.client
          .from('orders')
          .select('total, status')
          .eq('user_id', userId);

      final totalOrders = ordersResponse.length;
      final totalSpent = ordersResponse.fold<double>(
        0.0, 
        (sum, order) => sum + (order['total'] as num).toDouble()
      );

      final completedOrders = ordersResponse
          .where((order) => order['status'] == 'completed')
          .length;

      // Get user registration date
      final user = await getUserById(userId);
      final memberSince = user?.createdAt ?? DateTime.now();

      return UserStats(
        totalOrders: totalOrders,
        totalSpent: totalSpent,
        completedOrders: completedOrders,
        averageOrderValue: totalOrders > 0 ? totalSpent / totalOrders : 0.0,
        memberSince: memberSince,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get user statistics', e, stackTrace);
      rethrow;
    }
  }

  // Search users
  Future<List<User>> searchUsers(String query) async {
    try {
      Logger.info('Searching users: $query');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .or('email.ilike.%$query%,full_name.ilike.%$query%')
          .neq('role', 'admin')
          .order('created_at', ascending: false)
          .limit(50);

      return response.map<User>((json) => User.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Search users', e, stackTrace);
      rethrow;
    }
  }

  // Get user activity summary
  Future<Map<String, dynamic>> getUserActivitySummary() async {
    try {
      Logger.info('Fetching user activity summary');
      
      // Get total users count
      final totalUsersResponse = await SupabaseService.client
          .from(_tableName)
          .select('id', count: CountOption.exact)
          .neq('role', 'admin');

      // Get active users count
      final activeUsersResponse = await SupabaseService.client
          .from(_tableName)
          .select('id', count: CountOption.exact)
          .eq('is_active', true)
          .neq('role', 'admin');

      // Get new users this month
      final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final newUsersResponse = await SupabaseService.client
          .from(_tableName)
          .select('id', count: CountOption.exact)
          .gte('created_at', startOfMonth.toIso8601String())
          .neq('role', 'admin');

      // Get verified users count
      final verifiedUsersResponse = await SupabaseService.client
          .from(_tableName)
          .select('id', count: CountOption.exact)
          .eq('email_verified', true)
          .neq('role', 'admin');

      return {
        'total_users': totalUsersResponse.count,
        'active_users': activeUsersResponse.count,
        'new_users_this_month': newUsersResponse.count,
        'verified_users': verifiedUsersResponse.count,
        'verification_rate': totalUsersResponse.count > 0 
            ? (verifiedUsersResponse.count / totalUsersResponse.count * 100).round()
            : 0,
      };
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get user activity summary', e, stackTrace);
      rethrow;
    }
  }

  // Mark user as suspicious
  Future<User> markUserAsSuspicious(String id, String reason) async {
    try {
      Logger.info('Marking user as suspicious: $id');

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'is_suspicious': true,
            'suspicious_reason': reason,
            'suspicious_marked_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('User marked as suspicious successfully: $id');
      return User.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Mark user as suspicious', e, stackTrace);
      rethrow;
    }
  }

  // Clear suspicious flag
  Future<User> clearSuspiciousFlag(String id) async {
    try {
      Logger.info('Clearing suspicious flag for user: $id');

      final response = await SupabaseService.client
          .from(_tableName)
          .update({
            'is_suspicious': false,
            'suspicious_reason': null,
            'suspicious_marked_at': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      Logger.info('Suspicious flag cleared successfully: $id');
      return User.fromJson(response);
    } catch (e, stackTrace) {
      ErrorHandler.logError('Clear suspicious flag', e, stackTrace);
      rethrow;
    }
  }

  // Get recent users
  Future<List<User>> getRecentUsers({int limit = 10}) async {
    try {
      Logger.info('Fetching recent users');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .neq('role', 'admin')
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map<User>((json) => User.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get recent users', e, stackTrace);
      rethrow;
    }
  }

  // Get suspicious users
  Future<List<User>> getSuspiciousUsers() async {
    try {
      Logger.info('Fetching suspicious users');
      
      final response = await SupabaseService.client
          .from(_tableName)
          .select('*')
          .eq('is_suspicious', true)
          .neq('role', 'admin')
          .order('suspicious_marked_at', ascending: false);

      return response.map<User>((json) => User.fromJson(json)).toList();
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get suspicious users', e, stackTrace);
      rethrow;
    }
  }

  // Get user statistics
  Future<UserStatistics> getUserStatistics({DateTime? startDate, DateTime? endDate}) async {
    try {
      Logger.info('Fetching user statistics');
      
      var query = SupabaseService.client
          .from(_tableName)
          .select('*')
          .neq('role', 'admin');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final users = await query;
      
      final totalUsers = users.length;
      final activeUsers = users.where((u) => u['status'] == 'active').length;
      final suspiciousUsers = users.where((u) => u['is_suspicious'] == true).length;
      
      // Calculate new users this month
      final startOfMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
      final newUsersThisMonth = users.where((u) {
        final createdAt = DateTime.parse(u['created_at']);
        return createdAt.isAfter(startOfMonth);
      }).length;

      // Group by role
      final usersByRole = <String, int>{};
      for (final user in users) {
        final role = user['role'] as String;
        usersByRole[role] = (usersByRole[role] ?? 0) + 1;
      }

      // Group by status
      final usersByStatus = <String, int>{};
      for (final user in users) {
        final status = user['status'] as String? ?? 'active';
        usersByStatus[status] = (usersByStatus[status] ?? 0) + 1;
      }

      return UserStatistics(
        totalUsers: totalUsers,
        activeUsers: activeUsers,
        newUsersThisMonth: newUsersThisMonth,
        suspiciousUsers: suspiciousUsers,
        usersByRole: usersByRole,
        usersByStatus: usersByStatus,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('Get user statistics', e, stackTrace);
      rethrow;
    }
  }

  // Delete user (soft delete by deactivating)
  Future<void> deleteUser(String id) async {
    try {
      Logger.info('Soft deleting user: $id');

      await SupabaseService.client
          .from(_tableName)
          .update({
            'status': 'deleted',
            'deleted_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      Logger.info('User soft deleted successfully: $id');
    } catch (e, stackTrace) {
      ErrorHandler.logError('Delete user', e, stackTrace);
      rethrow;
    }
  }
}