// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:tks/linkapi/linkapi.dart';
import 'package:video_player/video_player.dart';

class AdsCarousel extends StatefulWidget {
  const AdsCarousel({super.key});

  @override
  _AdsCarouselState createState() => _AdsCarouselState();
}

class _AdsCarouselState extends State<AdsCarousel> {
  static final List<String> _adEndpoints = [
    '${AppLink.server}/ads/ads2.php',
    '${AppLink.server}/ads/ads.php',
  ];

  final bool _enablePeriodicUpdate = true;
  final int _pollIntervalSeconds = 90;

  List<String> adMedia = [];
  List<String> adLinks = [];
  List<VideoPlayerController?> videoControllers = [];
  late PageController _pageController;
  Timer? _timer;
  Timer? _updateTimer;

  int _currentPage = 0;
  bool _isLoading = false;
  int _cacheBuster = 0;

  Future<void> fetchAdMedia({bool forceRefresh = false}) async {
    if (!mounted) return;
    if (_isLoading || (adMedia.isNotEmpty && !forceRefresh)) return;

    _isLoading = true;
    try {
      final data = await _fetchAdsFromAvailableEndpoint();
      if (data == null || !mounted) return;

      final nextMedia = data
          .map<String>((item) => _normalizeMediaUrl(item['image_url']))
          .where((url) => url.isNotEmpty)
          .toList();
      final nextLinks = data
          .map<String>(
            (item) => AppLink.normalizeUrl('${item['link_url'] ?? ''}'),
          )
          .toList();

      if (nextMedia.isEmpty) return;

      final hasSameMedia = _sameStringList(adMedia, nextMedia);
      final hasSameLinks = _sameStringList(adLinks, nextLinks);
      if (forceRefresh && hasSameMedia && hasSameLinks) {
        return;
      }

      final previousPage = _currentPage;
      final oldControllers = List<VideoPlayerController?>.from(videoControllers);
      final nextControllers = <VideoPlayerController?>[];

      for (var i = 0; i < nextMedia.length; i++) {
        final url = nextMedia[i];
        final oldIndex = adMedia.indexOf(url);
        if (_isVideo(url)) {
          if (oldIndex != -1 &&
              oldIndex < oldControllers.length &&
              oldControllers[oldIndex] != null) {
            nextControllers.add(oldControllers[oldIndex]);
            oldControllers[oldIndex] = null;
          } else {
            final controller = VideoPlayerController.networkUrl(Uri.parse(url));
            await controller.initialize();
            await controller.setVolume(0.0);
            controller.setLooping(true);
            nextControllers.add(controller);
          }
        } else {
          nextControllers.add(null);
        }
      }

      for (final controller in oldControllers) {
        controller?.dispose();
      }

      final nextPage = nextMedia.isEmpty
          ? 0
          : previousPage.clamp(0, nextMedia.length - 1);

      setState(() {
        adMedia = nextMedia;
        adLinks = nextLinks;
        videoControllers = nextControllers;
        _currentPage = nextPage;
      });

      if (mounted && _pageController.hasClients && nextPage != previousPage) {
        _pageController.jumpToPage(nextPage);
      }

      if (videoControllers.isNotEmpty &&
          _currentPage >= 0 &&
          _currentPage < videoControllers.length) {
        videoControllers[_currentPage]?.play();
      }

      _startAutoScrolling();
      _startPeriodicUpdateChecks();
    } catch (e) {
      debugPrint('Error loading ads: $e');
    } finally {
      _isLoading = false;
    }
  }

  bool _sameStringList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<List<dynamic>?> _fetchAdsFromAvailableEndpoint() async {
    for (final endpoint in _adEndpoints) {
      try {
        final response = await http.get(Uri.parse(endpoint));
        if (response.statusCode != 200) continue;

        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded;
        }
        if (decoded is Map<String, dynamic> && decoded['data'] is List) {
          return decoded['data'] as List<dynamic>;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.webm');
  }

  String _normalizeMediaUrl(dynamic rawUrl) {
    final value = '${rawUrl ?? ''}'.trim();
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return AppLink.normalizeUrl(value);
    }

    return AppLink.normalizeUrl('${AppLink.server}/$value');
  }

  void _startAutoScrolling() {
    _timer?.cancel();
    if (adMedia.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 8), (timer) async {
      if (videoControllers.isNotEmpty &&
          _currentPage >= 0 &&
          _currentPage < videoControllers.length) {
        videoControllers[_currentPage]?.pause();
      }

      _currentPage = (_currentPage + 1) % adMedia.length;

      if (mounted) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
        );
      }

      if (videoControllers.isNotEmpty &&
          _currentPage >= 0 &&
          _currentPage < videoControllers.length) {
        videoControllers[_currentPage]?.play();
      }
    });
  }

  void _startPeriodicUpdateChecks() {
    if (!_enablePeriodicUpdate) return;
    _updateTimer?.cancel();
    if (adMedia.isEmpty) return;

    _updateTimer = Timer.periodic(
      Duration(seconds: _pollIntervalSeconds),
      (timer) async => fetchAdMedia(forceRefresh: true),
    );
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    fetchAdMedia();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _updateTimer?.cancel();
    _pageController.dispose();
    for (final controller in videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  Widget _buildMediaItem(String url, int index) {
    if (_isVideo(url)) {
      final controller = videoControllers[index];
      if (controller == null || !controller.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      );
    }

    final displayUrl = _cacheBuster > 0
        ? '$url${url.contains('?') ? '&' : '?'}v=$_cacheBuster'
        : url;

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final targetWidth = (constraints.maxWidth * dpr).round().clamp(1, 4096);
        final targetHeight =
            (constraints.maxHeight * dpr).round().clamp(1, 4096);

        final provider = ResizeImage(
          NetworkImage(displayUrl),
          width: targetWidth,
          height: targetHeight,
        );

        return Image(
          image: provider,
          fit: BoxFit.cover,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final defaultHeight = 148.0;
    final maxHeight = math.min(defaultHeight, screen.height * 0.20);

    return adMedia.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              SizedBox(
                height: maxHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: adMedia.length,
                  onPageChanged: (index) {
                    if (!mounted) return;
                    setState(() => _currentPage = index);
                    for (var i = 0; i < videoControllers.length; i++) {
                      if (i == index) {
                        videoControllers[i]?.play();
                      } else {
                        videoControllers[i]?.pause();
                      }
                    }
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: GestureDetector(
                          onTap: () {
                            final url = adLinks[index];
                            if (url.isNotEmpty) {
                              debugPrint('Open: $url');
                            }
                          },
                          child: AnimatedOpacity(
                            opacity: _currentPage == index ? 1.0 : 0.8,
                            duration: const Duration(milliseconds: 400),
                            child: _buildMediaItem(adMedia[index], index),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(adMedia.length, (index) {
                  final active = _currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: active ? 22 : 10,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color.fromARGB(255, 0, 58, 61)
                          : Colors.grey.shade300.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ],
          );
  }
}
