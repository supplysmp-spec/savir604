import 'package:get/get.dart';
import 'package:tks/core/constant/imsgesassets.dart';
import 'package:tks/data/datasource/model/OnBordingmodel.dart';

final bool _isArabic = Get.locale?.languageCode == 'ar';

List<OnBordingmodels> onbordinglist = [
  OnBordingmodels(
    title: _isArabic
        ? 'أهلًا بك في تجربة أزياء أكثر أناقة'
        : 'Welcome to a more stylish fashion journey',
    body: _isArabic
        ? 'سافير صار وجهتك لاكتشاف الملابس العصرية في تجربة شراء واضحة، مريحة، وسريعة من أول لحظة.'
        : 'Savir is now your destination for modern fashion in a clear, comfortable, and fast shopping experience.',
    badge: _isArabic ? 'بداية أنيقة' : 'Elegant start',
    highlights: [
      _isArabic ? 'ملابس عصرية' : 'Modern outfits',
      _isArabic ? 'رحلة سلسة' : 'Smooth flow',
      _isArabic ? 'تصميم مريح' : 'Comfort-first design',
    ],
    images: AppImageAsset.onBoardingImageOne,
  ),
  OnBordingmodels(
    title: _isArabic
        ? 'شاهد القطعة واختر الأنسب لك'
        : 'See the piece before you choose',
    body: _isArabic
        ? 'تصفّح الصور بوضوح، وراجع خامة القطعة وتفاصيلها قبل إضافتها إلى السلة.'
        : 'Browse clear visuals, review the fabric and details, then add the piece with confidence.',
    badge: _isArabic ? 'تجربة ذكية' : 'Smart experience',
    highlights: [
      _isArabic ? 'عرض أوضح' : 'Clear preview',
      _isArabic ? 'تفاصيل دقيقة' : 'Detailed info',
      _isArabic ? 'صور متعددة' : 'Multiple images',
    ],
    images: AppImageAsset.onBoardingImageTwo,
  ),
  OnBordingmodels(
    title: _isArabic
        ? 'اختر اللون والمقاس المناسبين'
        : 'Choose the right color and size',
    body: _isArabic
        ? 'اختر اللون والمقاس لكل قطعة بسهولة، وشاهد السعر والمخزون حسب الاختيار.'
        : 'Pick the right color and size for every piece and see price and stock based on your selection.',
    badge: _isArabic ? 'مرونة كاملة' : 'Full flexibility',
    highlights: [
      _isArabic ? 'ألوان متعددة' : 'Multiple colors',
      _isArabic ? 'مقاسات واضحة' : 'Clear sizes',
      _isArabic ? 'سلة واضحة' : 'Clear cart',
    ],
    images: AppImageAsset.onBoardingImageThree,
  ),
  OnBordingmodels(
    title: _isArabic
        ? 'كل شيء تحت السيطرة بعد الطلب'
        : 'Stay in control after checkout',
    body: _isArabic
        ? 'من متابعة الطلب إلى الدعم والعروض، ستبقى التجربة مرتبة وواضحة حتى بعد إتمام الشراء.'
        : 'From order tracking to support and offers, the experience stays organized even after purchase.',
    badge: _isArabic ? 'راحة وثقة' : 'Confidence & ease',
    highlights: [
      _isArabic ? 'متابعة الطلب' : 'Track orders',
      _isArabic ? 'دعم سريع' : 'Fast support',
      _isArabic ? 'عروض مستمرة' : 'Ongoing offers',
    ],
    images: AppImageAsset.logo1,
  ),
];
