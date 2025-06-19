import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isCheckingOut = false;

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
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill user data if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user != null) {
        _nameController.text = authProvider.user!.name;
        _addressController.text = authProvider.user!.address;
      }
    });
  }

  void _showCheckoutForm(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: isSmallScreen ? 12 : 16,
          right: isSmallScreen ? 12 : 16,
          top: isSmallScreen ? 12 : 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isSmallScreen ? 12 : 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Delivery Address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isCheckingOut
                            ? null
                            : () => _submitOrder(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 14 : 16,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isCheckingOut
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Place Order',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 16),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to place an order'),
        ),
      );
      setState(() {
        _isCheckingOut = false;
      });
      return;
    }

    final success = await orderProvider.placeOrder(
      userId: authProvider.user!.id,
      address: _addressController.text,
      cartItems: cartProvider.items,
      contactNumber: _phoneController.text,
      name: _nameController.text,
    );

    setState(() {
      _isCheckingOut = false;
    });

    if (success && context.mounted) {
      // Update user address if needed
      if (_addressController.text != authProvider.user!.address) {
        await authProvider.updateUserAddress(_addressController.text);
      }

      // Clear cart
      cartProvider.clear();

      // Close bottom sheet
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to place order. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items;
    final theme = Theme.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color lightGray = Colors.grey.shade200;
    final Color darkGray = Colors.grey.shade600;
    final Color blue = Colors.blue;
    final double shippingFee = 5.0;
    final double taxFee = cartProvider.totalAmount * 0.1;
    final double orderTotal = cartProvider.totalAmount + shippingFee + taxFee;
    final TextEditingController promoController = TextEditingController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? theme.primaryColor : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Order Review',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: _getResponsiveFontSize(context, 18),
          ),
        ),
        centerTitle: true,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: isSmallScreen ? 56 : 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(context, 18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to your cart',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: _getResponsiveFontSize(context, 14),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: isSmallScreen ? 12 : 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue Shopping',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: _getResponsiveFontSize(context, 15),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    children: [
                      // Cart Items
                      ...items.map(
                        (item) => Container(
                          margin: EdgeInsets.only(
                            bottom: isSmallScreen ? 12 : 16,
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.product.imageUrl,
                                  width: isSmallScreen ? 48 : 54,
                                  height: isSmallScreen ? 48 : 54,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: isSmallScreen ? 48 : 54,
                                        height: isSmallScreen ? 48 : 54,
                                        color: lightGray,
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 10 : 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item.product.brand ?? 'Nike',
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(
                                              context,
                                              13,
                                            ),
                                            color: darkGray,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified,
                                          color: blue,
                                          size: isSmallScreen ? 14 : 16,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.product.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: _getResponsiveFontSize(
                                          context,
                                          15,
                                        ),
                                      ),
                                    ),
                                    if (item.product.color != null ||
                                        item.product.size != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'Color ${item.product.color ?? ''}  Size ${item.product.size ?? ''}',
                                          style: TextStyle(
                                            fontSize: _getResponsiveFontSize(
                                              context,
                                              12,
                                            ),
                                            color: darkGray,
                                          ),
                                        ),
                                      ),
                                    SizedBox(height: isSmallScreen ? 6 : 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Price
                                        Text(
                                          '\$${item.product.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: _getResponsiveFontSize(
                                              context,
                                              14,
                                            ),
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                        // Quantity controls
                                        Row(
                                          children: [
                                            // Remove item button
                                            InkWell(
                                              onTap: () {
                                                cartProvider.decreaseQuantity(
                                                  item.product.id,
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? Colors.grey.shade800
                                                      : Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: isSmallScreen ? 16 : 18,
                                                ),
                                              ),
                                            ),
                                            // Quantity
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                '${item.quantity}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      _getResponsiveFontSize(
                                                        context,
                                                        14,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            // Add item button
                                            InkWell(
                                              onTap: () {
                                                cartProvider.addItem(
                                                  item.product,
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: isSmallScreen ? 16 : 18,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Promo Code
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 10 : 12,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: isSmallScreen ? 6 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode ? theme.cardColor : lightGray,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: promoController,
                                decoration: InputDecoration(
                                  hintText: 'Have a promo code? Enter here',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    fontSize: _getResponsiveFontSize(
                                      context,
                                      14,
                                    ),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 14),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 14 : 18,
                                  vertical: isSmallScreen ? 8 : 10,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: _getResponsiveFontSize(context, 14),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Order Summary
                      Container(
                        margin: EdgeInsets.only(
                          bottom: isSmallScreen ? 12 : 16,
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Order Summary',
                                  style: TextStyle(
                                    fontSize: _getResponsiveFontSize(
                                      context,
                                      16,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 10 : 12),
                            _summaryRow('Subtotal', cartProvider.totalAmount),
                            SizedBox(height: isSmallScreen ? 4 : 6),
                            _summaryRow('Shipping Fee', shippingFee),
                            SizedBox(height: isSmallScreen ? 4 : 6),
                            _summaryRow('Tax Fee', taxFee),
                            Divider(height: isSmallScreen ? 20 : 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _getResponsiveFontSize(
                                      context,
                                      16,
                                    ),
                                  ),
                                ),
                                Text(
                                  '\$${orderTotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: _getResponsiveFontSize(
                                      context,
                                      18,
                                    ),
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Checkout Button
                SafeArea(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    child: ElevatedButton(
                      onPressed: () => _showCheckoutForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 14 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Checkout \$${orderTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: _getResponsiveFontSize(context, 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(String label, double value) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
