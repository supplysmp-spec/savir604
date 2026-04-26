import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/core/services/services.dart';
import 'package:tks/data/datasource/remote/cart/cart_data.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_builder_data.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_pricing_data.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_profile_data.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_quiz_data.dart';
import 'package:tks/data/datasource/remote/fragrance/fragrance_social_data.dart';

FragranceFlowController ensureFragranceFlowController() {
  if (Get.isRegistered<FragranceFlowController>()) {
    return Get.find<FragranceFlowController>();
  }

  return Get.put(
    FragranceFlowController(Get.find<MyServices>()),
    permanent: true,
  );
}

class FragranceIntroSlide {
  const FragranceIntroSlide({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonLabel,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonLabel;
}

class FragranceQuizOption {
  const FragranceQuizOption({
    required this.optionId,
    required this.optionKey,
    required this.valueCode,
    required this.label,
  });

  final String optionId;
  final String optionKey;
  final String valueCode;
  final String label;

  factory FragranceQuizOption.fromJson(Map<String, dynamic> json) {
    return FragranceQuizOption(
      optionId: json['option_id']?.toString() ?? '',
      optionKey: json['option_key']?.toString() ?? '',
      valueCode: json['value_code']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class FragranceQuizQuestion {
  const FragranceQuizQuestion({
    required this.questionId,
    required this.questionKey,
    required this.title,
    required this.subtitle,
    required this.helper,
    required this.options,
  });

  final String questionId;
  final String questionKey;
  final String title;
  final String subtitle;
  final String helper;
  final List<FragranceQuizOption> options;

  factory FragranceQuizQuestion.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawOptions = (json['options'] as List?) ?? <dynamic>[];
    return FragranceQuizQuestion(
      questionId: json['question_id']?.toString() ?? '',
      questionKey: json['question_key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      helper: json['helper']?.toString() ?? '',
      options: rawOptions
          .map(
            (dynamic option) =>
                FragranceQuizOption.fromJson(Map<String, dynamic>.from(option as Map)),
          )
          .toList(),
    );
  }
}

class FragranceBuilderOption {
  const FragranceBuilderOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class FragranceProfileResult {
  const FragranceProfileResult({
    required this.personalityType,
    required this.recommendedNotes,
    required this.fragranceFamilies,
    required this.signatureStyle,
    required this.creationName,
    required this.compatibility,
    required this.creativity,
    required this.balance,
    this.resultKey = '',
  });

  final String personalityType;
  final List<String> recommendedNotes;
  final List<String> fragranceFamilies;
  final String signatureStyle;
  final String creationName;
  final int compatibility;
  final int creativity;
  final int balance;
  final String resultKey;

  factory FragranceProfileResult.fromJson(Map<String, dynamic> json) {
    List<String> parseList(dynamic value) {
      if (value is List) {
        return value.map((dynamic item) => item.toString()).where((String item) => item.isNotEmpty).toList();
      }
      final String text = value?.toString() ?? '';
      if (text.trim().isEmpty) {
        return <String>[];
      }
      return text
          .split(',')
          .map((String item) => item.trim())
          .where((String item) => item.isNotEmpty)
          .toList();
    }

    return FragranceProfileResult(
      personalityType: json['personalityType']?.toString() ??
          json['personality_type']?.toString() ??
          '',
      recommendedNotes: parseList(json['recommendedNotes'] ?? json['recommended_notes']),
      fragranceFamilies:
          parseList(json['fragranceFamilies'] ?? json['recommended_families']),
      signatureStyle: json['signatureStyle']?.toString() ??
          json['signature_style']?.toString() ??
          '',
      creationName:
          json['creationName']?.toString() ?? json['creation_name']?.toString() ?? '',
      compatibility: int.tryParse(
            '${json['compatibility'] ?? json['compatibility_score'] ?? 0}',
          ) ??
          0,
      creativity: int.tryParse(
            '${json['creativity'] ?? json['creativity_score'] ?? 0}',
          ) ??
          0,
      balance:
          int.tryParse('${json['balance'] ?? json['balance_score'] ?? 0}') ?? 0,
      resultKey:
          json['resultKey']?.toString() ?? json['result_key']?.toString() ?? '',
    );
  }
}

class FragranceIngredientPricing {
  const FragranceIngredientPricing({
    required this.id,
    required this.name,
    required this.stage,
    required this.pricePerGram,
    required this.defaultGrams,
  });

  final String id;
  final String name;
  final String stage;
  final double pricePerGram;
  final double defaultGrams;

  factory FragranceIngredientPricing.fromJson(Map<String, dynamic> json) {
    return FragranceIngredientPricing(
      id: json['ingredient_id']?.toString() ?? '',
      name: json['ingredient_name']?.toString() ?? '',
      stage: json['ingredient_stage']?.toString() ?? '',
      pricePerGram:
          double.tryParse(json['price_per_gram']?.toString() ?? '0') ?? 0,
      defaultGrams:
          double.tryParse(json['default_grams']?.toString() ?? '0') ?? 0,
    );
  }
}

class FragranceBottleSize {
  const FragranceBottleSize({
    required this.id,
    required this.label,
    required this.volumeMl,
    required this.baseCost,
    required this.packagingCost,
    required this.multiplier,
    required this.imageUrl,
  });

  final String id;
  final String label;
  final int volumeMl;
  final double baseCost;
  final double packagingCost;
  final double multiplier;
  final String imageUrl;

  factory FragranceBottleSize.fromJson(Map<String, dynamic> json) {
    return FragranceBottleSize(
      id: json['bottle_size_id']?.toString() ?? '',
      label: json['size_label']?.toString() ?? '',
      volumeMl: int.tryParse(json['volume_ml']?.toString() ?? '0') ?? 0,
      baseCost: double.tryParse(json['base_cost']?.toString() ?? '0') ?? 0,
      packagingCost: double.tryParse(json['packaging_cost']?.toString() ?? '0') ?? 0,
      multiplier: double.tryParse(json['multiplier']?.toString() ?? '1') ?? 1,
      imageUrl: json['image_url']?.toString() ?? '',
    );
  }
}

class FragranceFlowController extends GetxController {
  FragranceFlowController(this._services);

  final MyServices _services;
  final FragranceProfileData _profileData = FragranceProfileData(Get.find());
  final FragranceQuizData _quizData = FragranceQuizData(Get.find());
  final FragranceBuilderData _builderData = FragranceBuilderData(Get.find());
  final FragrancePricingData _pricingData = FragrancePricingData(Get.find());
  final CartData _cartData = CartData(Get.find());
  final FragranceSocialData _socialData = FragranceSocialData(Get.find());

  static const String introCompletedKey = 'fragrance_intro_completed';
  static const String audienceKey = 'fragrance_target_audience';
  static const String giftKey = 'fragrance_gift_type';
  static const String quizCompletedKey = 'fragrance_quiz_completed';
  static const String creationSavedKey = 'fragrance_creation_saved';

  final PageController onboardingController = PageController();
  final TextEditingController creationNameController = TextEditingController();

  int onboardingIndex = 0;
  String? selectedAudience;
  String? selectedGiftType;
  String? selectedBottleSizeId;
  bool pricingConfigLoaded = false;
  bool shareActionInProgress = false;
  bool quizLoading = false;
  bool quizSubmitting = false;
  String? quizError;

  final Map<String, String> quizAnswers = <String, String>{};
  final Map<int, List<String>> builderSelections = <int, List<String>>{
    0: <String>[],
    1: <String>[],
    2: <String>[],
  };

  List<FragranceQuizQuestion> quizQuestions = <FragranceQuizQuestion>[];
  List<FragranceIngredientPricing> ingredientPricing =
      <FragranceIngredientPricing>[];
  List<FragranceBottleSize> bottleSizes = <FragranceBottleSize>[];
  FragranceProfileResult? _profileResult;

  final List<FragranceIntroSlide> introSlides = const <FragranceIntroSlide>[
    FragranceIntroSlide(
      title: 'Discover the Art of Fragrance',
      subtitle:
          'Explore curated luxury perfumes tailored to your mood, taste, and identity.',
      icon: Icons.auto_awesome_rounded,
      buttonLabel: 'Continue',
    ),
    FragranceIntroSlide(
      title: 'Build Your Own Signature Perfume',
      subtitle:
          'Layer notes, craft accords, and shape a scent that feels uniquely yours.',
      icon: Icons.science_outlined,
      buttonLabel: 'Continue',
    ),
    FragranceIntroSlide(
      title: 'Join the Fragrance Community',
      subtitle:
          'Share discoveries, follow creators, and connect with perfume lovers worldwide.',
      icon: Icons.groups_2_outlined,
      buttonLabel: 'Get Started',
    ),
  ];

  bool get isIntroCompleted =>
      _services.sharedPreferences.getBool(introCompletedKey) ?? false;
  bool get isQuizCompleted =>
      _services.sharedPreferences.getBool(quizCompletedKey) ?? false;
  String get currentLangCode => Get.locale?.languageCode == 'ar' ? 'ar' : 'en';

  String t(String ar, String en) => currentLangCode == 'ar' ? ar : en;

  @override
  void onInit() {
    super.onInit();
    selectedAudience = _services.sharedPreferences.getString(audienceKey);
    selectedGiftType = _services.sharedPreferences.getString(giftKey);
    creationNameController.text = profileResult.creationName;
    _syncProfileFromBackend();
    _loadPricingConfig();
  }

  @override
  void onClose() {
    creationNameController.dispose();
    onboardingController.dispose();
    super.onClose();
  }

  Future<void> _loadPricingConfig() async {
    final dynamic response = await _pricingData.getConfig();
    if (response is Map && response['status'] == 'success') {
      ingredientPricing = ((response['ingredients'] as List?) ?? <dynamic>[])
          .map(
            (dynamic e) =>
                FragranceIngredientPricing.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      bottleSizes = ((response['bottle_sizes'] as List?) ?? <dynamic>[])
          .map(
            (dynamic e) =>
                FragranceBottleSize.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      _pruneBuilderSelections();
      selectedBottleSizeId ??= bottleSizes.isNotEmpty ? bottleSizes.first.id : null;
      pricingConfigLoaded = true;
      update();
    }
  }

  List<List<FragranceBuilderOption>> get builderSteps => <List<FragranceBuilderOption>>[
        _optionsForStage('top'),
        _optionsForStage('middle'),
        _optionsForStage('base'),
      ];

  int get builderStepsCount => builderSteps.length;

  List<FragranceBuilderOption> _optionsForStage(String stage) {
    return ingredientPricing
        .where(
          (FragranceIngredientPricing ingredient) =>
              ingredient.stage.toLowerCase() == stage,
        )
        .map(
          (FragranceIngredientPricing ingredient) => FragranceBuilderOption(
            id: ingredient.id,
            name: ingredient.name,
          ),
        )
        .toList();
  }

  void _pruneBuilderSelections() {
    final List<Set<String>> availableNotes = builderSteps
        .map(
          (List<FragranceBuilderOption> options) =>
              options.map((FragranceBuilderOption option) => option.name).toSet(),
        )
        .toList();

    for (int index = 0; index < availableNotes.length; index++) {
      final List<String> current = List<String>.from(selectedNotesForStep(index));
      builderSelections[index] = current
          .where((String note) => availableNotes[index].contains(note))
          .take(3)
          .toList();
    }
  }

  Future<void> ensureQuizLoaded({bool force = false}) async {
    if (quizLoading) {
      return;
    }
    if (!force && quizQuestions.isNotEmpty) {
      return;
    }

    quizLoading = true;
    quizError = null;
    update();

    final dynamic response = await _quizData.getQuestions(
      lang: currentLangCode,
      audience: selectedAudience,
      giftType: selectedGiftType,
    );

    if (response is Map && response['status'] == 'success') {
      final List<dynamic> rows = (response['data'] as List?) ?? <dynamic>[];
      quizQuestions = rows
          .map(
            (dynamic row) =>
                FragranceQuizQuestion.fromJson(Map<String, dynamic>.from(row)),
          )
          .toList();
      quizError = quizQuestions.isEmpty
          ? t('لا توجد أسئلة متاحة حاليًا.', 'No quiz questions are available right now.')
          : null;
    } else {
      quizQuestions = <FragranceQuizQuestion>[];
      quizError = t(
        'تعذر تحميل الأسئلة الآن. حاول مرة أخرى.',
        'Unable to load quiz questions right now. Please try again.',
      );
    }

    quizLoading = false;
    update();
  }

  void setOnboardingIndex(int value) {
    onboardingIndex = value;
    update();
  }

  Future<void> nextOnboardingPage() async {
    if (onboardingIndex >= introSlides.length - 1) {
      await _services.sharedPreferences.setBool(introCompletedKey, true);
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    await onboardingController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> skipOnboarding() async {
    await _services.sharedPreferences.setBool(introCompletedKey, true);
    Get.offAllNamed(AppRoutes.login);
  }

  void chooseAudience(String value) {
    selectedAudience = value;
    _services.sharedPreferences.setString(audienceKey, value);
    _upsertProfile();
    update();
  }

  Future<void> continueFromAudience() async {
    if (selectedAudience == null) {
      return;
    }

    if (selectedAudience == 'gift') {
      Get.toNamed(AppRoutes.fragranceGift);
      return;
    }

    await _services.sharedPreferences.setBool(introCompletedKey, true);
    await ensureQuizLoaded(force: true);
    if (quizQuestions.isEmpty) {
      Get.snackbar(
        t('لا يمكن بدء الأسئلة الآن', 'Unable to start the quiz right now'),
        quizError ?? t('حاول مرة أخرى لاحقًا', 'Please try again later'),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(
      AppRoutes.fragranceQuiz,
      arguments: <String, dynamic>{'index': 0},
    );
  }

  void chooseGiftType(String value) {
    selectedGiftType = value;
    _services.sharedPreferences.setString(giftKey, value);
    _upsertProfile();
    update();
  }

  Future<void> continueFromGift() async {
    if (selectedGiftType == null) {
      return;
    }

    await _services.sharedPreferences.setBool(introCompletedKey, true);
    await ensureQuizLoaded(force: true);
    if (quizQuestions.isEmpty) {
      Get.snackbar(
        t('لا يمكن بدء الأسئلة الآن', 'Unable to start the quiz right now'),
        quizError ?? t('حاول مرة أخرى لاحقًا', 'Please try again later'),
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.toNamed(
      AppRoutes.fragranceQuiz,
      arguments: <String, dynamic>{'index': 0},
    );
  }

  bool get canStartQuiz {
    if (selectedAudience == 'gift') {
      return selectedGiftType != null;
    }
    return selectedAudience != null;
  }

  Future<void> routeAfterLogin() async {
    if (!isQuizCompleted) {
      Get.offAllNamed(AppRoutes.fragranceAudience);
      return;
    }

    Get.offAllNamed(AppRoutes.homepage);
  }

  void selectQuizAnswer(int questionIndex, String optionId) {
    if (questionIndex < 0 || questionIndex >= quizQuestions.length) {
      return;
    }
    final String questionId = quizQuestions[questionIndex].questionId;
    quizAnswers[questionId] = optionId;
    _upsertProfile();
    update();
  }

  String? answerFor(int questionIndex) {
    if (questionIndex < 0 || questionIndex >= quizQuestions.length) {
      return null;
    }
    return quizAnswers[quizQuestions[questionIndex].questionId];
  }

  Future<void> continueQuiz(int questionIndex) async {
    if (answerFor(questionIndex) == null) {
      return;
    }

    if (questionIndex >= quizQuestions.length - 1) {
      final bool submitted = await submitQuiz();
      if (submitted) {
        Get.offAllNamed(AppRoutes.fragranceResult);
      }
      return;
    }

    Get.toNamed(
      AppRoutes.fragranceQuiz,
      arguments: <String, dynamic>{'index': questionIndex + 1},
      preventDuplicates: false,
    );
  }

  Future<bool> submitQuiz() async {
    final int? userId = _services.sharedPreferences.getInt('id');
    if (userId == null || quizAnswers.isEmpty) {
      return false;
    }

    quizSubmitting = true;
    update();

    final dynamic response = await _quizData.submitQuiz(
      userId: userId.toString(),
      lang: currentLangCode,
      answers: quizAnswers,
      audience: selectedAudience,
      giftType: selectedGiftType,
    );

    quizSubmitting = false;

    if (response is Map && response['status'] == 'success' && response['data'] is Map) {
      _profileResult =
          FragranceProfileResult.fromJson(Map<String, dynamic>.from(response['data']));
      await _services.sharedPreferences.setBool(quizCompletedKey, true);
      _syncCreationNameWithRecommendation();
      update();
      return true;
    }

    Get.snackbar(
      t('تعذر تحليل الإجابات', 'Unable to analyze your answers'),
      t(
        'حاول مرة أخرى بعد مراجعة إجاباتك.',
        'Please try again after reviewing your answers.',
      ),
      snackPosition: SnackPosition.BOTTOM,
    );
    update();
    return false;
  }

  void goBackQuiz() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
      return;
    }

    Get.offAllNamed(AppRoutes.homepage);
  }

  FragranceProfileResult get profileResult =>
      _profileResult ?? _fallbackProfileResult();

  FragranceProfileResult _fallbackProfileResult() {
    return FragranceProfileResult(
      personalityType: t('ذوق متوازن', 'Balanced Taste'),
      recommendedNotes: currentLangCode == 'ar'
          ? <String>['ورد', 'مسك', 'عنبر', 'صندل', 'برغموت']
          : <String>['Rose', 'Musk', 'Amber', 'Sandalwood', 'Bergamot'],
      fragranceFamilies: currentLangCode == 'ar'
          ? <String>['زهري', 'خشبي', 'عنبر']
          : <String>['Floral', 'Woody', 'Amber'],
      signatureStyle: t(
        'نتيجتك المخصصة ستظهر هنا بعد إنهاء الأسئلة الدينمك.',
        'Your personalized profile will appear here after completing the dynamic quiz.',
      ),
      creationName: t('لمسة خاصة', 'Signature Touch'),
      compatibility: 88,
      creativity: 84,
      balance: 86,
      resultKey: 'fallback_profile',
    );
  }

  List<String> selectedNotesForStep(int step) =>
      builderSelections[step] ?? <String>[];

  bool isBuilderSelected(int step, String note) =>
      selectedNotesForStep(step).contains(note);

  void toggleBuilderSelection(int step, String note) {
    final List<String> current = List<String>.from(selectedNotesForStep(step));

    if (current.contains(note)) {
      current.remove(note);
    } else if (current.length < 3) {
      current.add(note);
    }

    builderSelections[step] = current;
    update();
  }

  bool canContinueBuilderStep(int step) => selectedNotesForStep(step).isNotEmpty;

  void openBuilderStep(int step) {
    Get.toNamed(
      AppRoutes.fragranceBuilder,
      arguments: <String, dynamic>{'step': step},
      preventDuplicates: false,
    );
  }

  void continueBuilderStep(int step) {
    if (!canContinueBuilderStep(step)) {
      return;
    }

    if (step >= builderSteps.length - 1) {
      _syncCreationNameWithRecommendation();
      Get.offAllNamed(AppRoutes.fragranceCreation);
      return;
    }

    Get.toNamed(
      AppRoutes.fragranceBuilder,
      arguments: <String, dynamic>{'step': step + 1},
      preventDuplicates: false,
    );
  }

  void resetBuilder() {
    builderSelections[0] = <String>[];
    builderSelections[1] = <String>[];
    builderSelections[2] = <String>[];
    selectedBottleSizeId = bottleSizes.isNotEmpty ? bottleSizes.first.id : null;
    _services.sharedPreferences.remove(creationSavedKey);
    creationNameController.text = profileResult.creationName;
    update();
  }

  void updateCreationName(String value) {
    creationNameController.value = creationNameController.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    update();
  }

  void selectBottleSize(String bottleSizeId) {
    selectedBottleSizeId = bottleSizeId;
    update();
  }

  void _syncCreationNameWithRecommendation() {
    if (creationNameController.text.trim().isEmpty) {
      creationNameController.text = profileResult.creationName;
    }
  }

  String get creationName {
    final String value = creationNameController.text.trim();
    if (value.isNotEmpty) {
      return value;
    }
    return profileResult.creationName;
  }

  FragranceBottleSize? get selectedBottleSize {
    if (selectedBottleSizeId == null) {
      return bottleSizes.isNotEmpty ? bottleSizes.first : null;
    }
    return bottleSizes.firstWhereOrNull(
      (FragranceBottleSize size) => size.id == selectedBottleSizeId,
    );
  }

  FragranceIngredientPricing? _findIngredient(String stage, String noteName) {
    return ingredientPricing.firstWhereOrNull(
      (FragranceIngredientPricing ingredient) =>
          ingredient.stage == stage &&
          ingredient.name.toLowerCase() == noteName.toLowerCase(),
    );
  }

  double _stageCost(String stage, List<String> notes) {
    final FragranceBottleSize? bottle = selectedBottleSize;
    final double multiplier = bottle?.multiplier ?? 1;
    double total = 0;
    for (final String note in notes) {
      final FragranceIngredientPricing? ingredient =
          _findIngredient(stage, note);
      if (ingredient == null) {
        continue;
      }
      total += ingredient.pricePerGram * ingredient.defaultGrams * multiplier;
    }
    return total;
  }

  double get ingredientCost =>
      _stageCost('top', topNotes) +
      _stageCost('middle', middleNotes) +
      _stageCost('base', baseNotes);

  double get totalGrams {
    final FragranceBottleSize? bottle = selectedBottleSize;
    final double multiplier = bottle?.multiplier ?? 1;
    double grams = 0;
    for (final String note in topNotes) {
      grams += (_findIngredient('top', note)?.defaultGrams ?? 0) * multiplier;
    }
    for (final String note in middleNotes) {
      grams += (_findIngredient('middle', note)?.defaultGrams ?? 0) * multiplier;
    }
    for (final String note in baseNotes) {
      grams += (_findIngredient('base', note)?.defaultGrams ?? 0) * multiplier;
    }
    return grams;
  }

  double get estimatedPrice {
    final FragranceBottleSize? bottle = selectedBottleSize;
    return ingredientCost + (bottle?.baseCost ?? 0) + (bottle?.packagingCost ?? 0);
  }

  Future<void> saveCreation() async {
    await _services.sharedPreferences.setBool(creationSavedKey, true);
    await _persistCreation();
  }

  Future<bool> addCreationToCart() async {
    final int? userId = _services.sharedPreferences.getInt('id');
    if (userId == null || creationName.trim().isEmpty) {
      return false;
    }

    final dynamic creationResponse = await _persistCreation();
    if (creationResponse is! Map || creationResponse['status'] != 'success') {
      return false;
    }

    final String customPerfumeId =
        creationResponse['custom_perfume_id']?.toString() ?? '';
    if (customPerfumeId.isEmpty) {
      return false;
    }

    final dynamic cartResponse = await _cartData.addCart(
      userId.toString(),
      null,
      customPerfumeId: customPerfumeId,
      cartItemType: 'custom_perfume',
    );

    return cartResponse is Map && cartResponse['status'] == 'success';
  }

  Future<Map<String, dynamic>?> shareCreationAsPost({
    required String description,
    XFile? imageFile,
  }) async {
    final int? userId = _services.sharedPreferences.getInt('id');
    if (userId == null || creationName.trim().isEmpty) {
      return null;
    }

    shareActionInProgress = true;
    update();

    try {
      final dynamic creationResponse = await _persistCreation();
      if (creationResponse is! Map || creationResponse['status'] != 'success') {
        return null;
      }

      final int? customPerfumeId = int.tryParse(
        creationResponse['custom_perfume_id']?.toString() ?? '',
      );
      if (customPerfumeId == null) {
        return null;
      }

      return await _socialData.createCustomPerfumePost(
        userId: userId,
        customPerfumeId: customPerfumeId,
        postText: _composeCreationDescription(description),
        imageFile: imageFile,
      );
    } finally {
      shareActionInProgress = false;
      update();
    }
  }

  Future<Map<String, dynamic>?> shareCreationAsStory({
    required String description,
    XFile? imageFile,
  }) async {
    final int? userId = _services.sharedPreferences.getInt('id');
    if (userId == null || creationName.trim().isEmpty) {
      return null;
    }

    shareActionInProgress = true;
    update();

    try {
      final dynamic creationResponse = await _persistCreation();
      if (creationResponse is! Map || creationResponse['status'] != 'success') {
        return null;
      }

      return await _socialData.createCustomPerfumeStory(
        userId: userId,
        storyText: _composeCreationDescription(description),
        imageFile: imageFile,
      );
    } finally {
      shareActionInProgress = false;
      update();
    }
  }

  String _composeCreationDescription(String description) {
    final List<String> lines = <String>[
      creationName,
      if (description.trim().isNotEmpty) description.trim(),
      'Top: ${topNotes.join(', ')}',
      'Middle: ${middleNotes.join(', ')}',
      'Base: ${baseNotes.join(', ')}',
      'Size: ${selectedBottleSize?.label ?? '--'}',
      'Price: ${CurrencyFormatter.egp(estimatedPrice)}',
    ];
    return lines.join('\n');
  }

  Future<dynamic> _persistCreation() async {
    final int? userId = _services.sharedPreferences.getInt('id');
    if (userId == null ||
        selectedBottleSize == null ||
        creationName.trim().isEmpty) {
      return null;
    }

    final FragranceProfileResult result = profileResult;
    return _builderData.saveCreation(
      userId: userId.toString(),
      creationName: creationName,
      bottleSizeId: selectedBottleSize!.id,
      topNotes: topNotes,
      middleNotes: middleNotes,
      baseNotes: baseNotes,
      compatibility: result.compatibility,
      creativity: result.creativity,
      balance: result.balance,
      estimatedPrice: estimatedPrice,
    );
  }

  Future<void> clearQuizState({bool clearAudience = false}) async {
    quizAnswers.clear();
    quizQuestions = <FragranceQuizQuestion>[];
    _profileResult = null;
    await _services.sharedPreferences.remove(quizCompletedKey);

    if (clearAudience) {
      selectedAudience = null;
      selectedGiftType = null;
      await _services.sharedPreferences.remove(audienceKey);
      await _services.sharedPreferences.remove(giftKey);
    }
    await _upsertProfile(profileCompleted: false);
    update();
  }

  Future<void> retakeQuiz() async {
    await clearQuizState();
    await ensureQuizLoaded(force: true);
    Get.toNamed(
      AppRoutes.fragranceQuiz,
      arguments: <String, dynamic>{'index': 0},
      preventDuplicates: false,
    );
  }

  Future<void> editPreferences() async {
    await clearQuizState(clearAudience: true);
    Get.toNamed(AppRoutes.fragranceAudience);
  }

  List<String> get topNotes => selectedNotesForStep(0);
  List<String> get middleNotes => selectedNotesForStep(1);
  List<String> get baseNotes => selectedNotesForStep(2);

  Future<void> routeFromSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 2200));

    if (!isIntroCompleted) {
      Get.offAllNamed(AppRoutes.OnBording);
      return;
    }

    final String? step = _services.sharedPreferences.getString('step');
    if (step == '2') {
      await routeAfterLogin();
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> _syncProfileFromBackend() async {
    final int? userId = _services.sharedPreferences.getInt('id');
    if (userId == null) {
      return;
    }

    final dynamic response = await _profileData.getProfile(userId.toString());
    if (response is! Map ||
        response['status'] != 'success' ||
        response['data'] is! Map) {
      return;
    }

    final Map<dynamic, dynamic> profile = response['data'] as Map<dynamic, dynamic>;
    selectedAudience = (profile['audience']?.toString().isNotEmpty ?? false)
        ? profile['audience'].toString()
        : selectedAudience;
    selectedGiftType = (profile['gift_type']?.toString().isNotEmpty ?? false)
        ? profile['gift_type'].toString()
        : selectedGiftType;

    final String rawAnswers = profile['quiz_answers_json']?.toString() ?? '';
    if (rawAnswers.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded =
            Map<String, dynamic>.from(jsonDecode(rawAnswers) as Map);
        quizAnswers
          ..clear()
          ..addAll(
            decoded.map(
              (String key, dynamic value) =>
                  MapEntry<String, String>(key, value.toString()),
            ),
          );
      } catch (_) {}
    }

    if (selectedAudience != null) {
      await _services.sharedPreferences.setString(audienceKey, selectedAudience!);
    }
    if (selectedGiftType != null) {
      await _services.sharedPreferences.setString(giftKey, selectedGiftType!);
    }
    if (profile['profile_completed'].toString() == '1') {
      await _services.sharedPreferences.setBool(quizCompletedKey, true);
    }

    final String payload = profile['result_payload_json']?.toString() ?? '';
    if (payload.isNotEmpty) {
      try {
        _profileResult = FragranceProfileResult.fromJson(
          Map<String, dynamic>.from(jsonDecode(payload) as Map),
        );
      } catch (_) {}
    } else if ((profile['personality_type']?.toString().isNotEmpty ?? false) ||
        (profile['creation_name']?.toString().isNotEmpty ?? false)) {
      _profileResult = FragranceProfileResult.fromJson(
        Map<String, dynamic>.from(profile.cast<String, dynamic>()),
      );
    }

    if (selectedAudience != null &&
        (selectedAudience != 'gift' || selectedGiftType != null)) {
      await ensureQuizLoaded(force: true);
    }

    if (isQuizCompleted && quizAnswers.isNotEmpty) {
      await submitQuiz();
    }

    _syncCreationNameWithRecommendation();
    update();
  }

  Future<void> _upsertProfile({bool? profileCompleted}) async {
    final int? userId = _services.sharedPreferences.getInt('id');
    if (userId == null) {
      return;
    }

    final bool completed = profileCompleted ?? isQuizCompleted;
    final FragranceProfileResult result = profileResult;
    await _profileData.upsertProfile(
      userId: userId.toString(),
      audience: selectedAudience,
      giftType: selectedGiftType,
      quizAnswers: quizAnswers,
      personalityType: completed ? result.personalityType : null,
      recommendedNotes: completed ? result.recommendedNotes : null,
      recommendedFamilies: completed ? result.fragranceFamilies : null,
      signatureStyle: completed ? result.signatureStyle : null,
      resultKey: completed ? result.resultKey : null,
      creationName: completed ? result.creationName : null,
      compatibilityScore: completed ? result.compatibility : null,
      creativityScore: completed ? result.creativity : null,
      balanceScore: completed ? result.balance : null,
      resultPayloadJson:
          completed ? jsonEncode(_profileResultToJson(result)) : null,
      profileCompleted: completed,
    );
  }

  Map<String, dynamic> _profileResultToJson(FragranceProfileResult result) {
    return <String, dynamic>{
      'personalityType': result.personalityType,
      'recommendedNotes': result.recommendedNotes,
      'fragranceFamilies': result.fragranceFamilies,
      'signatureStyle': result.signatureStyle,
      'creationName': result.creationName,
      'compatibility': result.compatibility,
      'creativity': result.creativity,
      'balance': result.balance,
      'resultKey': result.resultKey,
    };
  }
}
