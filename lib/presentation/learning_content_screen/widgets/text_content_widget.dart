import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TextContentWidget extends StatefulWidget {
  final String content;
  final Function(double) onProgressUpdate;
  final double initialProgress;

  const TextContentWidget({
    Key? key,
    required this.content,
    required this.onProgressUpdate,
    this.initialProgress = 0.0,
  }) : super(key: key);

  @override
  State<TextContentWidget> createState() => _TextContentWidgetState();
}

class _TextContentWidgetState extends State<TextContentWidget> {
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 16.0;
  bool _isDarkMode = false;
  final List<String> _highlights = [];
  String _selectedText = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Set initial scroll position based on progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialProgress > 0) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetScroll = maxScroll * widget.initialProgress;
        _scrollController.jumpTo(targetScroll);
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      if (maxScroll > 0) {
        final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        widget.onProgressUpdate(progress);
      }
    }
  }

  void _increaseFontSize() {
    setState(() {
      _fontSize = (_fontSize + 2).clamp(12.0, 24.0);
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _fontSize = (_fontSize - 2).clamp(12.0, 24.0);
    });
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _highlightText() {
    if (_selectedText.isNotEmpty && !_highlights.contains(_selectedText)) {
      setState(() {
        _highlights.add(_selectedText);
        _selectedText = '';
      });
    }
  }

  Widget _buildHighlightedText(String text) {
    if (_highlights.isEmpty) {
      return Text(
        text,
        style: TextStyle(
          fontSize: _fontSize,
          height: 1.6,
          color: _isDarkMode
              ? Colors.white
              : AppTheme.lightTheme.colorScheme.onSurface,
        ),
      );
    }

    List<TextSpan> spans = [];
    String remainingText = text;

    while (remainingText.isNotEmpty) {
      String? foundHighlight;
      int earliestIndex = remainingText.length;

      // Find the earliest highlight in the remaining text
      for (String highlight in _highlights) {
        int index = remainingText.indexOf(highlight);
        if (index != -1 && index < earliestIndex) {
          earliestIndex = index;
          foundHighlight = highlight;
        }
      }

      if (foundHighlight != null && earliestIndex < remainingText.length) {
        // Add text before highlight
        if (earliestIndex > 0) {
          spans.add(TextSpan(
            text: remainingText.substring(0, earliestIndex),
            style: TextStyle(
              fontSize: _fontSize,
              height: 1.6,
              color: _isDarkMode
                  ? Colors.white
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ));
        }

        // Add highlighted text
        spans.add(TextSpan(
          text: foundHighlight,
          style: TextStyle(
            fontSize: _fontSize,
            height: 1.6,
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary
                .withValues(alpha: 0.3),
            color: _isDarkMode
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ));

        remainingText =
            remainingText.substring(earliestIndex + foundHighlight.length);
      } else {
        // Add remaining text
        spans.add(TextSpan(
          text: remainingText,
          style: TextStyle(
            fontSize: _fontSize,
            height: 1.6,
            color: _isDarkMode
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ));
        break;
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode
            ? Colors.grey[900]
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Control bar
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: _isDarkMode
                  ? Colors.grey[800]
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _decreaseFontSize,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'text_decrease',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '${_fontSize.toInt()}',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: _isDarkMode ? Colors.white : null,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: _increaseFontSize,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'text_increase',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_selectedText.isNotEmpty)
                      GestureDetector(
                        onTap: _highlightText,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: CustomIconWidget(
                            iconName: 'highlight',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 20,
                          ),
                        ),
                      ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: _toggleDarkMode,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? Colors.yellow.withValues(alpha: 0.2)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: _isDarkMode ? 'light_mode' : 'dark_mode',
                          color:
                              _isDarkMode ? Colors.yellow : Colors.grey[700]!,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(4.w),
              child: SelectableText.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.content,
                      style: TextStyle(
                        fontSize: _fontSize,
                        height: 1.6,
                        color: _isDarkMode
                            ? Colors.white
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                onSelectionChanged: (selection, cause) {
                  if (selection.baseOffset != selection.extentOffset) {
                    setState(() {
                      _selectedText = widget.content.substring(
                        selection.baseOffset,
                        selection.extentOffset,
                      );
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
