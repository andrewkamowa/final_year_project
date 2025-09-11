
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ChatInputWidget extends StatefulWidget {
  final Function(String) onSendMessage;
  final Function(String)? onVoiceMessage;
  final VoidCallback? onMicrophonePressed;

  const ChatInputWidget({
    super.key,
    required this.onSendMessage,
    this.onVoiceMessage,
    this.onMicrophonePressed,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  bool _hasText = false;
  String? _recordingPath;
  late AnimationController _recordingAnimationController;
  late Animation<double> _recordingAnimation;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);

    _recordingAnimationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _recordingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _recordingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _recordingAnimationController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _messageController.text.trim().isNotEmpty;
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _messageController.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      bool hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Microphone permission is required for voice messages')),
        );
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        String path;

        if (kIsWeb) {
          path = 'recording.wav';
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.wav),
            path: path,
          );
        } else {
          final dir = await getTemporaryDirectory();
          path =
              '${dir.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path,
          );
        }

        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });

        _recordingAnimationController.repeat(reverse: true);
        widget.onMicrophonePressed?.call();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording')),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      _recordingAnimationController.stop();
      _recordingAnimationController.reset();

      if (path != null && widget.onVoiceMessage != null) {
        widget.onVoiceMessage!(path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to stop recording')),
      );
    }
  }

  Future<bool> _requestMicrophonePermission() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          hintText: 'Ask me about budgeting, investing...',
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _recordingAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _isRecording ? _recordingAnimation.value : 1.0,
                          child: GestureDetector(
                            onTap: _toggleRecording,
                            child: Container(
                              margin: EdgeInsets.only(right: 2.w),
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: _isRecording
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: _isRecording ? 'stop' : 'mic',
                                color: _isRecording
                                    ? Colors.white
                                    : theme.colorScheme.primary,
                                size: 5.w,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: _hasText ? _sendMessage : null,
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: _hasText
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'send',
                  color: _hasText
                      ? Colors.white
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 5.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
