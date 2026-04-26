import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/cart/cart_controller.dart';
import 'package:tks/controler/home/homescreen_controller.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/functions/app_image_urls.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/data/datasource/model/cartmodel.dart';
import 'package:tks/view/widget/common/fallback_network_image.dart';

class Cart extends StatelessWidget {
  Cart({super.key});

  final CartController controller = Get.isRegistered<CartController>()
      ? Get.find<CartController>()
      : Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        bottom: false,
        child: GetBuilder<CartController>(
          builder: (CartController logic) => HandlingDataView(
            statusRequest: logic.statusRequest,
            widget: Column(
              children: <Widget>[
                _LuxuryHeader(title: 'Shopping Cart'.tr),
                Expanded(
                  child: logic.data.isEmpty
                      ? const _EmptyCartState()
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 180),
                          children: <Widget>[
                            ...logic.data.map(
                              (CartModel item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: _CartItemCard(
                                    item: item, controller: logic),
                              ),
                            ),
                            _PromoCodeCard(controller: logic),
                            const SizedBox(height: 18),
                            _CartSummaryCard(controller: logic),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GetBuilder<CartController>(
        builder: (CartController logic) {
          if (logic.data.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              border: Border(top: BorderSide(color: Color(0xFF2B2419))),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Total'.tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.58),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(logic.getFinalTotal()),
                              style: const TextStyle(
                                color: Color(0xFFD6B878),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: logic.goToPageCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6B878),
                        foregroundColor: const Color(0xFF16120D),
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Proceed to Checkout'.tr,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LuxuryHeader extends StatelessWidget {
  const _LuxuryHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
      child: Row(
        children: <Widget>[
          _CircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {
              if (Get.previousRoute.isNotEmpty) {
                Get.back();
                return;
              }
              if (Get.isRegistered<HomeScreenControllerImp>()) {
                Get.find<HomeScreenControllerImp>().changePage(0);
              }
            },
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'myfont',
                fontSize: 27,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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

class _EmptyCartState extends StatelessWidget {
  const _EmptyCartState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF2F271D)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFFE8CE92), Color(0xFFD0A95E)],
                  ),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFF1A160F),
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your cart is empty'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'myfont',
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add luxury fragrances and custom creations to begin your checkout journey.'
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 15,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.controller,
  });

  final CartModel item;
  final CartController controller;

  @override
  Widget build(BuildContext context) {
    final String title = (item.itemsNameEn?.trim().isNotEmpty == true)
        ? item.itemsNameEn!.trim()
        : (item.itemsNameAr?.trim().isNotEmpty == true)
            ? item.itemsNameAr!.trim()
            : 'Precious Fragrance'.tr;
    final String collectionLabel =
        item.isCustomPerfume ? 'Custom Perfume'.tr : 'Precious Collection'.tr;
    final String details = (item.itemsDescEn?.trim().isNotEmpty == true)
        ? item.itemsDescEn!.trim()
        : (item.itemsDescAr?.trim().isNotEmpty == true)
            ? item.itemsDescAr!.trim()
            : '';
    final double linePrice = double.tryParse(item.lineTotal ?? '0') ?? 0;
    final int count = int.tryParse(item.countitems ?? '1') ?? 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 86,
              height: 86,
              child: item.isCustomPerfume
                  ? const _CustomPerfumeArtwork()
                  : FallbackNetworkImage(
                      imageUrls: AppImageUrls.item(item.itemsImage),
                      label: title,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  collectionLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.44),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'myfont',
                  ),
                ),
                if (details.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(
                    details,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Text(
                      _formatCurrency(linePrice),
                      style: const TextStyle(
                        color: Color(0xFFD6B878),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    _QtyButton(
                      icon: Icons.remove_rounded,
                      onTap: () async {
                        await controller.delete(
                          cartid: item.cartId,
                          itemsid: item.itemsId,
                        );
                        controller.refreshPage();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add_rounded,
                      onTap: () async {
                        await controller.add(
                          item.itemsId,
                          cartid: item.cartId,
                          customPerfumeId: item.cartCustomPerfumeId,
                        );
                        controller.refreshPage();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomPerfumeArtwork extends StatelessWidget {
  const _CustomPerfumeArtwork();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFE8D29A),
            Color(0xFFC79B57),
            Color(0xFF2A2014),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(8),
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF16120D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: Color(0xFFD6B878),
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.star_rounded,
              size: 34,
              color: Color(0xFF16120D),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2B2926),
          border: Border.all(color: const Color(0xFF473823)),
        ),
        child: Icon(icon, color: const Color(0xFFD6B878)),
      ),
    );
  }
}

class _PromoCodeCard extends StatelessWidget {
  const _PromoCodeCard({required this.controller});

  final CartController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.local_offer_outlined, color: Color(0xFFD6B878)),
              const SizedBox(width: 10),
              Text(
                'Promo Code'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'myfont',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller.controllercoupon,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter code'.tr,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.34),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0F0F0F),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: controller.isCheckingCoupon
                      ? null
                      : controller.checkcoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD6B878),
                    foregroundColor: const Color(0xFF16120D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: controller.isCheckingCoupon
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Apply'.tr,
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                ),
              ),
            ],
          ),
          if ((controller.couponname ?? '').isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF5B482B)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      '${controller.couponname} applied • ${controller.discountcoupon.toStringAsFixed(0)}% off',
                      style: const TextStyle(
                        color: Color(0xFFE9D5AC),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.removeCoupon,
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFFD6B878)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({required this.controller});

  final CartController controller;

  @override
  Widget build(BuildContext context) {
    final double subtotal = controller.getSubtotal();
    final double discount = controller.getTotalItemsDiscountAmount() +
        controller.getCouponDiscountAmount();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Order Summary'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'myfont',
            ),
          ),
          const SizedBox(height: 18),
          _summaryRow('Subtotal'.tr, _formatCurrency(subtotal)),
          const SizedBox(height: 12),
          _summaryRow('Shipping'.tr, 'Calculated at checkout'.tr),
          const SizedBox(height: 12),
          _summaryRow(
            'Savings'.tr,
            discount > 0 ? '-${_formatCurrency(discount)}' : _formatCurrency(0),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFF3A3126)),
          ),
          _summaryRow(
            'Total'.tr,
            _formatCurrency(controller.getFinalTotal()),
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value, {bool highlight = false}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: highlight ? 0.94 : 0.70),
              fontSize: highlight ? 20 : 16,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFFD6B878) : Colors.white,
            fontSize: highlight ? 22 : 16,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String _formatCurrency(double value) => CurrencyFormatter.egp(value);
