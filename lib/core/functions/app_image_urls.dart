import 'package:tks/linkapi/linkapi.dart';

class AppImageUrls {
  static final List<String> _itemBases = [
    AppLink.imagestItems,
    AppLink.imagestItemsAlt,
  ];

  static final List<String> _categoryBases = [AppLink.imagestCategories];
  static final List<String> _userBases = [
    '${AppLink.server}/uploads/users/img',
    '${AppLink.server}/uploud/users/img',
  ];

  static List<String> item(String? imagePath) =>
      _buildCandidates(imagePath, _itemBases);

  static List<String> user(String? imagePath) =>
      _buildCandidates(imagePath, _userBases);

  static List<String> profileAvatar({
    String? imagePath,
    String? avatarUrl,
  }) {
    final Set<String> candidates = <String>{};
    candidates.addAll(_buildCandidates(avatarUrl, _userBases));
    candidates.addAll(_buildCandidates(imagePath, _userBases));
    return candidates.toList();
  }

  static List<String> category(
    String? imagePath, {
    String? nameEn,
    String? nameAr,
  }) {
    final candidates = <String>{..._buildCandidates(imagePath, _categoryBases)};
    for (final fileName in _categoryNameCandidates(nameEn, nameAr)) {
      candidates.addAll(_buildCandidates(fileName, _categoryBases));
    }
    return candidates.toList();
  }

  static List<String> _buildCandidates(
    String? imagePath,
    List<String> bases,
  ) {
    final trimmed = imagePath?.trim() ?? '';
    if (trimmed.isEmpty) return const [];

    final lowered = trimmed.toLowerCase();
    if (lowered == 'null' ||
        lowered == 'undefined' ||
        lowered == 'false' ||
        lowered == '0' ||
        lowered == 'none') {
      return const [];
    }

    final normalizedPath = trimmed.replaceAll('\\', '/');
    final embeddedAbsoluteUrl = _extractEmbeddedAbsoluteUrl(normalizedPath);

    if (embeddedAbsoluteUrl != null) {
      return <String>{
        _encodeAbsoluteUrl(AppLink.normalizeUrl(embeddedAbsoluteUrl)),
      }.toList();
    }

    if (normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://')) {
      final normalized = AppLink.normalizeUrl(normalizedPath);
      final Set<String> absoluteCandidates = <String>{
        _encodeAbsoluteUrl(normalized),
      };

      final String withoutNestedZahra =
          normalized.replaceFirst('/savir604/zahra/', '/savir604/');
      final String withNestedZahra =
          normalized.replaceFirst('/savir604/', '/savir604/zahra/');

      absoluteCandidates.add(_encodeAbsoluteUrl(withoutNestedZahra));
      absoluteCandidates.add(_encodeAbsoluteUrl(withNestedZahra));

      return absoluteCandidates.toList();
    }

    if (normalizedPath.startsWith('uploud/') ||
        normalizedPath.startsWith('uploads/')) {
      return [
        '${AppLink.server}/${_encodePath(normalizedPath)}',
      ];
    }

    final encodedPath = _encodePath(normalizedPath);
    return <String>{
      for (final base in bases) '$base/$encodedPath',
    }.toList();
  }

  static String? _extractEmbeddedAbsoluteUrl(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final lowered = normalized.toLowerCase();
    final httpIndex = lowered.indexOf('http://');
    final httpsIndex = lowered.indexOf('https://');

    int index = -1;
    if (httpIndex >= 0 && httpsIndex >= 0) {
      index = httpIndex < httpsIndex ? httpIndex : httpsIndex;
    } else if (httpIndex >= 0) {
      index = httpIndex;
    } else if (httpsIndex >= 0) {
      index = httpsIndex;
    }

    if (index <= 0) {
      return null;
    }

    return normalized.substring(index);
  }

  static String _encodeAbsoluteUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    return uri.replace(path: _encodePath(uri.path)).toString();
  }

  static String _encodePath(String path) {
    return path
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .map(Uri.encodeComponent)
        .join('/');
  }

  static List<String> _categoryNameCandidates(String? nameEn, String? nameAr) {
    final rawNames = [nameEn, nameAr]
        .map((e) => (e ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final candidates = <String>{};
    for (final name in rawNames) {
      final normalized = name.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (normalized.isEmpty) continue;

      if (normalized.contains('.')) {
        candidates.add(normalized);
      } else {
        for (final ext in const ['png', 'jpg', 'jpeg', 'webp']) {
          candidates.add('$normalized.$ext');
        }
      }
    }

    return candidates.toList();
  }
}
