import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/data/datasource/model/item_image_model.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class FullscreenGallery extends StatefulWidget {
  final List<ItemImageModel> images;
  final int initialIndex;
  final String? heroPrefix;

  const FullscreenGallery(
      {super.key,
      required this.images,
      required this.initialIndex,
      this.heroPrefix});

  @override
  State<FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<FullscreenGallery> {
  late PageController _pageController;
  late List<_ImageStatus> _statuses;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _statuses =
        List.generate(widget.images.length, (_) => _ImageStatus.loading);

    // Pre-check initial and neighbor images
    _checkImageAt(_currentIndex);
    if (_currentIndex + 1 < widget.images.length)
      _checkImageAt(_currentIndex + 1);
    if (_currentIndex - 1 >= 0) _checkImageAt(_currentIndex - 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _checkImageAt(int index) async {
    final img = widget.images[index];
    final candidates = AppImageUrls.item(img.imgPath);
    final url = candidates.isNotEmpty ? candidates.first : '';

    setState(() => _statuses[index] = _ImageStatus.loading);

    try {
      final uri = Uri.parse(url);
      if (!uri.isAbsolute || (uri.scheme != 'http' && uri.scheme != 'https')) {
        setState(() => _statuses[index] = _ImageStatus.invalid);
        return;
      }

      final client = HttpClient();
      final request = await client.headUrl(uri);
      final response = await request.close();
      final contentType = response.headers.contentType?.mimeType ?? '';

      if (response.statusCode == 200 && contentType.startsWith('image/')) {
        setState(() => _statuses[index] = _ImageStatus.ok);
      } else {
        setState(() => _statuses[index] = _ImageStatus.invalid);
      }
      client.close();
    } catch (e) {
      setState(() => _statuses[index] = _ImageStatus.invalid);
    }
  }

  Widget _buildPlaceholder(int index) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 64, color: Colors.white70),
          const SizedBox(height: 12),
          const Text('Unable to load image',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          ElevatedButton(
              onPressed: () => _checkImageAt(index), child: const Text('Retry'))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('${_currentIndex + 1}/${widget.images.length}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (i) {
          setState(() => _currentIndex = i);
          // start checking neighbor images for smoother UX
          if (i + 1 < widget.images.length &&
              _statuses[i + 1] == _ImageStatus.loading) _checkImageAt(i + 1);
          if (i - 1 >= 0 && _statuses[i - 1] == _ImageStatus.loading)
            _checkImageAt(i - 1);
        },
        itemBuilder: (context, index) {
          final img = widget.images[index];
          final urls = AppImageUrls.item(img.imgPath);

          final status = _statuses[index];
          if (status != _ImageStatus.ok) {
            if (status == _ImageStatus.loading) _checkImageAt(index);
            return _buildPlaceholder(index);
          }

          if (img.imgType == '360') {
            // تم حذف عارض البانوراما panorama لعدم التوافق
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, color: Colors.yellow, size: 48),
                  SizedBox(height: 16),
                  Text('عرض صورة 360 غير مدعوم حالياً',
                      style: TextStyle(color: Colors.white)),
                  SizedBox(height: 16),
                  FallbackNetworkImage(
                    imageUrls: urls,
                    fit: BoxFit.contain,
                    placeholder:
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: const Center(
                      child: Icon(Icons.broken_image, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          // Normal image - use PhotoView for zoom/pan (with hero if available)
          return PhotoView.customChild(
            heroAttributes: widget.heroPrefix != null
                ? PhotoViewHeroAttributes(tag: '${widget.heroPrefix}_$index')
                : null,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            child: FallbackNetworkImage(
              imageUrls: urls,
              fit: BoxFit.contain,
              placeholder: const Center(child: CircularProgressIndicator()),
              errorWidget: const Center(
                child: Icon(Icons.broken_image, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _ImageStatus { loading, ok, invalid }
