import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tks/controler/address/adddetails_controller.dart';
import 'package:tks/core/class/StatusRequest.dart';
import 'package:tks/view/widget/common/app_top_banner.dart';

class AddressAddDetails extends StatelessWidget {
  const AddressAddDetails({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AddAddressDetailsController());

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF060606),
              Color(0xFF0B0B0B),
              Color(0xFF17110B),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: GetBuilder<AddAddressDetailsController>(
            builder: (AddAddressDetailsController controller) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: <Widget>[
                  const _AddressAddHero(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFF31281F)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Address Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill in the delivery details carefully so this address is ready for checkout.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.58),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _AddressField(
                          controller: controller.name,
                          label: 'Address Name',
                          hint: 'Home, office, studio...',
                          icon: Icons.place_outlined,
                        ),
                        const SizedBox(height: 12),
                        _AddressField(
                          controller: controller.city,
                          label: 'City',
                          hint: 'Enter your city',
                          icon: Icons.location_city_outlined,
                        ),
                        const SizedBox(height: 12),
                        _AddressField(
                          controller: controller.street,
                          label: 'Street',
                          hint: 'Street or area details',
                          icon: Icons.signpost_outlined,
                        ),
                        const SizedBox(height: 12),
                        _AddressField(
                          controller: controller.phone,
                          label: 'Phone Number',
                          hint: 'A number the courier can reach',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                controller.statusRequest == StatusRequest.loading
                                    ? null
                                    : controller.addAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD6B878),
                              foregroundColor: const Color(0xFF16120D),
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: controller.statusRequest ==
                                    StatusRequest.loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF16120D),
                                    ),
                                  )
                                : const Text(
                                    'Save Address',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

class _AddressAddHero extends StatelessWidget {
  const _AddressAddHero();

  @override
  Widget build(BuildContext context) {
    return AppTopBanner(
      title: 'Add Address',
      subtitle:
          'Create a clean delivery record once, then use it anytime you place a new order.',
      leadingIcon: Icons.arrow_back_rounded,
      onLeadingTap: Get.back,
      trailingIcon: Icons.add_location_alt_outlined,
      onTrailingTap: () {},
      child: const AppTopBannerMetric(
        value: 'Ready',
        label: 'Delivery setup',
      ),
    );
  }
}

class _AddressField extends StatelessWidget {
  const _AddressField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.32)),
        prefixIcon: Icon(icon, color: const Color(0xFFD6B878)),
        filled: true,
        fillColor: const Color(0xFF101010),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2A221B)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2A221B)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD6B878)),
        ),
      ),
    );
  }
}
