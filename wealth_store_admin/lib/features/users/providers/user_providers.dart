import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../models/user_models.dart';
import '../../../services/user_service.dart';
import '../controllers/user_management_controller.dart';

// User service provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// User management controller provider
final userManagementProvider = Provider<UserManagementController>((ref) {
  return UserManagementController(ref.read(userServiceProvider), ref);
});

// Users list provider with filters
final usersListProvider = FutureProvider.family<List<User>, UserFilters?>((ref, filters) async {
  final controller = ref.read(userManagementProvider);
  return await controller.getUsers(filters: filters);
});

// Paginated users provider
final paginatedUsersProvider = FutureProvider.family<List<User>, UserPaginationParams>((ref, params) async {
  final controller = ref.read(userManagementProvider);
  return await controller.getUsers(
    filters: params.filters,
    page: params.page,
    limit: params.limit,
  );
});

// User by ID provider
final userByIdProvider = FutureProvider.family<User?, String>((ref, id) async {
  final controller = ref.read(userManagementProvider);
  return await controller.getUserById(id);
});

// Recent users provider
final recentUsersProvider = FutureProvider.family<List<User>, int>((ref, limit) async {
  final controller = ref.read(userManagementProvider);
  return await controller.getRecentUsers(limit: limit);
});

// User statistics provider
final userStatisticsProvider = FutureProvider.family<UserStatistics, UserDateRange?>((ref, dateRange) async {
  final controller = ref.read(userManagementProvider);
  return await controller.getUserStatistics(
    startDate: dateRange?.startDate,
    endDate: dateRange?.endDate,
  );
});

// Search users provider
final searchUsersProvider = FutureProvider.family<List<User>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    final controller = ref.read(userManagementProvider);
    return await controller.getUsers();
  }
  
  final controller = ref.read(userManagementProvider);
  return await controller.searchUsers(query);
});

// Suspicious users provider
final suspiciousUsersProvider = FutureProvider<List<User>>((ref) async {
  final controller = ref.read(userManagementProvider);
  return await controller.getSuspiciousUsers();
});

// User CRUD operations provider
final userCrudProvider = Provider<UserCrudOperations>((ref) {
  return UserCrudOperations(ref.read(userManagementProvider));
});

// User filters state provider
final userFiltersProvider = StateProvider<UserFilters>((ref) {
  return const UserFilters();
});

// Current page provider for pagination
final userCurrentPageProvider = StateProvider<int>((ref) => 1);

// Items per page provider
final userItemsPerPageProvider = StateProvider<int>((ref) => 20);

// Selected users provider for bulk operations
final selectedUsersProvider = StateProvider<Set<String>>((ref) => {});

class UserCrudOperations {
  final UserManagementController _controller;
  
  UserCrudOperations(this._controller);
  
  Future<User> updateUserStatus(String userId, UserStatus newStatus, {String? reason}) async {
    return await _controller.updateUserStatus(userId, newStatus, reason: reason);
  }
  
  Future<User> updateUserRole(String userId, String role) async {
    return await _controller.updateUserRole(userId, role);
  }
  
  Future<User> markUserAsSuspicious(String userId, String reason) async {
    return await _controller.markUserAsSuspicious(userId, reason);
  }
  
  Future<User> clearSuspiciousFlag(String userId) async {
    return await _controller.clearSuspiciousFlag(userId);
  }
  
  Future<void> deleteUser(String userId) async {
    return await _controller.deleteUser(userId);
  }
  
  Future<List<UserOrder>> getUserOrderHistory(String userId) async {
    return await _controller.getUserOrderHistory(userId);
  }
  
  Future<UserStats> getUserStats(String userId) async {
    return await _controller.getUserStats(userId);
  }
}

// Helper classes for providers
class UserPaginationParams {
  final UserFilters? filters;
  final int page;
  final int limit;

  const UserPaginationParams({
    this.filters,
    required this.page,
    required this.limit,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPaginationParams &&
          runtimeType == other.runtimeType &&
          filters == other.filters &&
          page == other.page &&
          limit == other.limit;

  @override
  int get hashCode => filters.hashCode ^ page.hashCode ^ limit.hashCode;
}

class UserDateRange {
  final DateTime? startDate;
  final DateTime? endDate;

  const UserDateRange({
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDateRange &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

// Computed providers for dashboard metrics
final totalUsersProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(userStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.totalUsers),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final activeUsersProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(userStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.activeUsers),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final newUsersThisMonthProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(userStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.newUsersThisMonth),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final suspiciousUsersCountProvider = Provider<AsyncValue<int>>((ref) {
  return ref.watch(userStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.suspiciousUsers),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final usersByRoleProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  return ref.watch(userStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.usersByRole),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

final usersByStatusProvider = Provider<AsyncValue<Map<String, int>>>((ref) {
  return ref.watch(userStatisticsProvider(null)).when(
    data: (stats) => AsyncValue.data(stats.usersByStatus),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// User role filter options
final userRoleOptionsProvider = Provider<List<UserRole>>((ref) {
  return UserRole.values;
});

// User status filter options
final userStatusOptionsProvider = Provider<List<UserStatus>>((ref) {
  return UserStatus.values;
});

// User sort options
final userSortOptionsProvider = Provider<List<UserSortBy>>((ref) {
  return UserSortBy.values;
});