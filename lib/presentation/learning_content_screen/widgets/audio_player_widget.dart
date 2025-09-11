import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  final Function(double) onProgressUpdate;
  final double initialProgress;

  const AudioPlayerWidget({
    Key? key,
    required this.audioUrl,
    required this.onProgressUpdate,
    this.initialProgress = 0.0,
  }) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late PlayerController _playerController;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _playerController = PlayerController();

      await _playerController.preparePlayer(
        path: widget.audioUrl,
        shouldExtractWaveform: true,
      );

      _playerController.onPlayerStateChanged.listen((state) {
        setState(() {
          _isPlaying = state.isPlaying;
        });
      });

      _playerController.onCurrentDurationChanged.listen((duration) {
        setState(() {
          _position = Duration(milliseconds: duration);
        });

        if (_duration.inMilliseconds > 0) {
          final progress = _position.inMilliseconds / _duration.inMilliseconds;
          widget.onProgressUpdate(progress.clamp(0.0, 1.0));
        }
      });

      // Get the maximum duration after player is prepared
      final maxDuration = await _playerController.getDuration();
      setState(() {
        _duration = Duration(milliseconds: maxDuration);
      });

      // Seek to initial progress
      if (widget.initialProgress > 0) {
        final seekPosition = Duration(
          milliseconds:
              (_duration.inMilliseconds * widget.initialProgress).round(),
        );
        await _playerController.seekTo(seekPosition.inMilliseconds);
      }

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _playerController.pausePlayer();
      } else {
        await _playerController.startPlayer();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _seekTo(double value) async {
    try {
      final position =
          Duration(milliseconds: (value * _duration.inMilliseconds).round());
      await _playerController.seekTo(position.inMilliseconds);
    } catch (e) {
      // Handle error silently
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
    if (_hasError) {
      return Container(
        width: double.infinity,
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Unable to load audio',
              style: AppTheme.lightTheme.textTheme.bodyLarge,
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
        height: 40.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
          ),
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
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
        ),
      ),
      child: Column(
        children: [
          // Audio waveform
          Container(
            height: 20.h,
            width: double.infinity,
            child: AudioFileWaveforms(
              size: Size(double.infinity, 20.h),
              playerController: _playerController,
              waveformType: WaveformType.fitWidth,
              playerWaveStyle: PlayerWaveStyle(
                fixedWaveColor:
                    AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                liveWaveColor: AppTheme.lightTheme.primaryColor,
                spacing: 6,
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Play/Pause button
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: _isPlaying ? 'pause' : 'play_arrow',
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Progress slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.lightTheme.primaryColor,
              inactiveTrackColor:
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
              thumbColor: AppTheme.lightTheme.primaryColor,
              overlayColor:
                  AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _duration.inMilliseconds > 0
                  ? (_position.inMilliseconds / _duration.inMilliseconds)
                      .clamp(0.0, 1.0)
                  : 0.0,
              onChanged: _seekTo,
            ),
          ),

          // Time indicators
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
                Text(
                  _formatDuration(_duration),
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }
}