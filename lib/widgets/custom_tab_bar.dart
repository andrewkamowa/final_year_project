import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomTabBarVariant {
  standard,
  pills,
  underlined,
  segmented,
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final TabController? controller;
  final CustomTabBarVariant variant;
  final ValueChanged<int>? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final bool isScrollable;
  final double? indicatorWeight;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.variant = CustomTabBarVariant.standard,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.backgroundColor,
    this.padding,
    this.isScrollable = false,
    this.indicatorWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context);
      case CustomTabBarVariant.underlined:
        return _buildUnderlinedTabBar(context);
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context);
      case CustomTabBarVariant.standard:
      default:
        return _buildStandardTabBar(context);
    }
  }

  Widget _buildStandardTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        onTap: onTap,
        isScrollable: isScrollable,
        labelColor: selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor: unselectedColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: indicatorColor ?? theme.colorScheme.primary,
        indicatorWeight: indicatorWeight ?? 2.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildPillsTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding ?? const EdgeInsets.all(16),
      child: DefaultTabController(
        length: tabs.length,
        child: Builder(
          builder: (context) {
            final tabController =
                controller ?? DefaultTabController.of(context);

            return Container(
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: TabBar(
                controller: tabController,
                tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                onTap: onTap,
                isScrollable: isScrollable,
                indicator: BoxDecoration(
                  color: selectedColor ?? theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: unselectedColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.6),
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                dividerColor: Colors.transparent,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUnderlinedTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        onTap: onTap,
        isScrollable: isScrollable,
        labelColor: selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor: unselectedColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: indicatorColor ?? theme.colorScheme.primary,
        indicatorWeight: indicatorWeight ?? 3.0,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.50,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.50,
        ),
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor ?? theme.colorScheme.surface,
      padding: padding ?? const EdgeInsets.all(16),
      child: DefaultTabController(
        length: tabs.length,
        child: Builder(
          builder: (context) {
            final tabController =
                controller ?? DefaultTabController.of(context);

            return Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: TabBar(
                controller: tabController,
                tabs: tabs.map((tab) => Tab(text: tab)).toList(),
                onTap: onTap,
                isScrollable: isScrollable,
                indicator: BoxDecoration(
                  color: selectedColor ?? theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: unselectedColor ??
                    theme.colorScheme.onSurface.withValues(alpha: 0.7),
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                dividerColor: Colors.transparent,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    switch (variant) {
      case CustomTabBarVariant.pills:
        return const Size.fromHeight(72); // 40 + 32 padding
      case CustomTabBarVariant.segmented:
        return const Size.fromHeight(80); // 48 + 32 padding
      case CustomTabBarVariant.underlined:
        return const Size.fromHeight(49); // Standard height + border
      case CustomTabBarVariant.standard:
      default:
        return const Size.fromHeight(48);
    }
  }
}

/// A specialized tab bar for course categories
class CustomCourseTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController? controller;
  final ValueChanged<int>? onTap;

  const CustomCourseTabBar({
    super.key,
    this.controller,
    this.onTap,
  });

  static const List<String> _courseTabs = [
    'All Courses',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Favorites',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
      tabs: _courseTabs,
      controller: controller,
      onTap: onTap,
      variant: CustomTabBarVariant.pills,
      isScrollable: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

/// A specialized tab bar for assessment categories
class CustomAssessmentTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController? controller;
  final ValueChanged<int>? onTap;

  const CustomAssessmentTabBar({
    super.key,
    this.controller,
    this.onTap,
  });

  static const List<String> _assessmentTabs = [
    'Practice',
    'Mock Tests',
    'Skill Check',
    'Progress',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
      tabs: _assessmentTabs,
      controller: controller,
      onTap: onTap,
      variant: CustomTabBarVariant.segmented,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

/// A specialized tab bar for profile sections
class CustomProfileTabBar extends StatelessWidget
    implements PreferredSizeWidget {
  final TabController? controller;
  final ValueChanged<int>? onTap;

  const CustomProfileTabBar({
    super.key,
    this.controller,
    this.onTap,
  });

  static const List<String> _profileTabs = [
    'Overview',
    'Achievements',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
      tabs: _profileTabs,
      controller: controller,
      onTap: onTap,
      variant: CustomTabBarVariant.underlined,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(49);
}
