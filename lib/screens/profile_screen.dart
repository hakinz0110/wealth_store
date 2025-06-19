import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _addressController = TextEditingController();
  bool _isEditingAddress = false;
  bool _isSavingAddress = false;
  bool _isInit = true;

  // Get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return baseSize * 0.8; // Smaller font for very small devices
    } else if (screenWidth < 600) {
      return baseSize * 0.9; // Slightly smaller font for phones
    } else {
      return baseSize; // Default size for larger devices
    }
  }

  // Get responsive padding
  EdgeInsets _getResponsivePadding(
    BuildContext context, {
    bool isSmall = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return EdgeInsets.all(isSmall ? 8.0 : 12.0);
    } else {
      return EdgeInsets.all(isSmall ? 12.0 : 16.0);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final authProvider = Provider.of<AuthProvider>(context);
      if (authProvider.user != null) {
        // Fetch user's orders
        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).fetchOrders(authProvider.user!.id);

        // Set address
        _addressController.text = authProvider.user!.address;
      }
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _saveAddress() async {
    setState(() {
      _isSavingAddress = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updateUserAddress(
      _addressController.text,
    );

    setState(() {
      _isSavingAddress = false;
      _isEditingAddress = false;
    });

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address updated successfully')),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update address'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPrivacyPolicy() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'This is a sample privacy policy for Wealth Store. '
            'We collect personal information such as your name, email, and address '
            'solely for the purpose of processing your orders and improving your shopping experience. '
            'We do not share your information with third parties except as necessary to fulfill your orders. '
            'You can request deletion of your account and data at any time by contacting our support team.',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              color: isDarkMode ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Notification Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Order Updates'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Promotions'),
              value: false,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('New Products'),
              value: true,
              onChanged: (value) {},
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Save',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCart() {
    Navigator.of(context).pushNamed('/cart');
  }

  void _navigateToOrders() {
    // This is a placeholder - you would normally navigate to a dedicated orders screen
    // For now, we'll just scroll to the orders section in this profile screen
    // You can replace this with actual navigation code when you have a separate orders screen
  }

  void _showCustomerServiceOptions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Customer Service',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildServiceOption(
                icon: Icons.chat,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Live chat coming soon')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildServiceOption(
                icon: Icons.email,
                title: 'Email Support',
                subtitle: 'Send us an email',
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Email support coming soon')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildServiceOption(
                icon: Icons.phone,
                title: 'Call Us',
                subtitle: 'Speak with customer service',
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Call service coming soon')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildServiceOption(
                icon: Icons.question_answer,
                title: 'FAQs',
                subtitle: 'Frequently asked questions',
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('FAQs coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Function() onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final cartCount = cartProvider.items.length;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final primaryColor = Color(0xFF4B69FF); // Blue color from the screenshot
    final backgroundColor = isDarkMode ? Colors.black : const Color(0xFFF5F7FA);
    final cardColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subtitleColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section with profile image and user info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                      child: Text(
                        'Account',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        // User avatar
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // User details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Edit button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pushNamed('/edit_profile');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              // Account Settings Options
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Address
                    _buildSettingsTile(
                      icon: Icons.location_on,
                      iconColor: Colors.indigo,
                      title: 'Address',
                      subtitle: 'Set shipping delivery address',
                      onTap: () {
                        // Show address edit dialog
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Edit Address'),
                            content: TextField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                hintText: 'Enter your address',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _saveAddress();
                                  Navigator.of(ctx).pop();
                                },
                                child: _isSavingAddress
                                    ? const CircularProgressIndicator()
                                    : const Text('Save'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    _buildDivider(),

                    // My Cart
                    _buildSettingsTile(
                      icon: Icons.shopping_cart,
                      iconColor: Colors.blue,
                      title: 'My Cart',
                      subtitle: 'Checkout products and move to',
                      trailing: cartCount > 0
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                cartCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: _navigateToCart,
                    ),

                    _buildDivider(),

                    // My Orders
                    _buildSettingsTile(
                      icon: Icons.receipt_long,
                      iconColor: Colors.green,
                      title: 'My Orders',
                      subtitle: 'In progress and completed orders',
                      onTap: _navigateToOrders,
                    ),

                    _buildDivider(),

                    // Payment Details
                    _buildSettingsTile(
                      icon: Icons.account_balance,
                      iconColor: Colors.purple,
                      title: 'Payment Details',
                      subtitle: 'Manage payment methods',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment methods coming soon'),
                          ),
                        );
                      },
                    ),

                    _buildDivider(),

                    // My Coupons
                    _buildSettingsTile(
                      icon: Icons.local_offer,
                      iconColor: Colors.amber,
                      title: 'My Coupons',
                      subtitle: 'List of all the discounted coupons',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coupons feature coming soon'),
                          ),
                        );
                      },
                    ),

                    _buildDivider(),

                    // Notifications
                    _buildSettingsTile(
                      icon: Icons.notifications,
                      iconColor: Colors.red,
                      title: 'Notifications',
                      subtitle: 'Get any kind of notification message',
                      onTap: _showNotificationSettings,
                    ),

                    _buildDivider(),

                    // Customer Service
                    _buildSettingsTile(
                      icon: Icons.headset_mic,
                      iconColor: Colors.orange,
                      title: 'Customer Service',
                      subtitle: 'Get help and support',
                      onTap: () {
                        _showCustomerServiceOptions();
                      },
                    ),

                    _buildDivider(),

                    // Account Privacy
                    _buildSettingsTile(
                      icon: Icons.privacy_tip,
                      iconColor: Colors.teal,
                      title: 'Account Privacy',
                      subtitle: 'Manage privacy and connected accounts',
                      onTap: _showPrivacyPolicy,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // App Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              // App Settings Card (With content depending on your actual requirements)
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Dark Mode Setting
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return SwitchListTile(
                          title: const Text('Dark Mode'),
                          secondary: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.dark_mode,
                              color: Colors.deepPurple,
                            ),
                          ),
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                        );
                      },
                    ),

                    _buildDivider(),

                    // Logout Button
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      title: const Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () => authProvider.signOut(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Function() onTap,
    Widget? trailing,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 16,
      color: Colors.grey.withOpacity(0.2),
    );
  }
}
