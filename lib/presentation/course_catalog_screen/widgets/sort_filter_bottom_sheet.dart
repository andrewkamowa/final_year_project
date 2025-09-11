import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SortFilterBottomSheet extends StatefulWidget {
  final String currentSortBy;
  final List<String> selectedFilters;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<List<String>> onFiltersChanged;

  const SortFilterBottomSheet({
    super.key,
    required this.currentSortBy,
    required this.selectedFilters,
    required this.onSortChanged,
    required this.onFiltersChanged,
  });

  @override
  State<SortFilterBottomSheet> createState() => _SortFilterBottomSheetState();
}

class _SortFilterBottomSheetState extends State<SortFilterBottomSheet> {
  late String _selectedSort;
  late List<String> _selectedFilters;

  final List<String> _sortOptions = [
    'Newest',
    'Popular',
    'Rating',
    'Duration (Short)',
    'Duration (Long)',
    'A-Z',
    'Z-A',
  ];

  final Map<String, List<String>> _filterCategories = {
    'Content Type': ['Video', 'Audio', 'Text', 'Interactive'],
    'Duration': ['< 1 hour', '1-3 hours', '3-6 hours', '6+ hours'],
    'Difficulty': ['Beginner', 'Semi-Pro', 'Pro', 'Expert'],
    'Topics': [
      'Budgeting',
      'Investing',
      'Retirement',
      'Taxes',
      'Insurance',
      'Real Estate'
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedSort = widget.currentSortBy;
    _selectedFilters = List.from(widget.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 2.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort & Filter',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSort = 'Newest';
                      _selectedFilters.clear();
                    });
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sort section
                  _buildSortSection(theme),
                  SizedBox(height: 3.h),
                  // Filter sections
                  ..._filterCategories.entries.map((entry) =>
                      _buildFilterSection(theme, entry.key, entry.value)),
                ],
              ),
            ),
          ),
          // Action buttons
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSortChanged(_selectedSort);
                      widget.onFiltersChanged(_selectedFilters);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Apply (${_selectedFilters.length})',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSortSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort by',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _sortOptions.map((option) {
            final isSelected = option == _selectedSort;
            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSort = option;
                  });
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFilterSection(
      ThemeData theme, String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = _selectedFilters.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedFilters.add(option);
                  } else {
                    _selectedFilters.remove(option);
                  }
                });
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.secondary,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 3.h),
      ],
    );
  }
}
