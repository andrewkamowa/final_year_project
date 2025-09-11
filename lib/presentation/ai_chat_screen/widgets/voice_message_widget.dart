import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String audioPath;
  final bool isUser;
  final Duration duration;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;

  const VoiceMessageWidget({
    super.key,
    required this.audioPath,
    required this.isUser,
    required this.duration,
    this.onPlay,
    this.onPause,
  });

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  late PlayerController _playerController;
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _initializePlayer();
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() => _isLoading = true);
      await _playerController.preparePlayer(
        path: widget.audioPath,
        shouldExtractWaveform: true,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load audio')),
      );
    }
  }

  Future<void> _togglePlayback() async {
    try {
      if (_isPlaying) {
        await _playerController.pausePlayer();
        widget.onPause?.call();
      } else {
        await _playerController.startPlayer();
        widget.onPlay?.call();
      }
      setState(() => _isPlaying = !_isPlaying);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playback error')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment:
            widget.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isUser) ...[
            _buildAvatarWidget(theme),
            SizedBox(width: 2.w),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: 75.w),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: widget.isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4.w),
                topRight: Radius.circular(4.w),
                bottomLeft: Radius.circular(widget.isUser ? 4.w : 1.w),
                bottomRight: Radius.circular(widget.isUser ? 1.w : 4.w),
              ),
              border: !widget.isUser
                  ? Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _isLoading ? null : _togglePlayback,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: widget.isUser
                          ? Colors.white.withValues(alpha: 0.2)
                          : theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.isUser
                                    ? Colors.white
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: _isPlaying ? 'pause' : 'play_arrow',
                            color: widget.isUser
                                ? Colors.white
                                : theme.colorScheme.primary,
                            size: 4.w,
                          ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_isLoading)
                        AudioFileWaveforms(
                          size: Size(40.w, 6.w),
                          playerController: _playerController,
                          waveformType: WaveformType.fitWidth,
                          playerWaveStyle: PlayerWaveStyle(
                            fixedWaveColor: widget.isUser
                                ? Colors.white.withValues(alpha: 0.3)
                                : theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                            liveWaveColor: widget.isUser
                                ? Colors.white
                                : theme.colorScheme.primary,
                            spacing: 6,
                          ),
                        )
                      else
                        Container(
                          width: 40.w,
                          height: 6.w,
                          child: Row(
                            children: List.generate(20, (index) {
                              return Container(
                                width: 1.w,
                                height: (index % 3 + 1) * 2.w,
                                margin: EdgeInsets.symmetric(horizontal: 0.5.w),
                                decoration: BoxDecoration(
                                  color: widget.isUser
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : theme.colorScheme.outline
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(0.5.w),
                                ),
                              );
                            }),
                          ),
                        ),
                      SizedBox(height: 1.h),
                      Text(
                        _formatDuration(widget.duration),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.isUser
                              ? Colors.white.withValues(alpha: 0.8)
                              : theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.isUser) ...[
            SizedBox(width: 2.w),
            _buildUserAvatarWidget(theme),
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
}