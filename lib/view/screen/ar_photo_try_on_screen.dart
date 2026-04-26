import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tks/linkapi/linkapi.dart';

class ArPhotoTryOnScreen extends StatefulWidget {
  final String itemId;
  final String? variantId;
  final String title;

  const ArPhotoTryOnScreen({
    super.key,
    required this.itemId,
    required this.title,
    this.variantId,
  });

  @override
  State<ArPhotoTryOnScreen> createState() => _ArPhotoTryOnScreenState();
}

class _ArPhotoTryOnScreenState extends State<ArPhotoTryOnScreen> {
  final ImagePicker _picker = ImagePicker();
  static const MethodChannel _galleryChannel =
      MethodChannel('com.example.savirv603/gallery');

  XFile? _selectedImage;
  ui.Image? _photoImage;
  ui.Image? _frameImage;
  _PhotoTryOnPose? _pose;
  bool _loading = false;
  bool _saving = false;
  String? _error;

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  Uri get _configUri {
    final query = <String, String>{'itemid': widget.itemId};
    if ((widget.variantId ?? '').trim().isNotEmpty) {
      query['variantid'] = widget.variantId!.trim();
    }
    return Uri.parse('${AppLink.server}/ar/config.php').replace(
      queryParameters: query,
    );
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    setState(() {
      _selectedImage = picked;
      _photoImage = null;
      _frameImage = null;
      _pose = null;
      _error = null;
    });
  }

  Future<void> _generate() async {
    if (_selectedImage == null) {
      setState(() {
        _error = _isArabic
            ? 'اختر صورة من الاستوديو اولا.'
            : 'Choose a photo from the gallery first.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final config = await _fetchConfig();
      final photoBytes = await File(_selectedImage!.path).readAsBytes();
      final frameResponse = await http.get(Uri.parse(config.overlayUrl));
      if (frameResponse.statusCode != 200) {
        throw Exception('Failed to load frame image');
      }

      final photoImage = await _decodeUiImage(photoBytes);
      final frameImage = await _decodeUiImage(frameResponse.bodyBytes);
      final pose = await _detectFacePose(_selectedImage!.path, config);

      if (!mounted) return;
      setState(() {
        _photoImage = photoImage;
        _frameImage = frameImage;
        _pose = pose;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _isArabic
            ? 'تعذر توليد الصورة حاليا. تاكد من وجود صورة فريم صحيحة ووجه واضح.'
            : 'Could not generate the try-on image. Make sure the frame and face photo are clear.';
      });
    }
  }

  Future<void> _saveResult() async {
    if (_photoImage == null || _frameImage == null || _pose == null) {
      setState(() {
        _error = _isArabic
            ? 'ولد النتيجة اولا قبل الحفظ.'
            : 'Generate the result before saving.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (Platform.isIOS) {
        final status = await Permission.photosAddOnly.request();
        if (!status.isGranted && !status.isLimited) {
          throw Exception('Gallery permission denied');
        }
      }

      final bytes = await _renderResultBytes();
      final fileName = 'tks_try_on_${DateTime.now().millisecondsSinceEpoch}.png';
      final saved = await _saveImageToGallery(
        bytes: bytes,
        fileName: fileName,
      );
      if (!saved) {
        throw Exception('Save failed');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isArabic ? 'تم حفظ الصورة في الاستوديو.' : 'Image saved to gallery.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _isArabic
            ? 'تعذر حفظ الصورة حاليا: ${e.toString()}'
            : 'Could not save the image right now: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<Uint8List> _renderResultBytes() async {
    final photoImage = _photoImage!;
    final frameImage = _frameImage!;
    final pose = _pose!;
    final sourceRect = _buildFocusedSourceRect(
      imageWidth: photoImage.width.toDouble(),
      imageHeight: photoImage.height.toDouble(),
      pose: pose,
    );

    final outputWidth = sourceRect.width.round().clamp(1, 2048).toInt();
    final outputHeight = sourceRect.height.round().clamp(1, 2048).toInt();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(outputWidth.toDouble(), outputHeight.toDouble());

    _paintPhotoTryOn(
      canvas: canvas,
      size: size,
      photoImage: photoImage,
      frameImage: frameImage,
      pose: pose,
      sourceRect: sourceRect,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(outputWidth, outputHeight);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Byte conversion failed');
    }
    return byteData.buffer.asUint8List();
  }

  Future<bool> _saveImageToGallery({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (Platform.isAndroid) {
      final result = await _galleryChannel.invokeMethod<bool>(
        'saveImage',
        <String, dynamic>{
          'bytes': bytes,
          'fileName': fileName,
        },
      );
      return result ?? false;
    }

    throw UnsupportedError('Saving is currently supported on Android only.');
  }

  Future<_ArFrameConfig> _fetchConfig() async {
    final response = await http.get(_configUri);
    if (response.statusCode != 200) {
      throw Exception('Config request failed');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['status'] != 'success') {
      throw Exception('Invalid config response');
    }

    final data = Map<String, dynamic>.from(decoded['data'] as Map);
    final overlayUrl = (data['overlay_url'] ?? '').toString();
    if (overlayUrl.trim().isEmpty) {
      throw Exception('Missing overlay url');
    }

    return _ArFrameConfig(
      overlayUrl: overlayUrl,
      scaleFactor: _asDouble(data['scale_factor'], 1.0),
      offsetX: _asDouble(data['offset_x'], 0),
      offsetY: _asDouble(data['offset_y'], 0),
      rotationAdjust: _asDouble(data['rotation_adjust'], 0),
      bridgeYAdjust: _asDouble(data['bridge_y_adjust'], 0),
    );
  }

  Future<_PhotoTryOnPose> _detectFacePose(
    String imagePath,
    _ArFrameConfig config,
  ) async {
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableLandmarks: true,
        enableContours: false,
      ),
    );

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final faces = await detector.processImage(inputImage);
      if (faces.isEmpty) {
        throw Exception('No face detected');
      }

      final face = faces.reduce(
        (best, current) =>
            best.boundingBox.width * best.boundingBox.height >=
                    current.boundingBox.width * current.boundingBox.height
                ? best
                : current,
      );

      final leftEye = face.landmarks[FaceLandmarkType.leftEye]?.position;
      final rightEye = face.landmarks[FaceLandmarkType.rightEye]?.position;
      final noseBase = face.landmarks[FaceLandmarkType.noseBase]?.position;

      if (leftEye == null || rightEye == null || noseBase == null) {
        throw Exception('Required landmarks not found');
      }

      final dx = rightEye.x - leftEye.x;
      final dy = rightEye.y - leftEye.y;
      final eyeDistance = math.sqrt(dx * dx + dy * dy);
      if (eyeDistance == 0) {
        throw Exception('Invalid eye distance');
      }

      final angle = math.atan2(dy, dx) + config.rotationAdjust;
      final eyeCenterX = (leftEye.x + rightEye.x) / 2;
      final eyeCenterY = (leftEye.y + rightEye.y) / 2;
      final faceWidth = face.boundingBox.width;
      final width =
          math.max(faceWidth * 0.98, eyeDistance * 2.0) * config.scaleFactor;
      final centerX = eyeCenterX + (config.offsetX * eyeDistance);
      final centerY = eyeCenterY - (eyeDistance * 0.08) +
          ((noseBase.y - eyeCenterY) * 0.18) +
          (config.bridgeYAdjust * eyeDistance) +
          (config.offsetY * eyeDistance);

      return _PhotoTryOnPose(
        centerX: centerX,
        centerY: centerY,
        width: width,
        angle: angle,
        faceRect: face.boundingBox,
      );
    } finally {
      await detector.close();
    }
  }

  Future<ui.Image> _decodeUiImage(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  static double _asDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.trim().isEmpty ? 'Photo Try On' : widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildPreview(theme),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            OutlinedButton.icon(
              onPressed: _loading || _saving ? null : _pickImage,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(
                _isArabic
                    ? 'اختيار صورة من الاستوديو'
                    : 'Choose photo from gallery',
              ),
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed:
                  _loading || _saving || _selectedImage == null ? null : _generate,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                _isArabic ? 'توليد النتيجة' : 'Generate result',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _saving || _loading || _pose == null ? null : _saveResult,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_outlined),
              label: Text(_isArabic ? 'حفظ الصورة' : 'Save image'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_photoImage != null && _frameImage != null && _pose != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _PhotoTryOnPainter(
              photoImage: _photoImage!,
              frameImage: _frameImage!,
              pose: _pose!,
            ),
          );
        },
      );
    }

    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.contain,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          _isArabic
              ? 'اختر صورة واضحة من الاستوديو ثم اضغط توليد لدمج الفريم عليها.'
              : 'Choose a clear portrait from the gallery, then tap Generate to blend the frame on it.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _PhotoTryOnPainter extends CustomPainter {
  final ui.Image photoImage;
  final ui.Image frameImage;
  final _PhotoTryOnPose pose;

  const _PhotoTryOnPainter({
    required this.photoImage,
    required this.frameImage,
    required this.pose,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sourceRect = _buildFocusedSourceRect(
      imageWidth: photoImage.width.toDouble(),
      imageHeight: photoImage.height.toDouble(),
      pose: pose,
    );

    _paintPhotoTryOn(
      canvas: canvas,
      size: size,
      photoImage: photoImage,
      frameImage: frameImage,
      pose: pose,
      sourceRect: sourceRect,
    );
  }

  @override
  bool shouldRepaint(covariant _PhotoTryOnPainter oldDelegate) {
    return oldDelegate.photoImage != photoImage ||
        oldDelegate.frameImage != frameImage ||
        oldDelegate.pose != pose;
  }
}

void _paintPhotoTryOn({
  required Canvas canvas,
  required Size size,
  required ui.Image photoImage,
  required ui.Image frameImage,
  required _PhotoTryOnPose pose,
  required Rect sourceRect,
}) {
  final destinationRect = Rect.fromLTWH(0, 0, size.width, size.height);
  canvas.drawImageRect(photoImage, sourceRect, destinationRect, Paint());

  final scaleX = destinationRect.width / sourceRect.width;
  final scaleY = destinationRect.height / sourceRect.height;
  final frameWidth = pose.width * scaleX;
  final frameHeight = frameWidth * (frameImage.height / frameImage.width);
  final centerX = (pose.centerX - sourceRect.left) * scaleX;
  final centerY = (pose.centerY - sourceRect.top) * scaleY;

  canvas.save();
  canvas.translate(centerX, centerY);
  canvas.rotate(pose.angle);
  paintImage(
    canvas: canvas,
    rect: Rect.fromCenter(
      center: Offset.zero,
      width: frameWidth,
      height: frameHeight,
    ),
    image: frameImage,
    fit: BoxFit.fill,
    filterQuality: FilterQuality.high,
  );
  canvas.restore();
}

Rect _buildFocusedSourceRect({
  required double imageWidth,
  required double imageHeight,
  required _PhotoTryOnPose pose,
}) {
  final face = pose.faceRect;
  final desiredWidth =
      math.min(imageWidth, math.max(face.width * 3.2, 420.0)).toDouble();
  final desiredHeight =
      math.min(imageHeight, math.max(face.height * 4.6, 560.0)).toDouble();

  double left = pose.centerX - (desiredWidth / 2);
  double top = pose.centerY - (desiredHeight * 0.38);

  left = left
      .clamp(0.0, math.max(0.0, imageWidth - desiredWidth))
      .toDouble();
  top = top
      .clamp(0.0, math.max(0.0, imageHeight - desiredHeight))
      .toDouble();

  return Rect.fromLTWH(left, top, desiredWidth, desiredHeight);
}

class _ArFrameConfig {
  final String overlayUrl;
  final double scaleFactor;
  final double offsetX;
  final double offsetY;
  final double rotationAdjust;
  final double bridgeYAdjust;

  const _ArFrameConfig({
    required this.overlayUrl,
    required this.scaleFactor,
    required this.offsetX,
    required this.offsetY,
    required this.rotationAdjust,
    required this.bridgeYAdjust,
  });
}

class _PhotoTryOnPose {
  final double centerX;
  final double centerY;
  final double width;
  final double angle;
  final Rect faceRect;

  const _PhotoTryOnPose({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.angle,
    required this.faceRect,
  });
}
