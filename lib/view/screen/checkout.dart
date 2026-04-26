import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/cart/cart_controller.dart';
import 'package:tks/controler/checkout/checkout_controller.dart';
import 'package:tks/core/class/handlingdataview.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/functions/currency_formatter.dart';
import 'package:tks/core/theme/app_surface_palette.dart';
import 'package:tks/data/datasource/model/addressmodel.dart';
import 'package:tks/data/datasource/model/delivery_method_model.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  late final CheckoutController controller;
  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CheckoutController());
  }

  void _continueStep() {
    if (currentStep == 0) {
      final bool hasAddress = controller.dataaddress.isNotEmpty;
      if (!hasAddress) {
        Get.toNamed(AppRoutes.addressadddetails)?.then((_) {
          controller.getShippingAddress();
        });
        return;
      }
    }

    if (currentStep < 2) {
      setState(() => currentStep += 1);
      return;
    }

    controller.checkout();
  }

  @override
  Widget build(BuildContext context) {
    final CartController cart = Get.find<CartController>();
    final palette = AppSurfacePalette.of(context);

    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: SafeArea(
        bottom: false,
        child: GetBuilder<CheckoutController>(
          builder: (CheckoutController logic) => HandlingDataView(
            statusRequest: logic.statusRequest,
            widget: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _CheckoutCircleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () {
                              if (currentStep > 0) {
                                setState(() => currentStep -= 1);
                                return;
                              }
                              Get.back();
                            },
                          ),
                          Expanded(
                            child: Text(
                              'Checkout'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: palette.primaryText,
                                fontFamily: 'myfont',
                                fontSize: 27,
                              ),
                            ),
                          ),
                          const SizedBox(width: 44),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _CheckoutProgress(currentStep: currentStep),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 160),
                    children: <Widget>[
                      if (currentStep == 0) _AddressStep(controller: logic),
                      if (currentStep == 1) _DeliveryStep(controller: logic),
                      if (currentStep == 2) ...<Widget>[
                        _PaymentStep(controller: logic),
                        const SizedBox(height: 18),
                        _CheckoutSummary(cart: cart, controller: logic),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: GetBuilder<CheckoutController>(
        builder: (CheckoutController logic) => Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: palette.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            border: Border(top: BorderSide(color: palette.border)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: logic.statusRequest.toString().contains('loading')
                    ? null
                    : _continueStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD6B878),
                  foregroundColor: palette.accentText,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  currentStep == 2 ? 'Place Order'.tr : 'Continue'.tr,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutProgress extends StatelessWidget {
  const _CheckoutProgress({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Row(
      children: List<Widget>.generate(3, (int index) {
        final bool active = index <= currentStep;
        return Expanded(
          child: Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? palette.accent : palette.cardAlt,
                  border: Border.all(
                    color: active ? palette.accent : palette.borderStrong,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color:
                          active ? palette.accentText : palette.secondaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: currentStep > index
                        ? palette.accent
                        : palette.borderStrong,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _CheckoutCircleButton extends StatelessWidget {
  const _CheckoutCircleButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.card,
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, color: palette.accent, size: 18),
      ),
    );
  }
}

class _StepHeading extends StatelessWidget {
  const _StepHeading({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Row(
      children: <Widget>[
        Icon(icon, color: palette.accent),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: palette.primaryText,
            fontFamily: 'myfont',
            fontSize: 31,
          ),
        ),
      ],
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StepHeading(
          icon: Icons.location_on_outlined,
          title: 'Shipping Address'.tr,
        ),
        const SizedBox(height: 18),
        if (controller.dataaddress.isEmpty)
          _EmptyAddressCard(controller: controller)
        else
          ...controller.dataaddress.map(
            (AddressModel address) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _AddressCard(
                address: address,
                selected: controller.addressid == address.addressId,
                onTap: () =>
                    controller.chooseShippingAddress(address.addressId!),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyAddressCard extends StatelessWidget {
  const _EmptyAddressCard({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF242321),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B3125)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No saved shipping address yet'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Add an address first so we can deliver your fragrance to the right location.'
                .tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              await Get.toNamed(AppRoutes.addressadddetails);
              controller.getShippingAddress();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFD6B878),
              side: const BorderSide(color: Color(0xFFD6B878)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text('Add Address'.tr),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final AddressModel address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF342B1E) : const Color(0xFF242321),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFFD6B878) : const Color(0xFF3B3125),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: selected
                    ? const Color(0xFFD6B878).withValues(alpha: 0.18)
                    : const Color(0xFF2B2926),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: Color(0xFFD6B878),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    address.addressName ?? 'Shipping Address'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${address.addressStreet ?? ''}, ${address.addressCity ?? ''}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.62),
                      height: 1.4,
                    ),
                  ),
                  if ((address.addressphone ?? '').isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      address.addressphone!,
                      style: const TextStyle(
                        color: Color(0xFFE9D5AC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? const Color(0xFFD6B878) : Colors.white38,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryStep extends StatelessWidget {
  const _DeliveryStep({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StepHeading(
          icon: Icons.local_shipping_outlined,
          title: 'Delivery Options'.tr,
        ),
        const SizedBox(height: 18),
        if (controller.deliveryMethods.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF242321),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF3B3125)),
            ),
            child: Text(
              'No delivery options available right now.'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ...controller.deliveryMethods.map(
            (DeliveryMethodModel method) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _OptionCard(
                title: method.displayName(isArabic),
                subtitle: [
                  method.displayDescription(isArabic),
                  method.displayEta(isArabic),
                ].where((String value) => value.trim().isNotEmpty).join(' • '),
                trailing: CurrencyFormatter.egp(method.price),
                selected: controller.deliveryType == method.id,
                onTap: () => controller.chooseDeliveryType(method.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({required this.controller});

  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StepHeading(
          icon: Icons.credit_card_outlined,
          title: 'Payment Method'.tr,
        ),
        const SizedBox(height: 18),
        _OptionCard(
          title: 'Cash on Delivery'.tr,
          subtitle: 'Pay when your order arrives'.tr,
          leading: Icons.payments_outlined,
          selected: controller.paymentMethod == '0',
          onTap: () => controller.choosePaymentMethod('0'),
        ),
        const SizedBox(height: 14),
        _OptionCard(
          title: 'Credit Card'.tr,
          subtitle: 'Secure online payment'.tr,
          leading: Icons.credit_card_rounded,
          selected: controller.paymentMethod == '1',
          onTap: () => controller.choosePaymentMethod('1'),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailing,
    this.leading,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? trailing;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF342B1E) : const Color(0xFF242321),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? const Color(0xFFD6B878) : const Color(0xFF3B3125),
          ),
        ),
        child: Row(
          children: <Widget>[
            if (leading != null) ...<Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF2B2926),
                ),
                child: Icon(leading, color: const Color(0xFFD6B878)),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(
                  color: Color(0xFFD6B878),
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              )
            else
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? const Color(0xFFD6B878) : Colors.white38,
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({
    required this.cart,
    required this.controller,
  });

  final CartController cart;
  final CheckoutController controller;

  @override
  Widget build(BuildContext context) {
    final double shipping = controller.selectedDeliveryMethod?.price ?? 0;
    final double total = cart.getFinalTotal() + shipping;

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
          const SizedBox(height: 14),
          _summaryRow(
              'Subtotal'.tr, CurrencyFormatter.egp(cart.getFinalTotal())),
          const SizedBox(height: 10),
          _summaryRow('Shipping'.tr, CurrencyFormatter.egp(shipping)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: Color(0xFF3A3126)),
          ),
          _summaryRow('Total'.tr, CurrencyFormatter.egp(total),
              highlight: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: highlight ? 18 : 16,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFFD6B878) : Colors.white,
            fontSize: highlight ? 21 : 16,
            fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
