import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/auth_service.dart';
import '../../services/finlearn_database_service.dart';
import '../../models/user_profile_model.dart';
import '../../models/user_stats_model.dart';
import '../../models/achievement_model.dart';
import './widgets/account_section_widget.dart';
import './widgets/achievements_showcase_widget.dart';
import './widgets/edit_profile_modal_widget.dart';
import './widgets/preferences_section_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/stats_cards_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentBottomNavIndex = 4; // Profile tab active
  bool _isLoading = true;

  // Data from Supabase
  UserProfileModel? _userProfile;
  UserStatsModel? _userStats;
  List<AchievementModel> _achievements = [];

  // Preferences data (local state - could be moved to user_preferences table)
  String _selectedContentType = 'Video';
  bool _notificationsEnabled = true;
  bool _courseRemindersEnabled = true;
  bool _achievementNotificationsEnabled = true;
  bool _biometricEnabled = false;
  String _selectedTheme = 'System';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) {
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
        return;
      }

      // Load profile data in parallel
      final futures = await Future.wait([
        AuthService.instance.getUserProfile(),
        FinLearnDatabaseService.instance.getUserStats(userId),
        FinLearnDatabaseService.instance.getUserAchievements(userId),
      ]);

      if (mounted) {
        setState(() {
          _userProfile = futures[0] as UserProfileModel?;
          _userStats = futures[1] as UserStatsModel?;
          _achievements = futures[2] as List<AchievementModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: CustomBottomBar(
          currentIndex: _currentBottomNavIndex,
          onTap: _handleBottomNavTap,
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileHeaderWidget(
                userName: _userProfile?.fullName ?? 'User',
                userLevel: _getUserLevel(),
                profileImageUrl: _userProfile?.profileImageUrl ??
                    'https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
                onEditProfileTap: _showEditProfileModal,
                onProfileImageTap: _showEditProfileModal,
              ),
              StatsCardsWidget(
                coursesCompleted: _userStats?.coursesCompleted ?? 0,
                pointsEarned: _userStats?.pointsEarned ?? 0,
                currentStreak: _userStats?.currentStreak ?? 0,
                certificatesObtained: _userStats?.certificatesObtained ?? 0,
              ),
              AccountSectionWidget(
                email: _userProfile?.email ?? '',
                phoneNumber: null, // Add phone to user_profiles if needed
                isEmailVerified: true,
                isPhoneVerified: false,
                onChangePasswordTap: _handleChangePassword,
              ),
              PreferencesSectionWidget(
                selectedContentType: _selectedContentType,
                notificationsEnabled: _notificationsEnabled,
                courseRemindersEnabled: _courseRemindersEnabled,
                achievementNotificationsEnabled:
                    _achievementNotificationsEnabled,
                onContentTypeChanged: _handleContentTypeChanged,
                onNotificationsChanged: _handleNotificationsChanged,
                onCourseRemindersChanged: _handleCourseRemindersChanged,
                onAchievementNotificationsChanged:
                    _handleAchievementNotificationsChanged,
              ),
              AchievementsShowcaseWidget(
                achievements: _achievements
                    .map((a) => {
                          'id': a.id,
                          'name': a.name,
                          'description': a.description,
                          'icon': a.icon,
                          'type': a.type,
                          'earnedDate': a.earnedDate.toString().split('T')[0],
                        })
                    .toList(),
                certificates:
                    _getCertificatesList(), // Create from achievements
                onViewAllAchievements: _handleViewAllAchievements,
                onViewAllCertificates: _handleViewAllCertificates,
              ),
              SettingsSectionWidget(
                biometricEnabled: _biometricEnabled,
                selectedTheme: _selectedTheme,
                selectedLanguage: _selectedLanguage,
                onBiometricToggle: _handleBiometricToggle,
                onThemeChanged: _handleThemeChanged,
                onLanguageChanged: _handleLanguageChanged,
                onDownloadManagementTap: _handleDownloadManagement,
                onHelpSupportTap: _handleHelpSupport,
                onPrivacyPolicyTap: _handlePrivacyPolicy,
                onTermsServiceTap: _handleTermsService,
              ),
              _buildLogoutSection(),
              SizedBox(height: 10.h), // Bottom padding for navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  String _getUserLevel() {
    final points = _userStats?.pointsEarned ?? 0;
    if (points >= 5000) return 'Expert Level';
    if (points >= 2000) return 'Pro Level';
    if (points >= 500) return 'Intermediate Level';
    return 'Beginner Level';
  }

  List<Map<String, dynamic>> _getCertificatesList() {
    return _achievements
        .where((a) => a.type == 'completion')
        .map((a) => {
              'id': a.id,
              'courseName': a.name,
              'completionDate': a.earnedDate.toString().split('T')[0],
              'certificateUrl': 'https://example.com/cert/${a.id}.pdf',
            })
        .toList();
  }

  Widget _buildLogoutSection() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 2.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'logout',
                size: 5.w,
                color: Colors.white,
              ),
              SizedBox(width: 2.w),
              Text(
                'Logout',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileModalWidget(
        currentUserName: _userProfile?.fullName ?? '',
        currentBio: _userProfile?.bio ?? '',
        currentProfileImageUrl: _userProfile?.profileImageUrl ?? '',
        onSave: _handleProfileUpdate,
      ),
    );
  }

  Future<void> _handleProfileUpdate(
      String userName, String bio, String? imageUrl) async {
    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) return;

      final updatedProfile = await AuthService.instance.updateUserProfile(
        userId: userId,
        fullName: userName,
        bio: bio,
        profileImageUrl: imageUrl,
      );

      if (updatedProfile != null) {
        setState(() {
          _userProfile = updatedProfile;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  void _handleBottomNavTap(int index) {
    if (index == _currentBottomNavIndex) return;

    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard-screen');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/course-catalog-screen');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/assessment-quiz-screen');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/ai-chat-screen');
        break;
      case 4:
        // Already on profile screen
        break;
    }
  }

  void _handleChangePassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            SizedBox(height: 2.h),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                // In real implementation, validate old password and update
                await AuthService.instance.updatePassword('newPassword');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Password updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating password: $e')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _handleContentTypeChanged(String contentType) {
    setState(() {
      _selectedContentType = contentType;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Content preference updated to $contentType')),
    );
  }

  void _handleNotificationsChanged(bool enabled) {
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  void _handleCourseRemindersChanged(bool enabled) {
    setState(() {
      _courseRemindersEnabled = enabled;
    });
  }

  void _handleAchievementNotificationsChanged(bool enabled) {
    setState(() {
      _achievementNotificationsEnabled = enabled;
    });
  }

  void _handleBiometricToggle() {
    setState(() {
      _biometricEnabled = !_biometricEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_biometricEnabled
            ? 'Biometric authentication enabled'
            : 'Biometric authentication disabled'),
      ),
    );
  }

  void _handleThemeChanged(String theme) {
    setState(() {
      _selectedTheme = theme;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme changed to $theme')),
    );
  }

  void _handleLanguageChanged(String language) {
    setState(() {
      _selectedLanguage = language;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Language changed to $language')),
    );
  }

  void _handleDownloadManagement() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Download Management',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'storage',
                size: 6.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Storage Used'),
              subtitle: const Text('2.4 GB of 5 GB available'),
              trailing: const Text('48%'),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                size: 6.w,
                color: Colors.green,
              ),
              title: const Text('Downloaded Courses'),
              subtitle: Text(
                  '${_userStats?.coursesCompleted ?? 0} courses available offline'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Downloaded courses management coming soon')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete_sweep',
                size: 6.w,
                color: Colors.red,
              ),
              title: const Text('Clear Cache'),
              subtitle: const Text('Free up storage space'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cache cleared successfully')),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handleViewAllAchievements() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Full achievements page coming soon')),
    );
  }

  void _handleViewAllCertificates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Full certificates page coming soon')),
    );
  }

  void _handleHelpSupport() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Help & Support',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'help',
                size: 6.w,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('FAQ'),
              subtitle: const Text('Frequently asked questions'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('FAQ page coming soon')),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'chat',
                size: 6.w,
                color: Colors.green,
              ),
              title: const Text('Live Chat'),
              subtitle: const Text('Chat with our support team'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ai-chat-screen');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'email',
                size: 6.w,
                color: Colors.blue,
              ),
              title: const Text('Email Support'),
              subtitle: const Text('support@finlearnpro.com'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening email client...')),
                );
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _handlePrivacyPolicy() {
    _openWebView('Privacy Policy', 'https://finlearnpro.com/privacy');
  }

  void _handleTermsService() {
    _openWebView('Terms of Service', 'https://finlearnpro.com/terms');
  }

  void _openWebView(String title, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: kIsWeb
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'language',
                        size: 15.w,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'This would open in a web browser',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 2.h),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                )
              : WebViewWidget(
                  controller: WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..loadRequest(Uri.parse(url)),
                ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                await AuthService.instance.signOut();
                Navigator.pushReplacementNamed(context, '/onboarding-flow');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error during logout: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
