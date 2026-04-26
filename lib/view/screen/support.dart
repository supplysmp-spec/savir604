import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/linkapi/linkapi.dart';

class ComplaintScreen extends StatefulWidget {
  final int userId;

  const ComplaintScreen({super.key, required this.userId});

  @override
  State<ComplaintScreen> createState() => _ChatPageState();
}

class _ChatPageState extends State<ComplaintScreen> {
  List messages = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  bool isRecording = false;
  bool showEmojiPicker = false;

  final record = AudioRecorder();
  final player = AudioPlayer();
  Timer? refreshTimer;
  String? playingUrl;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  Future<void> getMessages() async {
    try {
      final res = await http.post(
        Uri.parse('${AppLink.server}/chat/get_messages.php'),
        body: {'user_id': widget.userId.toString()},
      );
      final data = jsonDecode(res.body);
      if (data['status'] == 'success') {
        setState(() => messages = data['data']);
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> sendMessage(String msg) async {
    if (msg.trim().isEmpty) return;
    setState(() => isLoading = true);
    try {
      await http.post(
        Uri.parse('${AppLink.server}/chat/send_message.php'),
        body: {
          'user_id': widget.userId.toString(),
          'sender_type': 'user',
          'message': msg,
        },
      );
      _controller.clear();
      await getMessages();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> startRecording() async {
    try {
      if (await record.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/record_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await record.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        setState(() => isRecording = true);
      }
    } catch (e) {
      debugPrint('Error starting record: $e');
    }
  }

  Future<void> stopRecording() async {
    final path = await record.stop();
    setState(() => isRecording = false);
    if (path != null) await sendAudio(File(path));
  }

  Future<void> sendAudio(File file) async {
    setState(() => isLoading = true);
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppLink.server}/chat/send_message.php'),
      );
      request.fields['user_id'] = widget.userId.toString();
      request.fields['sender_type'] = 'user';
      request.fields['message'] = '';
      request.files.add(await http.MultipartFile.fromPath('audio', file.path));
      final response = await request.send();
      if (response.statusCode == 200) {
        await getMessages();
      }
    } catch (e) {
      debugPrint('Error sending audio: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> playAudio(String url) async {
    try {
      if (playingUrl == url) {
        await player.pause();
        setState(() => playingUrl = null);
      } else {
        await player.stop();
        await player.play(UrlSource('${AppLink.server}/$url'));
        setState(() => playingUrl = url);
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void setupAudioListeners() {
    player.onPositionChanged.listen((value) {
      setState(() => position = value);
    });
    player.onDurationChanged.listen((value) {
      setState(() => duration = value);
    });
    player.onPlayerComplete.listen((_) {
      setState(() {
        position = Duration.zero;
        playingUrl = null;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getMessages();
    setupAudioListeners();
    refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      getMessages();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    player.dispose();
    record.dispose();
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration value) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(value.inMinutes)}:${twoDigits(value.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _ChatHeader(
              theme: theme,
              colors: colors,
              isDark: isDark,
              onBack: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.homepage,
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
            Expanded(
              child: messages.isEmpty
                  ? _EmptyConversation(theme: theme, colors: colors, isDark: isDark)
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isUser = msg['sender_type'] == 'user';
                        final audioUrl = (msg['audio_url'] ?? '').toString();
                        final timestamp = (msg['timestamp'] ?? '').toString();
                        final visibleTimestamp =
                            timestamp.length >= 16 ? timestamp.substring(0, 16) : timestamp;

                        return Column(
                          children: [
                            if (index == 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF262626)
                                        : const Color(0xFFF2ECE7),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Today',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurface.withValues(alpha: 0.65),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            _MessageBubble(
                              theme: theme,
                              colors: colors,
                              isDark: isDark,
                              isUser: isUser,
                              message: (msg['message'] ?? '').toString(),
                              audioUrl: audioUrl,
                              timestamp: visibleTimestamp,
                              playing: playingUrl == audioUrl,
                              sliderValue: playingUrl == audioUrl
                                  ? position.inMilliseconds.toDouble()
                                  : 0,
                              sliderMax: duration.inMilliseconds > 0
                                  ? duration.inMilliseconds.toDouble()
                                  : 1,
                              playbackText: playingUrl == audioUrl
                                  ? _formatDuration(position)
                                  : '00:00',
                              onPlayPause: audioUrl.isEmpty
                                  ? null
                                  : () => playAudio(audioUrl),
                              onSeek: audioUrl.isEmpty
                                  ? null
                                  : (value) async {
                                      await player.seek(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    },
                            ),
                          ],
                        );
                      },
                    ),
            ),
            _ChatComposer(
              theme: theme,
              colors: colors,
              isLoading: isLoading,
              isRecording: isRecording,
              showEmojiPicker: showEmojiPicker,
              controller: _controller,
              onToggleEmoji: () {
                FocusScope.of(context).unfocus();
                setState(() => showEmojiPicker = !showEmojiPicker);
              },
              onMicTap: isRecording ? stopRecording : startRecording,
              onSend: () => sendMessage(_controller.text),
            ),
            Offstage(
              offstage: !showEmojiPicker,
              child: SizedBox(
                height: 250,
                child: EmojiPicker(
                  textEditingController: _controller,
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    emojiViewConfig: EmojiViewConfig(
                      emojiSizeMax: 28,
                      columns: 7,
                      backgroundColor: theme.cardColor,
                    ),
                    skinToneConfig: const SkinToneConfig(enabled: true),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: theme.cardColor,
                      indicatorColor: colors.primary,
                      iconColor: theme.iconTheme.color ?? Colors.grey,
                      iconColorSelected: colors.primary,
                    ),
                    bottomActionBarConfig: BottomActionBarConfig(
                      enabled: true,
                      backgroundColor: theme.cardColor,
                    ),
                    searchViewConfig: SearchViewConfig(
                      backgroundColor: theme.cardColor,
                      hintText: 'ابحث عن إيموجي...',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colors;
  final bool isDark;
  final VoidCallback onBack;

  const _ChatHeader({
    required this.theme,
    required this.colors,
    required this.isDark,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151515) : const Color(0xFF171310),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF6E9CF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent_rounded,
                color: const Color(0xFF171310),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الدعم الفني',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'جاهزون لمساعدتك',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Online',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFF6E9CF),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyConversation extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colors;
  final bool isDark;

  const _EmptyConversation({
    required this.theme,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.7)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF242424) : const Color(0xFFF2F2ED),
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: colors.onSurface,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ابدأ المحادثة مع فريق الدعم',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'اكتب رسالتك وسنرد عليك في أقرب وقت ممكن.',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colors;
  final bool isDark;
  final bool isUser;
  final String message;
  final String audioUrl;
  final String timestamp;
  final bool playing;
  final double sliderValue;
  final double sliderMax;
  final String playbackText;
  final VoidCallback? onPlayPause;
  final ValueChanged<double>? onSeek;

  const _MessageBubble({
    required this.theme,
    required this.colors,
    required this.isDark,
    required this.isUser,
    required this.message,
    required this.audioUrl,
    required this.timestamp,
    required this.playing,
    required this.sliderValue,
    required this.sliderMax,
    required this.playbackText,
    required this.onPlayPause,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isUser
        ? (isDark ? const Color(0xFF222222) : const Color(0xFFF3F3F1))
        : (isDark ? const Color(0xFF2B261F) : const Color(0xFFF8EDC8));
    final textColor = isUser ? colors.onSurface : const Color(0xFF4E3F1B);
    final timeColor = isUser
        ? colors.onSurface.withValues(alpha: 0.46)
        : const Color(0xFF6B5B30);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 18),
          ),
          border: Border.all(
            color: isUser
                ? theme.dividerColor.withValues(alpha: 0.55)
                : const Color(0xFFF2E4B5).withValues(alpha: isDark ? 0.18 : 0.72),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (audioUrl.isNotEmpty)
              Row(
                children: [
                  InkWell(
                    onTap: onPlayPause,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isUser
                            ? colors.onSurface.withValues(alpha: 0.08)
                            : const Color(0xFFFFFFFF).withValues(alpha: isDark ? 0.10 : 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 4),
                        overlayShape:
                            const RoundSliderOverlayShape(overlayRadius: 10),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        value: sliderValue.clamp(0, sliderMax),
                        max: sliderMax <= 0 ? 1 : sliderMax,
                        onChanged: onSeek,
                        activeColor: textColor,
                        inactiveColor: textColor.withValues(alpha: 0.20),
                      ),
                    ),
                  ),
                  Text(
                    playbackText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: timeColor,
                    ),
                  ),
                ],
              )
            else
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  height: 1.45,
                ),
              ),
            const SizedBox(height: 6),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                timestamp,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: timeColor,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  final ThemeData theme;
  final ColorScheme colors;
  final bool isLoading;
  final bool isRecording;
  final bool showEmojiPicker;
  final TextEditingController controller;
  final VoidCallback onToggleEmoji;
  final VoidCallback onMicTap;
  final VoidCallback onSend;

  const _ChatComposer({
    required this.theme,
    required this.colors,
    required this.isLoading,
    required this.isRecording,
    required this.showEmojiPicker,
    required this.controller,
    required this.onToggleEmoji,
    required this.onMicTap,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.7)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _ComposerButton(
              icon: showEmojiPicker ? Icons.keyboard_rounded : Icons.mood_rounded,
              onTap: onToggleEmoji,
              foreground: colors.onSurface.withValues(alpha: 0.72),
              background: isDark ? const Color(0xFF242424) : const Color(0xFFF1F1EC),
            ),
            const SizedBox(width: 8),
            _ComposerButton(
              icon: isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
              onTap: onMicTap,
              foreground: isRecording ? Colors.white : colors.onSurface,
              background: isRecording
                  ? const Color(0xFFD63B3B)
                  : (isDark ? const Color(0xFF242424) : const Color(0xFFF1F1EC)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: Color(0xFFD6B878),
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  filled: true,
                  fillColor: const Color(0xFF090909),
                  hintStyle: const TextStyle(
                    color: Color(0xFFB89B5E),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFD6B878)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFD6B878)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(color: Color(0xFFD6B878)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: isLoading ? null : onSend,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF090909),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD6B878)),
                ),
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.all(13),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color(0xFFD6B878),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Color(0xFFD6B878),
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color foreground;
  final Color background;

  const _ComposerButton({
    required this.icon,
    required this.onTap,
    required this.foreground,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: foreground, size: 20),
      ),
    );
  }
}

class SupportHome extends StatelessWidget {
  final int userId;

  const SupportHome({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ChatHeader(
              theme: theme,
              colors: theme.colorScheme,
              isDark: isDark,
              onBack: () => Get.back(),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () {
                Get.to(() => ComplaintScreen(userId: userId));
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF242424) : const Color(0xFFF2F2ED),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ابدأ محادثة جديدة',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'تواصل مع فريق الدعم بشكل مباشر وهادئ.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
