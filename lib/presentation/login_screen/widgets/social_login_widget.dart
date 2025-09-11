import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SocialLoginWidget extends StatelessWidget {
  final Function(String provider) onSocialLogin;
  final bool isLoading;

  const SocialLoginWidget({
    Key? key,
    required this.onSocialLogin,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "Or continue with"
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'Or continue with',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.lightTheme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Social Login Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              'Google',
              'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/google/google-original.svg',
              () => onSocialLogin('google'),
            ),
            _buildSocialButton(
              'Apple',
              'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/apple/apple-original.svg',
              () => onSocialLogin('apple'),
            ),
            _buildSocialButton(
              'Facebook',
              'https://cdn.jsdelivr.net/gh/devicons/devicon/icons/facebook/facebook-original.svg',
              () => onSocialLogin('facebook'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(String name, String iconUrl, VoidCallback onTap) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 20.w,
        height: 6.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.lightTheme.colorScheme.surface,
        ),
        child: Center(
          child: CustomImageWidget(
            imageUrl: iconUrl,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
