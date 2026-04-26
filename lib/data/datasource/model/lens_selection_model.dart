import 'dart:convert';

class EyePrescription {
  final String label;
  final double sph;
  final double cyl;
  final int axis;

  const EyePrescription({
    required this.label,
    required this.sph,
    required this.cyl,
    required this.axis,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'sph': sph,
      'cyl': cyl,
      'axis': axis,
    };
  }
}

class PrescriptionSelection {
  final EyePrescription rightEye;
  final EyePrescription leftEye;
  final String strengthLabel;
  final String recommendationNote;

  const PrescriptionSelection({
    required this.rightEye,
    required this.leftEye,
    required this.strengthLabel,
    required this.recommendationNote,
  });

  double get maxSph => [rightEye.sph.abs(), leftEye.sph.abs()].reduce(
        (value, element) => value > element ? value : element,
      );

  double get maxCyl => [rightEye.cyl.abs(), leftEye.cyl.abs()].reduce(
        (value, element) => value > element ? value : element,
      );

  Map<String, dynamic> toJson() {
    return {
      'right_eye': rightEye.toJson(),
      'left_eye': leftEye.toJson(),
      'strength_label': strengthLabel,
      'recommendation_note': recommendationNote,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  String get summary {
    String formatEye(EyePrescription eye) {
      return '${eye.label}: SPH ${eye.sph.toStringAsFixed(2)}, '
          'CYL ${eye.cyl.toStringAsFixed(2)}, AXIS ${eye.axis}';
    }

    return '${formatEye(rightEye)} | ${formatEye(leftEye)} | $strengthLabel';
  }

  static PrescriptionSelection fromInput({
    required String rightSph,
    required String rightCyl,
    required String rightAxis,
    required String leftSph,
    required String leftCyl,
    required String leftAxis,
    required bool isArabic,
  }) {
    final parsedRightSph = _parseDouble(rightSph, 'Right SPH');
    final parsedRightCyl = _parseDouble(rightCyl, 'Right CYL');
    final parsedRightAxis = _parseAxis(rightAxis, 'Right AXIS');
    final parsedLeftSph = _parseDouble(leftSph, 'Left SPH');
    final parsedLeftCyl = _parseDouble(leftCyl, 'Left CYL');
    final parsedLeftAxis = _parseAxis(leftAxis, 'Left AXIS');

    final maxPower = [
      parsedRightSph.abs(),
      parsedRightCyl.abs(),
      parsedLeftSph.abs(),
      parsedLeftCyl.abs(),
    ].reduce((value, element) => value > element ? value : element);

    final strengthLabel = maxPower >= 6
        ? (isArabic ? 'قوة عالية' : 'High power')
        : maxPower >= 3
            ? (isArabic ? 'قوة متوسطة' : 'Medium power')
            : (isArabic ? 'قوة خفيفة' : 'Light power');

    final recommendationNote = maxPower >= 6
        ? (isArabic
            ? 'نرشح عدسات فائقة النحافة لتقليل السمك والوزن.'
            : 'Ultra-thin lenses are strongly recommended to reduce bulk.')
        : maxPower >= 3
            ? (isArabic
                ? 'العدسات الرفيعة ستعطي راحة أفضل ومظهر أنحف.'
                : 'Thin lenses will provide better comfort and a slimmer look.')
            : (isArabic
                ? 'العدسات اليومية والبلوكات الزرقاء ستكون مناسبة.'
                : 'Daily clear and blue-cut lenses are a good fit.');

    return PrescriptionSelection(
      rightEye: EyePrescription(
        label: isArabic ? 'اليمنى' : 'Right',
        sph: parsedRightSph,
        cyl: parsedRightCyl,
        axis: parsedRightAxis,
      ),
      leftEye: EyePrescription(
        label: isArabic ? 'اليسرى' : 'Left',
        sph: parsedLeftSph,
        cyl: parsedLeftCyl,
        axis: parsedLeftAxis,
      ),
      strengthLabel: strengthLabel,
      recommendationNote: recommendationNote,
    );
  }

  static double _parseDouble(String value, String fieldName) {
    final normalized = value.trim().replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null) {
      throw FormatException('$fieldName is invalid');
    }
    return parsed;
  }

  static int _parseAxis(String value, String fieldName) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 0 || parsed > 180) {
      throw FormatException('$fieldName must be between 0 and 180');
    }
    return parsed;
  }
}

class LensOption {
  final String code;
  final String nameAr;
  final String nameEn;
  final String colorHex;
  final double unitPrice;
  final List<String> featuresAr;
  final List<String> featuresEn;
  final int priorityLight;
  final int priorityMedium;
  final int priorityHigh;

  const LensOption({
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.colorHex,
    required this.unitPrice,
    required this.featuresAr,
    required this.featuresEn,
    required this.priorityLight,
    required this.priorityMedium,
    required this.priorityHigh,
  });

  String displayName(bool isArabic) => isArabic ? nameAr : nameEn;

  List<String> displayFeatures(bool isArabic) =>
      isArabic ? featuresAr : featuresEn;

  Map<String, dynamic> toJson(bool isArabic) {
    return {
      'code': code,
      'name': displayName(isArabic),
      'color': colorHex,
      'features': displayFeatures(isArabic),
      'unit_price': unitPrice,
    };
  }

  factory LensOption.fromJson(Map<String, dynamic> json) {
    List<String> parseFeatures(dynamic raw) {
      final text = raw?.toString().trim() ?? '';
      if (text.isEmpty) return [];
      return text
          .split(RegExp(r'[\n\r]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return LensOption(
      code: json['lens_code']?.toString() ?? '',
      nameAr: json['lens_name_ar']?.toString() ?? '',
      nameEn: json['lens_name_en']?.toString() ?? '',
      colorHex: json['lens_color']?.toString() ?? '#DCEEFF',
      unitPrice: double.tryParse(json['lens_price']?.toString() ?? '0') ?? 0,
      featuresAr: parseFeatures(json['lens_features_ar']),
      featuresEn: parseFeatures(json['lens_features_en']),
      priorityLight:
          int.tryParse(json['priority_light']?.toString() ?? '99') ?? 99,
      priorityMedium:
          int.tryParse(json['priority_medium']?.toString() ?? '99') ?? 99,
      priorityHigh:
          int.tryParse(json['priority_high']?.toString() ?? '99') ?? 99,
    );
  }
}

class LensCatalog {
  static const List<LensOption> fallbackOptions = [
    LensOption(
      code: 'daily_clear_156',
      nameAr: 'عدسة يومية 1.56',
      nameEn: 'Daily Clear 1.56',
      colorHex: '#DCEEFF',
      unitPrice: 320,
      featuresAr: ['شفافة يومية', 'خفيفة', 'مناسبة للمقاسات الخفيفة'],
      featuresEn: ['Clear daily lens', 'Lightweight', 'Best for light prescriptions'],
      priorityLight: 2,
      priorityMedium: 99,
      priorityHigh: 99,
    ),
    LensOption(
      code: 'blue_cut_156',
      nameAr: 'عدسة بلو كت 1.56',
      nameEn: 'Blue Cut 1.56',
      colorHex: '#BEE3F8',
      unitPrice: 420,
      featuresAr: ['حماية من الضوء الأزرق', 'مريحة للشاشات', 'للاستخدام اليومي'],
      featuresEn: ['Blue light protection', 'Comfort for screens', 'Daily-use lens'],
      priorityLight: 1,
      priorityMedium: 99,
      priorityHigh: 99,
    ),
    LensOption(
      code: 'thin_160',
      nameAr: 'عدسة رفيعة 1.60',
      nameEn: 'Thin Lens 1.60',
      colorHex: '#C7F9CC',
      unitPrice: 560,
      featuresAr: ['أنحف من القياسي', 'شكل أجمل داخل الفريم', 'للمقاسات المتوسطة'],
      featuresEn: ['Slimmer profile', 'Better frame aesthetics', 'Great for medium power'],
      priorityLight: 3,
      priorityMedium: 2,
      priorityHigh: 99,
    ),
    LensOption(
      code: 'photochromic_160',
      nameAr: 'عدسة فوتوكروميك 1.60',
      nameEn: 'Photochromic 1.60',
      colorHex: '#FFD6A5',
      unitPrice: 720,
      featuresAr: ['تتفاعل مع الشمس', 'راحة داخل وخارج المنزل', 'مناسبة للقيادة'],
      featuresEn: ['Light-adaptive lens', 'Indoor and outdoor comfort', 'Great for driving'],
      priorityLight: 99,
      priorityMedium: 3,
      priorityHigh: 3,
    ),
    LensOption(
      code: 'ultra_thin_167',
      nameAr: 'عدسة فائقة النحافة 1.67',
      nameEn: 'Ultra Thin 1.67',
      colorHex: '#FEC5E5',
      unitPrice: 930,
      featuresAr: ['مقاس عالٍ', 'سمك أقل', 'مظهر أخف على الوجه'],
      featuresEn: ['High prescription ready', 'Reduced thickness', 'Lighter look on the face'],
      priorityLight: 99,
      priorityMedium: 1,
      priorityHigh: 2,
    ),
    LensOption(
      code: 'premium_ultra_174',
      nameAr: 'عدسة بريميوم 1.74',
      nameEn: 'Premium 1.74',
      colorHex: '#E9D5FF',
      unitPrice: 1180,
      featuresAr: ['أعلى نحافة', 'مناسبة للمقاسات العالية جدًا', 'خيار فاخر'],
      featuresEn: ['Maximum thinness', 'Built for very high prescriptions', 'Premium choice'],
      priorityLight: 99,
      priorityMedium: 99,
      priorityHigh: 1,
    ),
  ];

  static List<LensOption> options([List<LensOption>? source]) {
    if (source != null && source.isNotEmpty) {
      return source;
    }
    return fallbackOptions;
  }

  static List<LensOption> recommended(
    PrescriptionSelection selection, [
    List<LensOption>? source,
  ]) {
    final maxSph = selection.maxSph;
    final maxCyl = selection.maxCyl;
    final catalog = List<LensOption>.from(options(source));

    int priorityFor(LensOption option) {
      if (maxSph >= 6 || maxCyl >= 3) {
        return option.priorityHigh;
      }
      if (maxSph >= 3 || maxCyl >= 2) {
        return option.priorityMedium;
      }
      return option.priorityLight;
    }

    catalog.sort((a, b) {
      final pa = priorityFor(a);
      final pb = priorityFor(b);
      if (pa != pb) return pa.compareTo(pb);
      return a.unitPrice.compareTo(b.unitPrice);
    });

    return catalog;
  }
}
