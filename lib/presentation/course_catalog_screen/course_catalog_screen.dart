import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/auth_service.dart';
import '../../services/finlearn_database_service.dart';
import '../../models/course_model.dart';
import '../../models/enrollment_model.dart';
import './widgets/course_card.dart';
import './widgets/course_filter_chips.dart';
import './widgets/empty_search_state.dart';
import './widgets/recent_searches_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sort_filter_bottom_sheet.dart';

class CourseCatalogScreen extends StatefulWidget {
  const CourseCatalogScreen({super.key});

  @override
  State<CourseCatalogScreen> createState() => _CourseCatalogScreenState();
}

class _CourseCatalogScreenState extends State<CourseCatalogScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _selectedCategory = 'All Courses';
  String _searchQuery = '';
  String _currentSort = 'Newest';
  List<String> _selectedFilters = [];
  List<String> _recentSearches = [];
  bool _isSearchFocused = false;
  bool _isLoading = false;

  // Data from Supabase
  List<CourseModel> _allCourses = [];
  List<EnrollmentModel> _enrollments = [];

  final List<String> _categories = [
    'All Courses',
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _loadCourses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = AuthService.instance.currentUserId;

      // Load courses and enrollments in parallel
      final futures = await Future.wait([
        FinLearnDatabaseService.instance.getCourses(
          difficulty:
              _selectedCategory != 'All Courses' ? _selectedCategory : null,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
          sortBy: _currentSort,
        ),
        userId != null
            ? FinLearnDatabaseService.instance.getUserEnrollments(userId)
            : Future.value(<EnrollmentModel>[]),
      ]);

      if (mounted) {
        setState(() {
          _allCourses = futures[0] as List<CourseModel>;
          _enrollments = futures[1] as List<EnrollmentModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading courses: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredCourses {
    return _allCourses.map((course) {
      final enrollment = _enrollments.firstWhere(
        (e) => e.courseId == course.id,
        orElse: () => EnrollmentModel(
          id: '',
          userId: '',
          courseId: course.id,
          progress: 0.0,
          isCompleted: false,
          isBookmarked: false,
          enrolledAt: DateTime.now(),
        ),
      );

      return {
        "id": course.id,
        "title": course.title,
        "instructor": course.instructorName ?? 'Unknown',
        "difficulty": course.difficulty,
        "duration": course.duration,
        "rating": course.rating,
        "reviewCount": course.reviewCount,
        "contentType": course.contentType,
        "thumbnail": course.thumbnailUrl ??
            'https://images.unsplash.com/photo-1554224155-6726b3ff858f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
        "isEnrolled": enrollment.userId.isNotEmpty,
        "progress": enrollment.progress,
        "isBookmarked": enrollment.isBookmarked,
        "topics": course.topics,
        "price": course.price ?? 'Free',
      };
    }).toList();
  }

  void _loadRecentSearches() {
    // Mock recent searches - in real app, load from SharedPreferences
    setState(() {
      _recentSearches = [
        'Investment basics',
        'Budgeting tips',
        'Retirement planning',
      ];
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Debounce search to avoid too many API calls
    Future.delayed(Duration(milliseconds: 500), () {
      if (_searchQuery == query) {
        _loadCourses();
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _addToRecentSearches(query.trim());
      setState(() {
        _searchQuery = query.trim();
        _isSearchFocused = false;
      });
      FocusScope.of(context).unfocus();
      _loadCourses();
    }
  }

  void _addToRecentSearches(String search) {
    setState(() {
      _recentSearches.remove(search);
      _recentSearches.insert(0, search);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
  }

  void _removeFromRecentSearches(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _onVoiceSearch() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Voice search coming soon!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onCourseCardTap(Map<String, dynamic> course) {
    HapticFeedback.selectionClick();
    // Navigate to course detail with shared element transition
    Fluttertoast.showToast(
      msg: "Opening ${course['title']}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Future<void> _onBookmarkTap(Map<String, dynamic> course) async {
    try {
      final userId = AuthService.instance.currentUserId;
      if (userId == null) {
        Fluttertoast.showToast(msg: "Please sign in to bookmark courses");
        return;
      }

      HapticFeedback.lightImpact();

      // Check if enrolled, enroll if not
      if (!(course['isEnrolled'] as bool)) {
        await FinLearnDatabaseService.instance
            .enrollInCourse(userId, course['id']);
      }

      // Toggle bookmark
      final enrollment = await FinLearnDatabaseService.instance
          .toggleBookmark(userId, course['id']);

      if (enrollment != null) {
        setState(() {
          course['isBookmarked'] = enrollment.isBookmarked;
          course['isEnrolled'] = true;
        });

        Fluttertoast.showToast(
          msg: enrollment.isBookmarked
              ? "Course bookmarked!"
              : "Bookmark removed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error updating bookmark: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _onShareTap(Map<String, dynamic> course) {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Sharing ${course['title']}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onPreviewTap(Map<String, dynamic> course) {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Playing preview for ${course['title']}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showSortFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortFilterBottomSheet(
        currentSortBy: _currentSort,
        selectedFilters: _selectedFilters,
        onSortChanged: (sort) {
          setState(() {
            _currentSort = sort;
          });
          _loadCourses();
        },
        onFiltersChanged: (filters) {
          setState(() {
            _selectedFilters = filters;
          });
          _loadCourses();
        },
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _loadCourses();

    Fluttertoast.showToast(
      msg: "Course catalog updated!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCourses = _filteredCourses;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Course Catalog',
        variant: CustomAppBarVariant.withActions,
        actions: [
          IconButton(
            onPressed: _showSortFilterBottomSheet,
            icon: Stack(
              children: [
                CustomIconWidget(
                  iconName: 'tune',
                  size: 24,
                  color: theme.colorScheme.onSurface,
                ),
                if (_selectedFilters.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Sort & Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          SearchBarWidget(
            controller: _searchController,
            hintText: 'Search courses, instructors...',
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            onVoiceSearch: _onVoiceSearch,
            showVoiceIcon: true,
          ),

          // Filter chips
          CourseFilterChips(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
              _loadCourses();
            },
          ),

          // Main content
          Expanded(
            child: _isSearchFocused && _searchQuery.isEmpty
                ? RecentSearchesWidget(
                    recentSearches: _recentSearches,
                    onSearchTap: (search) {
                      _searchController.text = search;
                      _onSearchSubmitted(search);
                    },
                    onSearchRemove: _removeFromRecentSearches,
                  )
                : _searchQuery.isNotEmpty && filteredCourses.isEmpty
                    ? EmptySearchState(
                        searchQuery: _searchQuery,
                        onClearSearch: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadCourses();
                        },
                        onSuggestionTap: (suggestion) {
                          _searchController.text = suggestion;
                          _onSearchSubmitted(suggestion);
                        },
                      )
                    : _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: filteredCourses.length + 1,
                              itemBuilder: (context, index) {
                                if (index == filteredCourses.length) {
                                  // Bottom padding
                                  return SizedBox(height: 10.h);
                                }

                                final course = filteredCourses[index];
                                return CourseCard(
                                  course: course,
                                  onTap: () => _onCourseCardTap(course),
                                  onBookmark: () => _onBookmarkTap(course),
                                  onShare: () => _onShareTap(course),
                                  onPreview: () => _onPreviewTap(course),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex: 1, // Courses tab
        variant: CustomBottomBarVariant.standard,
      ),
      floatingActionButton:
          _searchQuery.isNotEmpty || _selectedFilters.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedFilters.clear();
                      _selectedCategory = 'All Courses';
                    });
                    _loadCourses();
                  },
                  icon: CustomIconWidget(
                    iconName: 'clear_all',
                    size: 20,
                    color: Colors.white,
                  ),
                  label: const Text('Clear All'),
                  backgroundColor: theme.colorScheme.secondary,
                )
              : null,
    );
  }
}
