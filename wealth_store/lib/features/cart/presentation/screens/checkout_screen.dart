import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wealth_app/core/constants/app_colors.dart';
import 'package:wealth_app/core/constants/app_spacing.dart';
import 'package:wealth_app/features/cart/domain/cart_notifier.dart';
import 'package:wealth_app/features/orders/data/order_repository.dart';
import 'package:wealth_app/features/orders/domain/order_notifier.dart';
import 'package:wealth_app/shared/models/order.dart';
import 'package:wealth_app/shared/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Form data
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCVVController = TextEditingController();
  
  String _paymentMethod = 'credit_card';

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCVVController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_currentStep == 0) {
        if (_formKey.currentState!.validate()) {
          setState(() {
            _currentStep++;
          });
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      } else {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _placeOrder() async {
    // Validate payment form first
    if (_currentStep == 1 && !_formKey.currentState!.validate()) {
      return;
    }

    final cartState = ref.read(cartNotifierProvider);
    if (cartState.items.isEmpty) {
      setState(() {
        _errorMessage = 'Your cart is empty';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current user
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        throw Exception('You must be logged in to place an order');
      }

      // Create shipping address
      final shippingAddress = ShippingAddress(
        fullName: _fullNameController.text,
        addressLine1: _addressController.text,
        addressLine2: '',
        city: _cityController.text,
        state: _stateController.text,
        postalCode: _zipController.text,
        country: 'United States', // Default for now
        phone: _phoneController.text,
        email: _emailController.text,
      );

      // Create order items
      final orderItems = cartState.items.map((item) => OrderItem(
        id: '', // Will be assigned by the database
        orderId: '', // Will be assigned by the database
        productId: item.productId.toString(),
        productName: item.name,
        quantity: item.quantity,
        unitPrice: item.price,
        totalPrice: item.price * item.quantity,
      )).toList();

      // Place order
      final order = await ref.read(orderNotifierProvider.notifier).createOrder(
        total: cartState.total,
        items: orderItems,
        shippingAddress: shippingAddress,
        paymentMethod: _paymentMethod,
      );

      // Clear cart
      await ref.read(cartNotifierProvider.notifier).clearCart();

      // Navigate to order confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        context.go('/orders/${order.id}'); // Navigate to order details
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _currentStep == 0 
              ? () => context.pop() 
              : _previousStep,
        ),
      ),
      body: Column(
        children: [
          // Stepper indicator
          _StepperIndicator(currentStep: _currentStep),
          
          // Main content - scrollable
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: Shipping Information
                _buildShippingForm(),
                
                // Step 2: Payment Information
                _buildPaymentForm(),
                
                // Step 3: Order Summary
                _buildOrderSummary(cartState),
              ],
            ),
          ),
          
          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          
          // Action buttons
          _buildBottomBar(cartState),
        ],
      ),
    );
  }
  
  Widget _buildShippingForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipping Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            
            _buildTextField(
              controller: _phoneController,
              label: 'Phone',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.medium),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'City',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.medium),
                Expanded(
                  child: _buildTextField(
                    controller: _stateController,
                    label: 'State',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.medium),
            
            _buildTextField(
              controller: _zipController,
              label: 'ZIP Code',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your ZIP code';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.large),
            
            // Payment method selection
            _buildPaymentMethodSelector(),
            const SizedBox(height: AppSpacing.large),
            
            // Credit card form (only show if credit card selected)
            if (_paymentMethod == 'credit_card')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _cardNumberController,
                    label: 'Card Number',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      _CardNumberFormatter(),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your card number';
                      }
                      if (value.replaceAll(' ', '').length < 16) {
                        return 'Card number must be 16 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  
                  _buildTextField(
                    controller: _cardNameController,
                    label: 'Cardholder Name',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter cardholder name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.medium),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cardExpiryController,
                          label: 'Expiry Date (MM/YY)',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _CardExpiryFormatter(),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (value.length < 5) {
                              return 'Invalid format';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.medium),
                      Expanded(
                        child: _buildTextField(
                          controller: _cardCVVController,
                          label: 'CVV',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (value.length < 3) {
                              return 'Invalid CVV';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderSummary(cartState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.large),
          
          // Order details card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Items
                  ...cartState.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.small),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.name}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )),
                  
                  const Divider(height: 24),
                  
                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '\$${cartState.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.small),
                  
                  // Shipping
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Shipping',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        'Free',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${cartState.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.large),
          
          // Shipping information
          Text(
            'Shipping Address',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(_fullNameController.text),
          Text(_addressController.text),
          Text('${_cityController.text}, ${_stateController.text} ${_zipController.text}'),
          Text(_phoneController.text),
          
          const SizedBox(height: AppSpacing.large),
          
          // Payment method
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.small),
          Text(_paymentMethod == 'credit_card' 
              ? 'Credit Card ending in ${_cardNumberController.text.isNotEmpty ? _cardNumberController.text.substring(_cardNumberController.text.length - 4) : "****"}'
              : 'Pay on Delivery'),
              
          const SizedBox(height: 100), // Space for bottom bar
        ],
      ),
    );
  }
  
  Widget _buildBottomBar(cartState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.medium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Only show back button for steps 1 and 2
            if (_currentStep > 0 && _currentStep < 2)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Back'),
                ),
              ),
            if (_currentStep > 0 && _currentStep < 2)
              const SizedBox(width: AppSpacing.medium),
            
            Expanded(
              flex: 2,
              child: CustomButton(
                text: _currentStep == 2
                    ? 'Place Order'
                    : 'Continue',
                onPressed: _isLoading
                    ? null
                    : _currentStep == 2
                        ? _placeOrder
                        : _nextStep,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
    );
  }
  
  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Row(
            children: [
              const Icon(Icons.credit_card),
              const SizedBox(width: AppSpacing.medium),
              const Text('Credit/Debit Card'),
            ],
          ),
          value: 'credit_card',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Row(
            children: [
              const Icon(Icons.payments_outlined),
              const SizedBox(width: AppSpacing.medium),
              const Text('Cash on Delivery'),
            ],
          ),
          value: 'cash_on_delivery',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
      ],
    );
  }
}

class _StepperIndicator extends StatelessWidget {
  final int currentStep;
  
  const _StepperIndicator({
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.medium,
        horizontal: AppSpacing.large,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStep(
            context, 
            index: 0, 
            title: 'Shipping',
            isActive: currentStep >= 0,
            isComplete: currentStep > 0,
          ),
          _buildLine(context, isActive: currentStep > 0),
          _buildStep(
            context, 
            index: 1, 
            title: 'Payment',
            isActive: currentStep >= 1,
            isComplete: currentStep > 1,
          ),
          _buildLine(context, isActive: currentStep > 1),
          _buildStep(
            context, 
            index: 2, 
            title: 'Review',
            isActive: currentStep >= 2,
            isComplete: false,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStep(
    BuildContext context, {
    required int index,
    required String title,
    required bool isActive,
    required bool isComplete,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? isComplete
                      ? AppColors.success
                      : AppColors.primary
                  : Colors.grey[300],
            ),
            child: Center(
              child: isComplete
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLine(BuildContext context, {required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey[300],
      ),
    );
  }
}

// Text input formatters
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      final nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != newText.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    
    if (newText.isEmpty) {
      return newValue;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if (i == 1 && i != newText.length - 1) {
        buffer.write('/');
      }
    }

    final string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
} 