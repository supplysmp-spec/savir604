// lib/controler/video/video_controller.dart
import 'package:get/get.dart';
import 'package:tks/core/class/crud.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/model/video_model.dart';
import 'package:tks/data/datasource/remote/video/video_remote.dart';
import 'package:video_player/video_player.dart';

class VideoController extends GetxController {
  final Crud crud;
  late final VideoRemote remote;

  VideoController(this.crud) {
    remote = VideoRemote(crud);
  }

  var videos = <VideoModel>[].obs;
  var isLoading = false.obs;
  var currentIndex = 0.obs;
  final failedVideoIds = <int>{}.obs;

  final Map<int, VideoPlayerController> _playerMap = {};

  VideoPlayerController? getController(int videoId) => _playerMap[videoId];

  @override
  void onInit() {
    super.onInit();
    fetchVideos();
  }

  @override
  void onClose() {
    _playerMap.values.forEach((c) {
      try {
        c.dispose();
      } catch (_) {}
    });
    super.onClose();
  }

  Future<void> fetchVideos() async {
    isLoading.value = true;
    try {
      final int viewerId =
          Get.find<MyServices>().sharedPreferences.getInt('id') ?? 0;
      var list = await remote.fetchVideos(viewerId: viewerId);
      videos.assignAll(list);
    } catch (e) {
      print("fetchVideos error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initVideoPlayer(VideoModel video) async {
    if (_playerMap.containsKey(video.videoId)) return;
    final controller =
        VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
    _playerMap[video.videoId] = controller;
    try {
      await controller.initialize();
      await controller.setVolume(1.0);
      await controller.setLooping(true);
      failedVideoIds.remove(video.videoId);
    } catch (e) {
      failedVideoIds.add(video.videoId);
      try {
        await controller.dispose();
      } catch (_) {}
      _playerMap.remove(video.videoId);
      print("initVideoPlayer error for ${video.videoUrl}: $e");
    }
  }

  void play(int videoId) {
    var c = _playerMap[videoId];
    if (c == null) return;
    c.setVolume(1.0);
    c.play();
  }

  void pause(int videoId) {
    var c = _playerMap[videoId];
    if (c == null) return;
    c.setVolume(0.0);
    c.pause();
  }

  void pauseAll() {
    for (final controller in _playerMap.values) {
      try {
        controller.setVolume(0.0);
        controller.pause();
      } catch (_) {}
    }
  }

  void setCurrentIndex(int index) {
    currentIndex.value = index;
    pauseAll();
    if (index >= 0 && index < videos.length) {
      final current = videos[index];
      play(current.videoId);
    }
  }

  Future<bool?> toggleLike(VideoModel video, int userId) async {
    final bool previousLiked = video.isLiked;
    final int previousLikes = video.videoLikes;

    video.isLiked = !previousLiked;
    video.videoLikes = video.isLiked
        ? previousLikes + 1
        : (previousLikes - 1).clamp(0, 99999999);
    videos.refresh();

    try {
      final res = await remote.addLike(videoId: video.videoId, userId: userId);
      if (res['status'] == 'success') {
        final bool serverLiked = res['action'] == 'liked';
        video.isLiked = serverLiked;
        video.videoLikes = serverLiked
            ? (previousLiked ? previousLikes : previousLikes + 1)
            : (previousLiked
                ? (previousLikes - 1).clamp(0, 99999999)
                : previousLikes);
        videos.refresh();
        return video.isLiked;
      }

      video.isLiked = previousLiked;
      video.videoLikes = previousLikes;
      videos.refresh();
      final msg = (res['message'] ?? 'Failed to update like').toString();
      Get.snackbar('Error', msg);
    } catch (e) {
      video.isLiked = previousLiked;
      video.videoLikes = previousLikes;
      videos.refresh();
      print("toggleLike error $e");
    }
    return null;
  }

  Future<void> markView(VideoModel video, int? userId) async {
    try {
      await remote.increaseView(videoId: video.videoId, userId: userId);
      video.videoViews += 1;
      videos.refresh();
    } catch (e) {
      print("markView error $e");
    }
  }
}
