import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFormWidget extends StatefulWidget {
  // 👉 Only email + password since phone is optional
  final Function(String email, String password) onSubmit;
  final bool isLoading;

  const RegistrationFormWidget({
    Key? key,
    required this.onSubmit,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;
  bool _acceptTerms = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _isPasswordValid = password.length >= 8 &&
          password.contains(RegExp(r'[A-Z]')) &&
          password.contains(RegExp(r'[a-z]')) &&
          password.contains(RegExp(r'[0-9]'));
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _isConfirmPasswordValid =
          _confirmPasswordController.text == _passwordController.text &&
              _confirmPasswordController.text.isNotEmpty;
    });
  }

  double _getPasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;

    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;

    return strength;
  }

  Color _getPasswordStrengthColor() {
    final strength = _getPasswordStrength();
    if (strength <= 0.25) return AppTheme.lightTheme.colorScheme.error;
    if (strength <= 0.5) return AppTheme.lightTheme.colorScheme.secondary;
    if (strength <= 0.75) return AppTheme.lightTheme.colorScheme.secondary;
    return AppTheme.lightTheme.colorScheme.primary;
  }

  String _getPasswordStrengthText() {
    final strength = _getPasswordStrength();
    if (strength <= 0.25) return 'Weak';
    if (strength <= 0.5) return 'Fair';
    if (strength <= 0.75) return 'Good';
    return 'Strong';
  }

  bool get _isFormValid {
    return _formKey.currentState?.validate() == true && _acceptTerms;
  }

  void _submitForm() {
    if (_isFormValid && !widget.isLoading) {
      widget.onSubmit(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email
          Text(
            'Email Address',
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email address',
            ),
            //Email validation using a validator
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email is required";
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return "Enter a valid email";
              }
              return null;
            },
            //Manual call to validate email
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 3.h),

          // Password
          Text('Password',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              )),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Create a strong password',
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "password is required";
              }
              if (value.length < 8) {
                return "Must be at least 8 characters";
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 3.h),

          // Password strength indicator
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getPasswordStrengthColor(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getPasswordStrengthText(),
                style: TextStyle(
                  color: _getPasswordStrengthColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Confirm Password
          Text('Confirm Password',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              )),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              suffixIcon: IconButton(
                icon: Icon(_isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () => setState(() =>
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please confirm password";
              }
              if (value != _passwordController.text) {
                return "Passwords do not match";
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          SizedBox(height: 3.h),

          // Terms
          Row(
            children: [
              Checkbox(
                value: _acceptTerms,
                onChanged: (val) => setState(() => _acceptTerms = val ?? false),
              ),
              const Text("I agree to Terms & Privacy"),
            ],
          ),
          SizedBox(height: 4.h),

          // Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isFormValid ? _submitForm : null,
              child: widget.isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Create Account"),
            ),
          ),
        ],
      ),
    );
  }
}
