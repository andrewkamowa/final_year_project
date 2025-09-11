import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum MessageType { user, ai }

class ChatMessageWidget extends StatelessWidget {
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final bool showTimestamp;
  final VoidCallback? onThumbsUp;
  final VoidCallback? onThumbsDown;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.type,
    required this.timestamp,
    this.showTimestamp = true,
    this.onThumbsUp,
    this.onThumbsDown,
    this.onCopy,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = type == MessageType.user;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser) ...[
                _buildAvatarWidget(theme),
                SizedBox(width: 2.w),
              ],
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageOptions(context),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 75.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isUser
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.w),
                        topRight: Radius.circular(4.w),
                        bottomLeft: Radius.circular(isUser ? 4.w : 1.w),
                        bottomRight: Radius.circular(isUser ? 1.w : 4.w),
                      ),
                      border: !isUser
                          ? Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              width: 1,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color:
                              theme.colorScheme.shadow.withValues(alpha: 0.08),
                          offset: Offset(0, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Text(
                      message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            isUser ? Colors.white : theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                SizedBox(width: 2.w),
                _buildUserAvatarWidget(theme),
              ],
            ],
          ),
          if (showTimestamp) ...[
            SizedBox(height: 0.5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isUser ? 0 : 12.w),
              child: Text(
                _formatTimestamp(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 10.sp,
                ),
              ),
            ),
          ],
          if (!isUser && (onThumbsUp != null || onThumbsDown != null)) ...[
            SizedBox(height: 1.h),
            Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: _buildReactionButtons(theme),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(ThemeData theme) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: CustomIconWidget(
        iconName: 'smart_toy',
        color: theme.colorScheme.primary,
        size: 4.w,
      ),
    );
  }

  Widget _buildUserAvatarWidget(ThemeData theme) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.secondary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: CustomIconWidget(
        iconName: 'person',
        color: theme.colorScheme.secondary,
        size: 4.w,
      ),
    );
  }

  Widget _buildReactionButtons(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onThumbsUp != null)
          GestureDetector(
            onTap: onThumbsUp,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'thumb_up_outlined',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 3.w,
              ),
            ),
          ),
        if (onThumbsUp != null && onThumbsDown != null) SizedBox(width: 2.w),
        if (onThumbsDown != null)
          GestureDetector(
            onTap: onThumbsDown,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'thumb_down_outlined',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 3.w,
              ),
            ),
          ),
      ],
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(0.25.h),
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'copy',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text(
                'Copy Message',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Message copied to clipboard')),
                );
                onCopy?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.onSurface,
                size: 6.w,
              ),
              title: Text(
                'Share Message',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
