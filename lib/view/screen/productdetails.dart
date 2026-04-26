import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/productdetails/productdetails_controller.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/core/functions/translatefatabase.dart';
import 'package:tks/data/datasource/model/item_image_model.dart';
import 'package:tks/data/datasource/model/itemsmodel.dart';
import 'package:tks/data/datasource/model/ratingmodel.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProductDetailsControllerImp());

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: GetBuilder<ProductDetailsControllerImp>(
        builder: (ProductDetailsControllerImp controller) {
          final ItemsModel item = controller.itemsModel;
          final String title =
              translateDatabase(item.itemsNameAr, item.itemsNameEn) ?? 'Perfume';
          final String family = translateDatabase(
                item.categoriesNameAr,
                item.categoriesNameEn,
              ) ??
              'Precious Collection';
          final String badgeLabel = (item.itemsBadge ?? '').trim();
          final double rating = controller.averageRating;
          final int reviewCount = controller.ratingsCount;
          final bool hasRating = rating > 0 && reviewCount > 0;
          final List<String> topNotes = item.topNotesList;
          final List<String> middleNotes = item.middleNotesList;
          final List<String> baseNotes = item.baseNotesList;
          final List<String> bestForTags = item.bestForList;
          final List<String> seasonsTags = item.seasonsList;
          final String? concentration = (item.itemsConcentration ?? '').trim().isEmpty
              ? null
              : item.itemsConcentration!.trim();
          final String? perfumeFamily = (item.itemsPerfumeFamily ?? '').trim().isEmpty
              ? null
              : item.itemsPerfumeFamily!.trim();

          return HandlingDataView(
            statusRequest: controller.statusRequest,
            widget: Stack(
              children: <Widget>[
                ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 170),
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _topCircleButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: Get.back,
                        ),
                        const Spacer(),
                        _topCircleButton(
                          icon: controller.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          onTap: controller.toggleFavorite,
                        ),
                        const SizedBox(width: 10),
                        _topCircleButton(
                          icon: Icons.share_outlined,
                          onTap: controller.share,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 430,
                      decoration: BoxDecoration(
                        color: const Color(0xFF171614),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF362A1D)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          FallbackNetworkImage(
                            imageUrls: controller.images.isNotEmpty
                                ? controller.images
                                    .map((ItemImageModel e) => e.imgPath)
                                    .expand(AppImageUrls.item)
                                    .toSet()
                                    .toList()
                                : item.galleryImagePaths
                                    .expand(AppImageUrls.item)
                                    .toSet()
                                    .toList(),
                            label: title,
                            fit: BoxFit.cover,
                          ),
                          if (badgeLabel.isNotEmpty)
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: const Color(0xFFD6B878),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    const Icon(
                                      Icons.auto_awesome_outlined,
                                      size: 16,
                                      color: Color(0xFF16120D),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      badgeLabel,
                                      style: const TextStyle(
                                        color: Color(0xFF16120D),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      family,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.56),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'myfont',
                        fontSize: 38,
                      ),
                    ),
                    if (concentration != null || perfumeFamily != null) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        [concentration, perfumeFamily]
                            .whereType<String>()
                            .where((value) => value.isNotEmpty)
                            .join(' • '),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.48),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFF4B400),
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasRating ? rating.toStringAsFixed(1) : '0.0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hasRating ? '($reviewCount reviews)' : '(No reviews yet)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.54),
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      CurrencyFormatter.egp(controller.selectedPrice),
                      style: const TextStyle(
                        color: Color(0xFFD6B878),
                        fontFamily: 'myfont',
                        fontSize: 44,
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (controller.hasVariants) ...<Widget>[
                      const _SectionTitle(title: 'Selection'),
                      const SizedBox(height: 12),
                      if (controller.availableColors.isNotEmpty) ...<Widget>[
                        Text(
                          'Bottle Design',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: controller.availableColors
                              .map(
                                (option) => _ChoiceChip(
                                  label: option.displayName(false),
                                  selected: controller.selectedColorId == option.id,
                                  onTap: () => controller.selectColor(option.id),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (controller.selectableSizes.isNotEmpty) ...<Widget>[
                        Text(
                          'Bottle Size',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: controller.selectableSizes
                              .map(
                                (option) => _ChoiceChip(
                                  label: option.displayName(false),
                                  selected: controller.selectedSizeId == option.id,
                                  onTap: () => controller.selectSize(option.id),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 26),
                      ],
                    ],
                    if (topNotes.isNotEmpty ||
                        middleNotes.isNotEmpty ||
                        baseNotes.isNotEmpty) ...<Widget>[
                      const _SectionTitle(title: 'Fragrance Notes'),
                      const SizedBox(height: 16),
                      if (topNotes.isNotEmpty) ...<Widget>[
                        _NotesBlock(title: 'Top Notes', notes: topNotes),
                        const SizedBox(height: 14),
                      ],
                      if (middleNotes.isNotEmpty) ...<Widget>[
                        _NotesBlock(title: 'Middle Notes', notes: middleNotes),
                        const SizedBox(height: 14),
                      ],
                      if (baseNotes.isNotEmpty) ...<Widget>[
                        _NotesBlock(title: 'Base Notes', notes: baseNotes),
                        const SizedBox(height: 28),
                      ],
                    ],
                    if (item.itemsLongevityValue > 0 ||
                        item.itemsSillageValue > 0) ...<Widget>[
                      const _SectionTitle(title: 'Performance'),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          if (item.itemsLongevityValue > 0)
                            Expanded(
                              child: _PerformanceCard(
                                icon: Icons.access_time_rounded,
                                title: 'Longevity',
                                score: item.itemsLongevityValue,
                              ),
                            ),
                          if (item.itemsLongevityValue > 0 &&
                              item.itemsSillageValue > 0)
                            const SizedBox(width: 14),
                          if (item.itemsSillageValue > 0)
                            Expanded(
                              child: _PerformanceCard(
                                icon: Icons.air_rounded,
                                title: 'Sillage',
                                score: item.itemsSillageValue,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 22),
                    ],
                    if (bestForTags.isNotEmpty) ...<Widget>[
                      _TagGroup(title: 'Best For', tags: bestForTags),
                      const SizedBox(height: 18),
                    ],
                    if (seasonsTags.isNotEmpty) ...<Widget>[
                      _TagGroup(title: 'Seasons', tags: seasonsTags),
                      const SizedBox(height: 28),
                    ],
                    if ((item.itemsDescEn ?? item.itemsDescAr ?? '')
                        .trim()
                        .isNotEmpty) ...<Widget>[
                      const _SectionTitle(title: 'About This Fragrance'),
                      const SizedBox(height: 12),
                      Text(
                        translateDatabase(item.itemsDescAr, item.itemsDescEn) ?? '',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.65,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                    const _SectionTitle(title: 'Ratings & Reviews'),
                    const SizedBox(height: 14),
                    _RatingsSummaryCard(
                      averageRating: rating,
                      reviewCount: reviewCount,
                      ratingPercentage: controller.ratingPercentage,
                      hasRating: hasRating,
                    ),
                    const SizedBox(height: 16),
                    _ReviewComposer(controller: controller),
                    const SizedBox(height: 18),
                    if (controller.hasRatings) ...<Widget>[
                      ...controller.ratings.map(
                        (review) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ReviewCard(review: review),
                        ),
                      ),
                    ] else ...<Widget>[
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151515),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFF31281F)),
                        ),
                        child: Text(
                          'No reviews yet. Be the first to share your experience with this fragrance.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.66),
                            height: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.addSelectedVariantToCartAndOpenCart,
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD6B878),
                              foregroundColor: const Color(0xFF16120D),
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    Get.toNamed(AppRoutes.fragranceBuilder),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFD6B878),
                                  backgroundColor: const Color(0xFF242321),
                                  side: const BorderSide(
                                      color: Color(0xFF3B3125)),
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Build Inspired',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.offAllNamed(AppRoutes.homepage),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF242321),
                                  side: const BorderSide(color: Color(0xFF3B3125)),
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text(
                                  'Try Similar',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _topCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF151515),
          border: Border.all(color: const Color(0xFF2E261B)),
        ),
        child: Icon(icon, color: const Color(0xFFD6B878), size: 18),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'myfont',
        fontSize: 32,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? const Color(0xFF2F291E) : const Color(0xFF151515),
          border: Border.all(
            color: selected ? const Color(0xFFD6B878) : const Color(0xFF3B3125),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFD6B878) : Colors.white70,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _NotesBlock extends StatelessWidget {
  const _NotesBlock({
    required this.title,
    required this.notes,
  });

  final String title;
  final List<String> notes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.72),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: notes
              .map(
                (String note) => _ChoiceChip(
                  label: note,
                  selected: false,
                  onTap: () {},
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.icon,
    required this.title,
    required this.score,
  });

  final IconData icon;
  final String title;
  final int score;

  @override
  Widget build(BuildContext context) {
    final int safeScore = score.clamp(0, 10);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD6B878).withValues(alpha: 0.16),
            ),
            child: Icon(icon, color: const Color(0xFFD6B878)),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List<Widget>.generate(
              10,
              (int index) => Expanded(
                child: Container(
                  height: 10.0 + (index * 8),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index < safeScore
                        ? const Color(0xFFD6B878)
                        : const Color(0xFF4B453C),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagGroup extends StatelessWidget {
  const _TagGroup({
    required this.title,
    required this.tags,
  });

  final String title;
  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: tags
              .map(
                (String tag) => _ChoiceChip(
                  label: tag,
                  selected: false,
                  onTap: () {},
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _RatingsSummaryCard extends StatelessWidget {
  const _RatingsSummaryCard({
    required this.averageRating,
    required this.reviewCount,
    required this.ratingPercentage,
    required this.hasRating,
  });

  final double averageRating;
  final int reviewCount;
  final int ratingPercentage;
  final bool hasRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171614),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF362A1D)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD6B878).withValues(alpha: 0.12),
              border: Border.all(
                color: const Color(0xFFD6B878).withValues(alpha: 0.42),
              ),
            ),
            child: Center(
              child: Text(
                hasRating ? averageRating.toStringAsFixed(1) : '0.0',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Customer sentiment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: List<Widget>.generate(
                    5,
                    (int index) => Icon(
                      index < averageRating.round()
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFF4B400),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  reviewCount > 0
                      ? '$reviewCount reviews - $ratingPercentage% recommend it'
                      : 'No verified reviews yet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewComposer extends StatelessWidget {
  const _ReviewComposer({required this.controller});

  final ProductDetailsControllerImp controller;

  @override
  Widget build(BuildContext context) {
    final bool hasUserRating = controller.hasUserRating;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171614),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF362A1D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                hasUserRating ? 'Edit your review' : 'Write a review',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (controller.currentUserId <= 0)
                Text(
                  'Login required',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List<Widget>.generate(5, (int index) {
              final double value = index + 1.0;
              final bool selected = controller.selectedUserRating >= value;
              return IconButton(
                onPressed: controller.isSubmittingRating
                    ? null
                    : () => controller.setUserRating(value),
                splashRadius: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                icon: Icon(
                  selected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xFFF4B400),
                  size: 28,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.ratingCommentController,
            enabled: !controller.isSubmittingRating,
            minLines: 3,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Share what stood out for you, the longevity, and who you would recommend it to.',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.34),
              ),
              filled: true,
              fillColor: const Color(0xFF101010),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF3B3125)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFF3B3125)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFD6B878)),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isSubmittingRating
                      ? null
                      : controller.submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6B878),
                    foregroundColor: const Color(0xFF16120D),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    controller.isSubmittingRating
                        ? 'Saving...'
                        : hasUserRating
                            ? 'Update Review'
                            : 'Submit Review',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (hasUserRating) ...<Widget>[
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: controller.isSubmittingRating
                      ? null
                      : controller.deleteUserRating,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF5C4034)),
                    minimumSize: const Size(110, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final RatingModel review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF31281F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  review.usersName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _formatReviewDate(review.createdAt),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 3,
            children: List<Widget>.generate(
              5,
              (int index) => Icon(
                index < review.rating.round()
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: const Color(0xFFF4B400),
                size: 18,
              ),
            ),
          ),
          if ((review.comment as String).trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.74),
                height: 1.55,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatReviewDate(String value) {
  final String trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  if (trimmed.length >= 16) {
    return trimmed.substring(0, 16).replaceFirst('T', ' ');
  }
  return trimmed;
}
