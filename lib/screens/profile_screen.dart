import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';

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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This is a sample privacy policy for Wealth Store. '
            'We collect personal information such as your name, email, and address '
            'solely for the purpose of processing your orders and improving your shopping experience. '
            'We do not share your information with third parties except as necessary to fulfill your orders. '
            'You can request deletion of your account and data at any time by contacting our support team.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help Center'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Frequently Asked Questions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Q: How do I track my order?'),
              Text(
                'A: You can view your order status in the "My Orders" section of your profile.',
              ),
              SizedBox(height: 8),
              Text('Q: How can I return a product?'),
              Text(
                'A: Contact our support team within 7 days of receiving your order.',
              ),
              SizedBox(height: 8),
              Text('Q: What payment methods do you accept?'),
              Text(
                'A: We accept credit cards, debit cards, and digital wallets.',
              ),
              SizedBox(height: 16),
              Text('Contact Us', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Email: support@wealthstore.com'),
              Text('Phone: +1 (555) 123-4567'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;
    final orders = orderProvider.orders;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => authProvider.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Name'),
                        subtitle: Text(user.name),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.email),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Delivery Address'),
                        subtitle: _isEditingAddress
                            ? TextField(
                                controller: _addressController,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your address',
                                ),
                              )
                            : Text(
                                user.address.isEmpty
                                    ? 'No address provided'
                                    : user.address,
                              ),
                        contentPadding: EdgeInsets.zero,
                        trailing: _isEditingAddress
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: _isSavingAddress
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.check),
                                    onPressed: _isSavingAddress
                                        ? null
                                        : _saveAddress,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _isEditingAddress = false;
                                        _addressController.text = user.address;
                                      });
                                    },
                                  ),
                                ],
                              )
                            : IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  setState(() {
                                    _isEditingAddress = true;
                                  });
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order History
              const Text(
                'Order History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              orderProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orders.isEmpty
                  ? const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: Text('No orders yet')),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orders.length,
                      itemBuilder: (ctx, index) {
                        final order = orders[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ExpansionTile(
                            title: Text(
                              'Order #${order.id.substring(0, 8)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${DateFormat('MMM dd, yyyy').format(order.orderDate)}',
                                ),
                                Text(
                                  'Status: ${order.status}',
                                  style: TextStyle(
                                    color: order.status == 'Delivered'
                                        ? Colors.green
                                        : order.status == 'Pending'
                                        ? Colors.orange
                                        : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Total: \$${order.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Delivery Address: ${order.address}'),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Products:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ...order.products.map(
                                      (product) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 4,
                                        ),
                                        child: Text(
                                          '• ${product['name']} (x${product['quantity']}) - \$${product['totalPrice'].toStringAsFixed(2)}',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 24),

              // Help and Support
              const Text(
                'Help & Support',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.privacy_tip),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showPrivacyPolicy,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help Center'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _showHelpCenter,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
