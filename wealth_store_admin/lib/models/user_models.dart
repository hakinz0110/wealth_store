enum UserRole {
  customer,
  admin,
  moderator;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.admin:
        return 'Admin';
      case UserRole.moderator:
        return 'Moderator';
    }
  }

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.name == role.toLowerCase(),
      orElse: () => UserRole.customer,
    );
  }
}

enum UserStatus {
  active('active', 'Active'),
  inactive('inactive', 'Inactive'),
  suspended('suspended', 'Suspended'),
  banned('banned', 'Banned');

  const UserStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  String get color {
    switch (this) {
      case UserStatus.active:
        return '#10B981'; // Green
      case UserStatus.inactive:
        return '#6B7280'; // Gray
      case UserStatus.suspended:
        return '#F59E0B'; // Orange
      case UserStatus.banned:
        return '#EF4444'; // Red
    }
  }

  static UserStatus fromString(String status) {
    return UserStatus.values.firstWhere(
      (e) => e.value == status.toLowerCase(),
      orElse: () => UserStatus.active,
    );
  }
}

class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? avatarUrl;
  final Map<String, dynamic>? preferences;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.avatarUrl,
    this.preferences,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'avatar_url': avatarUrl,
      'preferences': preferences,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return '';
  }

  String get initials {
    final first = firstName?.isNotEmpty == true ? firstName![0].toUpperCase() : '';
    final last = lastName?.isNotEmpty == true ? lastName![0].toUpperCase() : '';
    return '$first$last';
  }
}

class UserAddress {
  final String id;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final String? label; // e.g., "Home", "Work"

  const UserAddress({
    required this.id,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.isDefault = false,
    this.label,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] as String,
      addressLine1: json['address_line_1'] as String,
      addressLine2: json['address_line_2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      isDefault: json['is_default'] as bool? ?? false,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'is_default': isDefault,
      'label': label,
    };
  }

  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
      '$city, $state $postalCode',
      country,
    ];
    return parts.join('\n');
  }
}

class User {
  final String id;
  final String email;
  final UserRole role;
  final UserStatus status;
  final UserProfile? profile;
  final List<UserAddress> addresses;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? emailVerifiedAt;
  final int totalOrders;
  final double totalSpent;
  final bool isSuspicious;
  final String? suspiciousReason;

  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    this.profile,
    required this.addresses,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.emailVerifiedAt,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.isSuspicious = false,
    this.suspiciousReason,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: UserRole.fromString(json['role'] as String? ?? 'customer'),
      status: UserStatus.fromString(json['status'] as String? ?? 'active'),
      profile: json['profile'] != null 
          ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      addresses: (json['addresses'] as List<dynamic>?)
          ?.map((addr) => UserAddress.fromJson(addr as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLoginAt: json['last_login_at'] != null 
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at'] as String)
          : null,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      isSuspicious: json['is_suspicious'] as bool? ?? false,
      suspiciousReason: json['suspicious_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'status': status.name,
      'profile': profile?.toJson(),
      'addresses': addresses.map((addr) => addr.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'is_suspicious': isSuspicious,
      'suspicious_reason': suspiciousReason,
    };
  }

  User copyWith({
    String? id,
    String? email,
    UserRole? role,
    UserStatus? status,
    UserProfile? profile,
    List<UserAddress>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    DateTime? emailVerifiedAt,
    int? totalOrders,
    double? totalSpent,
    bool? isSuspicious,
    String? suspiciousReason,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      status: status ?? this.status,
      profile: profile ?? this.profile,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      isSuspicious: isSuspicious ?? this.isSuspicious,
      suspiciousReason: suspiciousReason ?? this.suspiciousReason,
    );
  }

  // Helper getters
  String get displayName => profile?.fullName.isNotEmpty == true 
      ? profile!.fullName 
      : email.split('@').first;
  
  String get initials => profile?.initials.isNotEmpty == true 
      ? profile!.initials 
      : email.substring(0, 2).toUpperCase();
  
  bool get isEmailVerified => emailVerifiedAt != null;
  bool get hasRecentActivity => lastLoginAt != null && 
      lastLoginAt!.isAfter(DateTime.now().subtract(const Duration(days: 30)));
  
  String get formattedTotalSpent => '\$${totalSpent.toStringAsFixed(2)}';
  double get averageOrderValue => totalOrders > 0 ? totalSpent / totalOrders : 0.0;
  String get formattedAverageOrderValue => '\$${averageOrderValue.toStringAsFixed(2)}';
  
  UserAddress? get defaultAddress => addresses.where((addr) => addr.isDefault).firstOrNull;
}

// User filters and sorting
enum UserSortBy {
  name,
  email,
  role,
  createdAt,
  lastLoginAt,
  totalOrders,
  totalSpent,
  status,
}

enum SortOrder {
  ascending,
  descending,
}

class UserFilters {
  final UserRole? role;
  final UserStatus? status;
  final bool? isActive;
  final bool? isVerified;
  final DateTime? registrationStartDate;
  final DateTime? registrationEndDate;
  final DateTime? lastLoginStartDate;
  final DateTime? lastLoginEndDate;
  final bool? emailVerified;
  final bool? hasOrders;
  final bool? isSuspicious;
  final double? minTotalSpent;
  final double? maxTotalSpent;
  final String? searchQuery; // Search by email, name, or phone
  final UserSortBy sortBy;
  final SortOrder sortOrder;

  const UserFilters({
    this.role,
    this.status,
    this.isActive,
    this.isVerified,
    this.registrationStartDate,
    this.registrationEndDate,
    this.lastLoginStartDate,
    this.lastLoginEndDate,
    this.emailVerified,
    this.hasOrders,
    this.isSuspicious,
    this.minTotalSpent,
    this.maxTotalSpent,
    this.searchQuery,
    this.sortBy = UserSortBy.createdAt,
    this.sortOrder = SortOrder.descending,
  });

  UserFilters copyWith({
    UserRole? role,
    UserStatus? status,
    bool? isActive,
    bool? isVerified,
    DateTime? registrationStartDate,
    DateTime? registrationEndDate,
    DateTime? lastLoginStartDate,
    DateTime? lastLoginEndDate,
    bool? emailVerified,
    bool? hasOrders,
    bool? isSuspicious,
    double? minTotalSpent,
    double? maxTotalSpent,
    String? searchQuery,
    UserSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    return UserFilters(
      role: role ?? this.role,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      registrationStartDate: registrationStartDate ?? this.registrationStartDate,
      registrationEndDate: registrationEndDate ?? this.registrationEndDate,
      lastLoginStartDate: lastLoginStartDate ?? this.lastLoginStartDate,
      lastLoginEndDate: lastLoginEndDate ?? this.lastLoginEndDate,
      emailVerified: emailVerified ?? this.emailVerified,
      hasOrders: hasOrders ?? this.hasOrders,
      isSuspicious: isSuspicious ?? this.isSuspicious,
      minTotalSpent: minTotalSpent ?? this.minTotalSpent,
      maxTotalSpent: maxTotalSpent ?? this.maxTotalSpent,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role?.name,
      'status': status?.name,
      'registration_start_date': registrationStartDate?.toIso8601String(),
      'registration_end_date': registrationEndDate?.toIso8601String(),
      'last_login_start_date': lastLoginStartDate?.toIso8601String(),
      'last_login_end_date': lastLoginEndDate?.toIso8601String(),
      'email_verified': emailVerified,
      'has_orders': hasOrders,
      'is_suspicious': isSuspicious,
      'min_total_spent': minTotalSpent,
      'max_total_spent': maxTotalSpent,
      'search_query': searchQuery,
      'sort_by': sortBy.name,
      'sort_order': sortOrder.name,
    };
  }
}

// User statistics for dashboard
class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int newUsersThisMonth;
  final int verifiedUsers;
  final int suspiciousUsers;
  final double averageOrdersPerUser;
  final double averageSpentPerUser;
  final Map<String, int> usersByRole;
  final Map<String, int> usersByStatus;
  final Map<String, int> newUsersByMonth;

  const UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersThisMonth,
    this.verifiedUsers = 0,
    required this.suspiciousUsers,
    this.averageOrdersPerUser = 0.0,
    this.averageSpentPerUser = 0.0,
    required this.usersByRole,
    required this.usersByStatus,
    this.newUsersByMonth = const {},
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: (json['total_users'] as num).toInt(),
      activeUsers: (json['active_users'] as num).toInt(),
      newUsersThisMonth: (json['new_users_this_month'] as num).toInt(),
      verifiedUsers: (json['verified_users'] as num).toInt(),
      suspiciousUsers: (json['suspicious_users'] as num).toInt(),
      averageOrdersPerUser: (json['average_orders_per_user'] as num).toDouble(),
      averageSpentPerUser: (json['average_spent_per_user'] as num).toDouble(),
      usersByRole: Map<String, int>.from(json['users_by_role'] as Map),
      usersByStatus: Map<String, int>.from(json['users_by_status'] as Map),
      newUsersByMonth: Map<String, int>.from(json['new_users_by_month'] as Map),
    );
  }

  String get formattedAverageSpentPerUser => '\$${averageSpentPerUser.toStringAsFixed(2)}';
}

// User order history item
class UserOrder {
  final String id;
  final String orderId;
  final String userId;
  final double total;
  final String status;
  final DateTime createdAt;
  final List<Map<String, dynamic>> items;

  const UserOrder({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    return UserOrder(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: List<Map<String, dynamic>>.from(json['items'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'total': total,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'items': items,
    };
  }
}

// Alias for UserStatistics
typedef UserStats = UserStatistics;