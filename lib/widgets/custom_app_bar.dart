import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  standard,
  centered,
  minimal,
  withActions,
  withSearch,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onSearchTap;
  final String? searchHint;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onSearchTap,
    this.searchHint = 'Search courses...',
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: _buildTitle(context),
      centerTitle: variant == CustomAppBarVariant.centered,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? 0,
      surfaceTintColor: Colors.transparent,
      leading: _buildLeading(context),
      automaticallyImplyLeading: automaticallyImplyLeading && !showBackButton,
      actions: _buildActions(context),
      titleTextStyle: GoogleFonts.inter(
        fontSize: variant == CustomAppBarVariant.minimal ? 16 : 18,
        fontWeight: FontWeight.w600,
        color: foregroundColor ?? theme.appBarTheme.foregroundColor,
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    switch (variant) {
      case CustomAppBarVariant.withSearch:
        return GestureDetector(
          onTap: onSearchTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    searchHint ?? 'Search courses...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case CustomAppBarVariant.minimal:
        return null;
      default:
        return title != null ? Text(title!) : null;
    }
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 20),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    // For dashboard and main screens, show menu or profile
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == '/dashboard-screen') {
      return IconButton(
        icon: const Icon(Icons.menu, size: 24),
        onPressed: () {
          // Open drawer or navigation menu
          Scaffold.of(context).openDrawer();
        },
        tooltip: 'Menu',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> actionWidgets = [];

    // Add default actions based on variant and current route
    final currentRoute = ModalRoute.of(context)?.settings.name;

    switch (variant) {
      case CustomAppBarVariant.withActions:
        if (currentRoute == '/dashboard-screen') {
          actionWidgets.addAll([
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 24),
              onPressed: () {
                // Handle notifications
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications coming soon')),
                );
              },
              tooltip: 'Notifications',
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, size: 24),
              onPressed: () {
                Navigator.pushNamed(context, '/profile-screen');
              },
              tooltip: 'Profile',
            ),
          ]);
        } else if (currentRoute == '/course-catalog-screen') {
          actionWidgets.addAll([
            IconButton(
              icon: const Icon(Icons.filter_list, size: 24),
              onPressed: () {
                // Handle filter
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter options coming soon')),
                );
              },
              tooltip: 'Filter',
            ),
            IconButton(
              icon: const Icon(Icons.search, size: 24),
              onPressed: onSearchTap ??
                  () {
                    // Handle search
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Search functionality coming soon')),
                    );
                  },
              tooltip: 'Search',
            ),
          ]);
        } else if (currentRoute == '/ai-chat-screen') {
          actionWidgets.add(
            IconButton(
              icon: const Icon(Icons.more_vert, size: 24),
              onPressed: () {
                // Show chat options
                _showChatOptions(context);
              },
              tooltip: 'More options',
            ),
          );
        }
        break;
      case CustomAppBarVariant.withSearch:
        actionWidgets.add(
          IconButton(
            icon: const Icon(Icons.tune, size: 24),
            onPressed: () {
              // Handle search filters
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search filters coming soon')),
              );
            },
            tooltip: 'Search filters',
          ),
        );
        break;
      default:
        break;
    }

    // Add custom actions if provided
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('New Chat'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting new chat...')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Chat History'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat history coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Chat Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat settings coming soon')),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
