import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/address/view_controller.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/core/constant/routes.dart';
import 'package:tks/core/theme/app_surface_palette.dart';
import 'package:tks/data/datasource/model/addressmodel.dart';
import 'package:tks/view/widget/common/app_top_banner.dart';

class AddressView extends StatelessWidget {
  const AddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final AddressViewController controller = Get.put(AddressViewController());
    final palette = AppSurfacePalette.of(context);

    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: palette.screenGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: GetBuilder<AddressViewController>(
            builder: (AddressViewController controller) {
              return Stack(
                children: <Widget>[
                  ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                    children: <Widget>[
                      _AddressHero(count: controller.data.length),
                      const SizedBox(height: 18),
                      if (controller.statusRequest == StatusRequest.loading)
                        const Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD6B878),
                            ),
                          ),
                        )
                      else if (controller.data.isEmpty)
                        _EmptyAddressState(
                          onAdd: () async {
                            final dynamic result =
                                await Get.toNamed(AppRoutes.addressadddetails);
                            if (result == true) {
                              controller.getData();
                            }
                          },
                        )
                      else ...controller.data.map(
                        (AddressModel address) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CardAddress(
                            addressModel: address,
                            onDelete: () =>
                                controller.deleteAddress(address.addressId!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: SafeArea(
                      top: false,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final dynamic result =
                              await Get.toNamed(AppRoutes.addressadddetails);
                          if (result == true) {
                            controller.getData();
                          }
                        },
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('Add New Address'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD6B878),
                          foregroundColor: const Color(0xFF16120D),
                          minimumSize: const Size.fromHeight(58),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AddressHero extends StatelessWidget {
  const _AddressHero({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppTopBanner(
      title: 'Addresses',
      subtitle:
          'Save delivery spots once and switch between them quickly whenever you place an order.',
      leadingIcon: Icons.arrow_back_rounded,
      onLeadingTap: Get.back,
      trailingIcon: Icons.location_on_outlined,
      onTrailingTap: () {},
      child: Row(
        children: <Widget>[
          Expanded(
            child: AppTopBannerMetric(
              value: '$count',
              label: 'Saved places',
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: AppTopBannerMetric(
              value: 'Fast',
              label: 'Checkout ready',
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAddressState extends StatelessWidget {
  const _EmptyAddressState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFD6B878).withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.map_outlined,
              color: Color(0xFFD6B878),
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No addresses saved yet',
            style: TextStyle(
              color: palette.primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first address so delivery details are ready the next time you checkout.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_location_alt_outlined),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.accent,
              side: BorderSide(color: palette.borderStrong),
            ),
            label: const Text('Add Address'),
          ),
        ],
      ),
    );
  }
}

class CardAddress extends StatelessWidget {
  const CardAddress({
    super.key,
    required this.addressModel,
    this.onDelete,
  });

  final AddressModel addressModel;
  final void Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = AppSurfacePalette.of(context);
    final String title = (addressModel.addressName ?? '').trim().isEmpty
        ? 'Address #${addressModel.addressId ?? ''}'
        : addressModel.addressName!.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6B878).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFFD6B878),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: palette.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFF26A61),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF101010),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2A221B)),
            ),
            child: Column(
              children: <Widget>[
                _AddressInfoRow(
                  icon: Icons.location_city_outlined,
                  text: addressModel.addressCity ?? '',
                ),
                const SizedBox(height: 10),
                _AddressInfoRow(
                  icon: Icons.signpost_outlined,
                  text: addressModel.addressStreet ?? '',
                ),
                const SizedBox(height: 10),
                _AddressInfoRow(
                  icon: Icons.phone_outlined,
                  text: addressModel.addressphone ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressInfoRow extends StatelessWidget {
  const _AddressInfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final String value = text.trim().isEmpty ? '-' : text.trim();

    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: const Color(0xFFD6B878)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
            ),
          ),
        ),
      ],
    );
  }
}
