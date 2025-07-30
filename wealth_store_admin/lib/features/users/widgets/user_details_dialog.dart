import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/user_models.dart';
import 'user_status_badge.dart';

class UserDetailsDialog extends StatelessWidget {
  final User user;

  const UserDetailsDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'User Details',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // User info header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user.profile?.avatarUrl != null
                        ? NetworkImage(user.profile!.avatarUrl!)
                        : null,
                    child: user.profile?.avatarUrl == null
                        ? Text(
                            user.initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.displayName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (user.isSuspicious) ...[
                              Icon(
                                Icons.warning,
                                size: 20,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                            ],
                            if (!user.isEmailVerified) ...[
                              Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            UserRoleBadge(role: user.role, isSmall: true),
                            const SizedBox(width: 8),
                            UserStatusBadge(status: user.status, isSmall: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal info and account info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Personal information
                        Expanded(
                          child: _buildInfoCard(
                            'Personal Information',
                            [
                              _buildInfoRow('Full Name', user.profile?.fullName ?? 'Not provided'),
                              _buildInfoRow('Phone', user.profile?.phoneNumber ?? 'Not provided'),
                              if (user.profile?.dateOfBirth != null)
                                _buildInfoRow('Date of Birth', DateFormat('MMM dd, yyyy').format(user.profile!.dateOfBirth!)),
                              if (user.profile?.gender != null)
                                _buildInfoRow('Gender', user.profile!.gender!),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Account information
                        Expanded(
                          child: _buildInfoCard(
                            'Account Information',
                            [
                              _buildInfoRow('User ID', user.id),
                              _buildInfoRow('Email Verified', user.isEmailVerified ? 'Yes' : 'No'),
                              _buildInfoRow('Registration', DateFormat('MMM dd, yyyy at HH:mm').format(user.createdAt)),
                              if (user.lastLoginAt != null)
                                _buildInfoRow('Last Login', DateFormat('MMM dd, yyyy at HH:mm').format(user.lastLoginAt!))
                              else
                                _buildInfoRow('Last Login', 'Never'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Order statistics and addresses
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order statistics
                        Expanded(
                          child: _buildInfoCard(
                            'Order Statistics',
                            [
                              _buildInfoRow('Total Orders', '${user.totalOrders}'),
                              _buildInfoRow('Total Spent', user.formattedTotalSpent),
                              _buildInfoRow('Average Order Value', user.formattedAverageOrderValue),
                              _buildInfoRow('Customer Since', _getCustomerDuration()),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Addresses
                        Expanded(
                          child: _buildInfoCard(
                            'Addresses (${user.addresses.length})',
                            user.addresses.isEmpty
                                ? [const Text('No addresses added', style: TextStyle(color: AppColors.textSecondary))]
                                : user.addresses.map((address) => _buildAddressItem(address)).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Suspicious activity section
                    if (user.isSuspicious) ...[
                      _buildInfoCard(
                        'Suspicious Activity',
                        [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: AppColors.warning, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'This user has been flagged for suspicious activity',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                      if (user.suspiciousReason != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Reason: ${user.suspiciousReason}',
                                          style: TextStyle(
                                            color: AppColors.warning.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Activity timeline
                    _buildActivityTimeline(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressItem(UserAddress address) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (address.label != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    address.label!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (address.isDefault) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Default',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            address.formattedAddress,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline() {
    final timelineEvents = <Map<String, dynamic>>[];
    
    // Add registration event
    timelineEvents.add({
      'title': 'Account Created',
      'date': user.createdAt,
      'icon': Icons.person_add,
      'color': AppColors.success,
    });
    
    // Add email verification event
    if (user.emailVerifiedAt != null) {
      timelineEvents.add({
        'title': 'Email Verified',
        'date': user.emailVerifiedAt!,
        'icon': Icons.verified,
        'color': AppColors.success,
      });
    }
    
    // Add last login event
    if (user.lastLoginAt != null) {
      timelineEvents.add({
        'title': 'Last Login',
        'date': user.lastLoginAt!,
        'icon': Icons.login,
        'color': AppColors.primary,
      });
    }
    
    // Add suspicious activity event
    if (user.isSuspicious) {
      timelineEvents.add({
        'title': 'Marked as Suspicious',
        'date': user.updatedAt,
        'icon': Icons.warning,
        'color': AppColors.warning,
        'details': user.suspiciousReason,
      });
    }

    // Sort events by date
    timelineEvents.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...timelineEvents.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              final isLast = index == timelineEvents.length - 1;
              
              return _buildTimelineEvent(
                event['title'],
                event['date'],
                event['icon'],
                event['color'],
                details: event['details'],
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineEvent(
    String title,
    DateTime date,
    IconData icon,
    Color color, {
    String? details,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        
        // Event details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM dd, yyyy at HH:mm').format(date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              if (details != null) ...[
                const SizedBox(height: 4),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  String _getCustomerDuration() {
    final duration = DateTime.now().difference(user.createdAt);
    if (duration.inDays > 365) {
      final years = (duration.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    } else if (duration.inDays > 30) {
      final months = (duration.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      return '${duration.inDays} day${duration.inDays > 1 ? 's' : ''}';
    }
  }
}