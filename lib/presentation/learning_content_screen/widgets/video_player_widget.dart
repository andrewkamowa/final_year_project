import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../../core/app_export.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final Function(double) onProgressUpdate;
  final double initialProgress;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.onProgressUpdate,
    this.initialProgress = 0.0,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppTheme.lightTheme.primaryColor,
          handleColor: AppTheme.lightTheme.primaryColor,
          backgroundColor:
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          bufferedColor:
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.5),
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.lightTheme.primaryColor,
            ),
          ),
        ),
        autoInitialize: true,
      );

      // Seek to initial progress
      if (widget.initialProgress > 0) {
        final duration = _videoPlayerController!.value.duration;
        final position = Duration(
          milliseconds:
              (duration.inMilliseconds * widget.initialProgress).round(),
        );
        await _videoPlayerController!.seekTo(position);
      }

      // Listen to progress updates
      _videoPlayerController!.addListener(_onVideoProgress);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _onVideoProgress() {
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      final position = _videoPlayerController!.value.position;
      final duration = _videoPlayerController!.value.duration;

      if (duration.inMilliseconds > 0) {
        final progress = position.inMilliseconds / duration.inMilliseconds;
        widget.onProgressUpdate(progress.clamp(0.0, 1.0));
      }
    }
  }

  void _skipForward() {
    if (_videoPlayerController != null) {
      final currentPosition = _videoPlayerController!.value.position;
      final newPosition = currentPosition + const Duration(seconds: 10);
      final duration = _videoPlayerController!.value.duration;

      if (newPosition <= duration) {
        _videoPlayerController!.seekTo(newPosition);
      } else {
        _videoPlayerController!.seekTo(duration);
      }
    }
  }

  void _skipBackward() {
    if (_videoPlayerController != null) {
      final currentPosition = _videoPlayerController!.value.position;
      final newPosition = currentPosition - const Duration(seconds: 10);

      if (newPosition >= Duration.zero) {
        _videoPlayerController!.seekTo(newPosition);
      } else {
        _videoPlayerController!.seekTo(Duration.zero);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Unable to load video',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isInitialized = false;
                });
                _initializePlayer();
              },
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized) {
      return Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Chewie(controller: _chewieController!),
            Positioned(
              bottom: 60,
              left: 4.w,
              right: 4.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSkipButton(
                    icon: 'replay_10',
                    onTap: _skipBackward,
                  ),
                  _buildSkipButton(
                    icon: 'forward_10',
                    onTap: _skipForward,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_onVideoProgress);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}
