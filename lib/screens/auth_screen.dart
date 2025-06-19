import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  const AuthScreen({super.key, this.isLogin = true});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: const Color(0xFF6518F4),
                ),
                const SizedBox(height: 16),
                Text(
                  'Wealth Store',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _isLogin ? const LoginForm() : const RegisterForm(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Wealth Store - Premium Shopping Experience',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // If login is successful, navigate to home page
      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = const Color(0xFF6518F4);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Log in to your account',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Error message
          if (authProvider.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  authProvider.error,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),

          // Email input
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Enter your email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 20),

          // Password input
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'Enter your password',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
            onFieldSubmitted: (_) => _login(),
          ),

          // Forgot password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implement forgot password functionality
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Login button
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),

          const SizedBox(height: 20),

          // Divider with OR
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade400)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade400)),
            ],
          ),

          const SizedBox(height: 20),

          // Google sign-in button
          OutlinedButton.icon(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    final success = await authProvider.signInWithGoogle();
                    if (success && mounted) {
                      Navigator.pushReplacementNamed(context, '/main');
                    }
                  },
            icon: Image.asset(
              'assets/images/google_g_logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            label: const Text(
              'Continue with Google',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Register link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account? ',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              GestureDetector(
                onTap: () {
                  final authScreenState = context
                      .findAncestorStateOfType<_AuthScreenState>();
                  if (authScreenState != null) {
                    authScreenState._toggleAuthMode();
                  }
                },
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _subscribeToNewsletter = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _verificationCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Combine first name and last name for the full name
      final fullName =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

      final success = await authProvider.signUpWithEmail(
        fullName,
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // If registration is successful, navigate to login page
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
          ),
        );

        // Find the parent AuthScreen state and toggle to login mode
        final authScreenState = context
            .findAncestorStateOfType<_AuthScreenState>();
        if (authScreenState != null) {
          authScreenState._toggleAuthMode();
        }
      }
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final primaryColor = const Color(0xFF6518F4);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create your account',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Error message
          if (authProvider.error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Text(
                  authProvider.error,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),

          // Personal Information section
          Text(
            'Personal information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 16),

          // First name input
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Last name input
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: 'Last Name',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Newsletter subscription
          Row(
            children: [
              Checkbox(
                value: _subscribeToNewsletter,
                onChanged: (value) {
                  setState(() {
                    _subscribeToNewsletter = value ?? true;
                  });
                },
                activeColor: primaryColor,
              ),
              const Text('Subscribe to our newsletter'),
            ],
          ),

          const SizedBox(height: 24),

          // Login Information section
          Text(
            'Login Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 16),

          // Email input
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          // Verification code row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _verificationCodeController,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    prefixIcon: const Icon(Icons.verified_user),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    // Get verification code functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Get Code'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Password input
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 8),

          // Password requirements
          Text(
            'Must be 6-16 characters with numbers and letters',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 16),

          // Confirm Password input
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Terms and conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreeToTerms,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
                activeColor: primaryColor,
              ),
              Flexible(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Register button
          ElevatedButton(
            onPressed: authProvider.isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Register',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),

          const SizedBox(height: 20),

          // Divider with OR
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade400)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade400)),
            ],
          ),

          const SizedBox(height: 20),

          // Google sign-in button
          OutlinedButton.icon(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    final success = await authProvider.signInWithGoogle();
                    if (success && mounted) {
                      Navigator.pushReplacementNamed(context, '/main');
                    }
                  },
            icon: Image.asset(
              'assets/images/google_g_logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, size: 24);
              },
            ),
            label: const Text(
              'Continue with Google',
              style: TextStyle(fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              GestureDetector(
                onTap: () {
                  final authScreenState = context
                      .findAncestorStateOfType<_AuthScreenState>();
                  if (authScreenState != null) {
                    authScreenState._toggleAuthMode();
                  }
                },
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
