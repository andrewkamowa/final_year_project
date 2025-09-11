import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final Function(String, String?) onAddNote;
  final Function(int) onDeleteNote;

  const NotesWidget({
    Key? key,
    required this.notes,
    required this.onAddNote,
    required this.onDeleteNote,
  }) : super(key: key);

  @override
  State<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends State<NotesWidget> {
  final TextEditingController _noteController = TextEditingController();
  bool _isExpanded = false;

  void _addNote() {
    if (_noteController.text.trim().isNotEmpty) {
      widget.onAddNote(_noteController.text.trim(), null);
      _noteController.clear();
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final time = DateTime.parse(timestamp);
      final minutes = time.minute.toString().padLeft(2, '0');
      final seconds = time.second.toString().padLeft(2, '0');
      return '${time.hour}:$minutes:$seconds';
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: _isExpanded ? Radius.zero : Radius.circular(12),
                  bottomRight: _isExpanded ? Radius.zero : Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'note_alt',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Notes (${widget.notes.length})',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: _isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            // Add note section
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppTheme.lightTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _addNote,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                      ),
                      child: Text('Add Note'),
                    ),
                  ),
                ],
              ),
            ),

            // Notes list
            if (widget.notes.isNotEmpty) ...[
              Container(
                constraints: BoxConstraints(maxHeight: 40.h),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: widget.notes.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                  itemBuilder: (context, index) {
                    final note = widget.notes[index];
                    return Container(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note['content'] as String,
                                  style:
                                      AppTheme.lightTheme.textTheme.bodyMedium,
                                ),
                                if (note['timestamp'] != null) ...[
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'access_time',
                                        color: AppTheme.lightTheme.colorScheme
                                            .onSurfaceVariant,
                                        size: 14,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        _formatTimestamp(
                                            note['timestamp'] as String?),
                                        style: AppTheme
                                            .lightTheme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: AppTheme.lightTheme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => widget.onDeleteNote(index),
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              child: CustomIconWidget(
                                iconName: 'delete_outline',
                                color: AppTheme.lightTheme.colorScheme.error,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 2.h),
            ] else ...[
              Container(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'note_add',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'No notes yet',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Add your first note above',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }
}
