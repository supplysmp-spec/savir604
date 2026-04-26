import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:tks/controler/delivery_controller.dart';

class SelectAddressMap extends StatefulWidget {
  const SelectAddressMap({super.key});

  @override
  State<SelectAddressMap> createState() => _SelectAddressMapState();
}

class _SelectAddressMapState extends State<SelectAddressMap> {
  final LatLng startPoint = LatLng(30.0715, 31.2057);

  LatLng? selectedPoint;
  double? distanceKm;
  int? deliveryPrice;

  final Distance distance = const Distance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("اختيار عنوان التوصيل"),
        backgroundColor: const Color.fromARGB(255, 255, 123, 0),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: startPoint,
                initialZoom: 14,
                onTap: (tapPos, latlng) {
                  setState(() {
                    selectedPoint = latlng;
                    distanceKm = distance.as(
                        LengthUnit.Kilometer, startPoint, selectedPoint!);
                    deliveryPrice = calculateDeliveryPrice(distanceKm!);
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: startPoint,
                      width: 50,
                      height: 50,
                      child: Icon(Icons.home,
                          color: Colors.red.shade700, size: 40),
                    ),
                    if (selectedPoint != null)
                      Marker(
                        point: selectedPoint!,
                        width: 50,
                        height: 50,
                        child: Icon(Icons.location_on,
                            color: Colors.blue.shade700, size: 40),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 12,
                    offset: Offset(0, -3)),
              ],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AnimatedOpacity(
                  opacity: selectedPoint != null ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      if (distanceKm != null)
                        Text(
                          "المسافة من مركز التوصيل: ${distanceKm!.toStringAsFixed(2)} كم",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800),
                        ),
                      if (deliveryPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            "سعر التوصيل: $deliveryPrice جنيه",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 255, 116, 2)),
                          ),
                        ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: selectedPoint != null
                              ? () {
                                  Get.find<DeliveryController>()
                                      .setDeliveryData(
                                    selectedPoint!,
                                    distanceKm!,
                                    deliveryPrice!,
                                  );
                                  Get.back();
                                }
                              : null,
                          icon: Icon(Icons.check_circle_outline),
                          label: const Text(
                            "تأكيد العنوان",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor:
                                const Color.fromARGB(255, 255, 115, 0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selectedPoint == null)
                  Text(
                    "اضغط على الخريطة لتحديد عنوانك",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int calculateDeliveryPrice(double distanceKm) {
    int blocks = (distanceKm / 5).ceil();
    return blocks * 7;
  }
}
