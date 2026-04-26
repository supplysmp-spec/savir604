import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tks/linkapi/linkapi.dart';
import 'package:tks/view/screen/ar_photo_try_on_screen.dart';

class ArTryOnScreen extends StatefulWidget {
  final String itemId;
  final String? variantId;
  final String title;

  const ArTryOnScreen({
    super.key,
    required this.itemId,
    required this.title,
    this.variantId,
  });

  @override
  State<ArTryOnScreen> createState() => _ArTryOnScreenState();
}

class _ArTryOnScreenState extends State<ArTryOnScreen> {
  double _progress = 0;
  bool _checkingPermission = true;
  bool _cameraGranted = false;
  bool _cameraPermanentlyDenied = false;

  bool get _isArabic => Get.locale?.languageCode == 'ar';

  Uri get _tryOnUri {
    final query = <String, String>{
      'itemid': widget.itemId,
      'lang': _isArabic ? 'ar' : 'en',
    };

    if ((widget.variantId ?? '').trim().isNotEmpty) {
      query['variantid'] = widget.variantId!.trim();
    }

    return Uri.parse('${AppLink.server}/ar/tryon.php').replace(
      queryParameters: query,
    );
  }

  @override
  void initState() {
    super.initState();
    _ensureCameraPermission();
  }

  Future<void> _ensureCameraPermission() async {
    setState(() {
      _checkingPermission = true;
      _cameraPermanentlyDenied = false;
    });

    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!mounted) return;

    setState(() {
      _cameraGranted = status.isGranted;
      _cameraPermanentlyDenied = status.isPermanentlyDenied;
      _checkingPermission = false;
    });
  }

  void _openPhotoTryOn() {
    Get.to(
      () => ArPhotoTryOnScreen(
        itemId: widget.itemId,
        variantId: widget.variantId,
        title: widget.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pageTitle = widget.title.trim().isNotEmpty
        ? widget.title
        : (_isArabic ? 'Try Frame' : 'Try On');

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: _buildBody(theme),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: _openPhotoTryOn,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _isArabic ? 'Try on a gallery photo' : 'Try on a gallery photo',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _isArabic
                    ? 'If alignment needs tuning, adjust this product filter values in the database.'
                    : 'If alignment needs tuning, adjust this product filter values in the database.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_checkingPermission) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_cameraGranted) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 54,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                _isArabic
                    ? 'Camera access is required for live try-on.'
                    : 'Camera access is required for live try-on.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _cameraPermanentlyDenied
                    ? (_isArabic
                        ? 'Camera permission is permanently denied. Open app settings and enable it.'
                        : 'Camera permission is permanently denied. Open app settings and enable it.')
                    : (_isArabic
                        ? 'Allow camera access, then try again.'
                        : 'Allow camera access, then try again.'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _cameraPermanentlyDenied
                    ? openAppSettings
                    : _ensureCameraPermission,
                child: Text(
                  _cameraPermanentlyDenied
                      ? (_isArabic ? 'Open Settings' : 'Open Settings')
                      : (_isArabic ? 'Try Again' : 'Try Again'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _openPhotoTryOn,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(
                  _isArabic ? 'Use a gallery photo instead' : 'Use a gallery photo instead',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri.uri(_tryOnUri)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            iframeAllow: 'camera; microphone',
            iframeAllowFullscreen: true,
            useHybridComposition: true,
          ),
          onPermissionRequest: (controller, request) async {
            final status = await Permission.camera.status;
            if (!status.isGranted) {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.DENY,
              );
            }

            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          onProgressChanged: (controller, progress) {
            if (!mounted) return;
            setState(() {
              _progress = progress / 100;
            });
          },
        ),
        if (_progress < 1)
          LinearProgressIndicator(
            value: _progress == 0 ? null : _progress,
            minHeight: 3,
          ),
      ],
    );
  }
}
