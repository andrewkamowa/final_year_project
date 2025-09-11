import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AccountSectionWidget extends StatelessWidget {
  final String email;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final VoidCallback onChangePasswordTap;

  const AccountSectionWidget({
    super.key,
    required this.email,
    this.phoneNumber,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.onChangePasswordTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Information',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildAccountItem(
            context,
            'Email Address',
            email,
            'email',
            isEmailVerified,
          ),
          if (phoneNumber != null) ...[
            SizedBox(height: 2.h),
            _buildAccountItem(
              context,
              'Phone Number',
              phoneNumber!,
              'phone',
              isPhoneVerified,
            ),
          ],
          SizedBox(height: 2.h),
          _buildChangePasswordButton(context),
        ],
      ),
    );
  }

  Widget _buildAccountItem(
    BuildContext context,
    String label,
    String value,
    String iconName,
    bool isVerified,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              size: 5.w,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildVerificationBadge(context, isVerified),
        ],
      ),
    );
  }

  Widget _buildVerificationBadge(BuildContext context, bool isVerified) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: isVerified
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: isVerified ? 'verified' : 'warning',
            size: 3.w,
            color: isVerified ? Colors.green : Colors.orange,
          ),
          SizedBox(width: 1.w),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: theme.textTheme.labelSmall?.copyWith(
              color: isVerified ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangePasswordButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onChangePasswordTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'lock',
              size: 4.w,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            Text(
              'Change Password',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
