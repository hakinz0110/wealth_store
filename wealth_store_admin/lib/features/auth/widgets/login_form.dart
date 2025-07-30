import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/auth_models.dart';

class LoginForm extends HookWidget {
  final bool isLoading;
  final Function(LoginRequest) onSubmit;

  const LoginForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final rememberMe = useState(false);
    final obscurePassword = useState(true);

    void handleSubmit() {
      if (formKey.currentState?.validate() ?? false) {
        final request = LoginRequest(
          email: emailController.text.trim(),
          password: passwordController.text,
          rememberMe: rememberMe.value,
        );
        onSubmit(request);
      }
    }

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            decoration: const InputDecoration(
              labelText: 'E-Mail',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          TextFormField(
            controller: passwordController,
            obscureText: obscurePassword.value,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            onFieldSubmitted: (_) => handleSubmit(),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword.value 
                      ? Icons.visibility_outlined 
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => obscurePassword.value = !obscurePassword.value,
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Remember me and forgot password row
          Row(
            children: [
              Checkbox(
                value: rememberMe.value,
                onChanged: isLoading ? null : (value) {
                  rememberMe.value = value ?? false;
                },
                activeColor: AppColors.primaryBlue,
              ),
              const Text('Remember Me'),
              const Spacer(),
              TextButton(
                onPressed: isLoading ? null : () {
                  context.go('/forgot-password');
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Sign in button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Developer login button
          Container(
            width: double.infinity,
            height: 48,
            margin: const EdgeInsets.only(bottom: 12),
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : () {
                context.go('/developer-login');
              },
              icon: const Icon(Icons.code, size: 18),
              label: const Text('Developer Login'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
          // Register link (for development only)
          TextButton(
            onPressed: isLoading ? null : () {
              // Navigate to register screen
              context.go('/register');
            },
            child: Text(
              'Need an admin account? Register here',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}