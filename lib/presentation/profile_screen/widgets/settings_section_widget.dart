import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class SettingsSectionWidget extends StatelessWidget {
  final bool biometricEnabled;
  final String selectedTheme;
  final String selectedLanguage;
  final VoidCallback onBiometricToggle;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onDownloadManagementTap;
  final VoidCallback onHelpSupportTap;
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onTermsServiceTap;

  const SettingsSectionWidget({
    super.key,
    required this.biometricEnabled,
    required this.selectedTheme,
    required this.selectedLanguage,
    required this.onBiometricToggle,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.onDownloadManagementTap,
    required this.onHelpSupportTap,
    required this.onPrivacyPolicyTap,
    required this.onTermsServiceTap,
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
            'Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildBiometricSetting(context),
          SizedBox(height: 2.h),
          _buildThemeSetting(context),
          SizedBox(height: 2.h),
          _buildLanguageSetting(context),
          SizedBox(height: 2.h),
          _buildDownloadManagement(context),
          SizedBox(height: 3.h),
          _buildSupportSection(context),
        ],
      ),
    );
  }

  Widget _buildBiometricSetting(BuildContext context) {
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
              iconName: 'fingerprint',
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
                  'Biometric Authentication',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Use fingerprint or face ID to unlock',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: biometricEnabled,
            onChanged: (value) => onBiometricToggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
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
              iconName: 'palette',
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
                  'App Theme',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  selectedTheme,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            initialValue: selectedTheme,
            onSelected: onThemeChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Light', child: Text('Light')),
              const PopupMenuItem(value: 'Dark', child: Text('Dark')),
              const PopupMenuItem(value: 'System', child: Text('System')),
            ],
            child: CustomIconWidget(
              iconName: 'arrow_drop_down',
              size: 5.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSetting(BuildContext context) {
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
              iconName: 'language',
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
                  'Language',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  selectedLanguage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            initialValue: selectedLanguage,
            onSelected: onLanguageChanged,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'English', child: Text('English')),
              const PopupMenuItem(value: 'Chichewa', child: Text('Chichewa')),
              const PopupMenuItem(value: 'Tumbuka', child: Text('Tumbuka')),
            ],
            child: CustomIconWidget(
              iconName: 'arrow_drop_down',
              size: 5.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadManagement(BuildContext context) {
    return _buildSettingItem(
      context,
      'Download Management',
      'Manage offline content and storage',
      'download',
      onDownloadManagementTap,
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Support & Legal',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        _buildSettingItem(
          context,
          'Help & Support',
          'FAQ and contact support',
          'help',
          onHelpSupportTap,
        ),
        SizedBox(height: 1.h),
        _buildSettingItem(
          context,
          'Privacy Policy',
          'Read our privacy policy',
          'privacy_tip',
          onPrivacyPolicyTap,
        ),
        SizedBox(height: 1.h),
        _buildSettingItem(
          context,
          'Terms of Service',
          'Read our terms of service',
          'description',
          onTermsServiceTap,
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String subtitle,
    String iconName,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              size: 5.w,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
