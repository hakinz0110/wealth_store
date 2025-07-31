import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_models.dart' as models;
import '../../../services/user_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/supabase_service.dart';
import '../../../shared/utils/logger.dart';
import '../../../shared/constants/app_constants.dart';

/// Controller for user management operations
class UserManagementController {
  final UserService _userService;
  final Ref _ref;
  final SupabaseClient _client = SupabaseService.client;

  UserManagementController(this._userService, this._ref);

  /// Get users with pagination and filters
  Future<List<models.User>> getUsers({
    int page = 1,
    int limit = 20,
    models.UserFilters? filters,
  }) async {
    try {
      Logger.info('Fetching users - Page: $page, Limit: $limit');
      return await _userService.getUsers(
        page: page,
        limit: limit,
        filters: filters,
      );
    } catch (e) {
      Logger.error('Failed to get users', e);
      rethrow;
    }
  }

  /// Search users by query
  Future<List<models.User>> searchUsers(String query) async {
    try {
      Logger.info('Searching users with query: $query');
      return await _userService.searchUsers(query);
    } catch (e) {
      Logger.error('Failed to search users', e);
      rethrow;
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    try {
      Logger.info('Fetching user by ID: $id');
      return await _userService.getUserById(id);
    } catch (e) {
      Logger.error('Failed to get user by ID', e);
      rethrow;
    }
  }

  /// Update user role
  Future<models.User> updateUserRole(String userId, String role) async {
    try {
      // Verify current user is admin before allowing role change
      final isAdmin = await AuthService.isAdminUser();
      if (!isAdmin) {
        Logger.warning('Non-admin user attempted to update user role');
        throw Exception('Only admins can update user roles');
      }

      Logger.info('Updating user role: $userId to $role');
      
      // Log the activity
      await _logAdminActivity('update_user_role', {
        'user_id': userId,
        'new_role': role,
      });
      
      return await _userService.updateUserRole(userId, role);
    } catch (e) {
      Logger.error('Failed to update user role', e);
      rethrow;
    }
  }

  /// Update user status (activate/deactivate)
  Future<models.User> updateUserStatus(String userId, models.UserStatus status, {String? reason}) async {
    try {
      // Verify current user is admin before allowing status change
      final isAdmin = await AuthService.isAdminUser();
      if (!isAdmin) {
        Logger.warning('Non-admin user attempted to update user status');
        throw Exception('Only admins can update user status');
      }

      Logger.info('Updating user status: $userId to ${status.name}');
      
      // Log the activity
      await _logAdminActivity('update_user_status', {
        'user_id': userId,
        'new_status': status.name,
        'reason': reason,
      });
      
      return await _userService.updateUserStatus(userId, status, reason: reason);
    } catch (e) {
      Logger.error('Failed to update user status', e);
      rethrow;
    }
  }

  /// Mark user as suspicious
  Future<models.User> markUserAsSuspicious(String userId, String reason) async {
    try {
      // Verify current user is admin
      final isAdmin = await AuthService.isAdminUser();
      if (!isAdmin) {
        Logger.warning('Non-admin user attempted to mark user as suspicious');
        throw Exception('Only admins can mark users as suspicious');
      }

      Logger.info('Marking user as suspicious: $userId');
      
      // Log the activity
      await _logAdminActivity('mark_user_suspicious', {
        'user_id': userId,
        'reason': reason,
      });
      
      return await _userService.markUserAsSuspicious(userId, reason);
    } catch (e) {
      Logger.error('Failed to mark user as suspicious', e);
      rethrow;
    }
  }

  /// Clear suspicious flag
  Future<models.User> clearSuspiciousFlag(String userId) async {
    try {
      // Verify current user is admin
      final isAdmin = await AuthService.isAdminUser();
      if (!isAdmin) {
        Logger.warning('Non-admin user attempted to clear suspicious flag');
        throw Exception('Only admins can clear suspicious flags');
      }

      Logger.info('Clearing suspicious flag for user: $userId');
      
      // Log the activity
      await _logAdminActivity('clear_suspicious_flag', {
        'user_id': userId,
      });
      
      return await _userService.clearSuspiciousFlag(userId);
    } catch (e) {
      Logger.error('Failed to clear suspicious flag', e);
      rethrow;
    }
  }

  /// Get user order history
  Future<List<models.UserOrder>> getUserOrderHistory(String userId) async {
    try {
      Logger.info('Fetching order history for user: $userId');
      return await _userService.getUserOrderHistory(userId);
    } catch (e) {
      Logger.error('Failed to get user order history', e);
      rethrow;
    }
  }

  /// Get user statistics
  Future<models.UserStats> getUserStats(String userId) async {
    try {
      Logger.info('Fetching statistics for user: $userId');
      return await _userService.getUserStats(userId);
    } catch (e) {
      Logger.error('Failed to get user statistics', e);
      rethrow;
    }
  }

  /// Get user activity summary
  Future<Map<String, dynamic>> getUserActivitySummary() async {
    try {
      Logger.info('Fetching user activity summary');
      return await _userService.getUserActivitySummary();
    } catch (e) {
      Logger.error('Failed to get user activity summary', e);
      rethrow;
    }
  }

  /// Delete user (soft delete)
  Future<void> deleteUser(String userId) async {
    try {
      // Verify current user is admin before allowing deletion
      final isAdmin = await AuthService.isAdminUser();
      if (!isAdmin) {
        Logger.warning('Non-admin user attempted to delete user');
        throw Exception('Only admins can delete users');
      }

      Logger.info('Soft deleting user: $userId');
      
      // Log the activity
      await _logAdminActivity('delete_user', {
        'user_id': userId,
      });
      
      await _userService.deleteUser(userId);
    } catch (e) {
      Logger.error('Failed to delete user', e);
      rethrow;
    }
  }

  /// Get recent users
  Future<List<models.User>> getRecentUsers({int limit = 10}) async {
    try {
      Logger.info('Fetching recent users, limit: $limit');
      return await _userService.getRecentUsers(limit: limit);
    } catch (e) {
      Logger.error('Failed to get recent users', e);
      rethrow;
    }
  }

  /// Get suspicious users
  Future<List<models.User>> getSuspiciousUsers() async {
    try {
      Logger.info('Fetching suspicious users');
      return await _userService.getSuspiciousUsers();
    } catch (e) {
      Logger.error('Failed to get suspicious users', e);
      rethrow;
    }
  }

  /// Get user statistics
  Future<models.UserStatistics> getUserStatistics({DateTime? startDate, DateTime? endDate}) async {
    try {
      Logger.info('Fetching user statistics');
      return await _userService.getUserStatistics(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      Logger.error('Failed to get user statistics', e);
      rethrow;
    }
  }
  
  /// Log admin activity
  Future<void> _logAdminActivity(String action, Map<String, dynamic> details) async {
    try {
      final adminId = AuthService.currentUser?.id;
      if (adminId == null) return;
      
      await _client.from(AppConstants.activityLogsTable).insert({
        'admin_id': adminId,
        'action': action,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      Logger.error('Failed to log admin activity', e);
      // Don't rethrow as this is a non-critical operation
    }
  }
}

/// Provider for user management controller
final userManagementControllerProvider = Provider<UserManagementController>((ref) {
  final userService = ref.read(userServiceProvider);
  return UserManagementController(userService, ref);
});