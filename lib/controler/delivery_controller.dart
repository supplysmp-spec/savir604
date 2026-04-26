import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class DeliveryController extends GetxController {
  LatLng? selectedAddress;
  double? distanceKm;
  int? price;

  void setDeliveryData(LatLng point, double dist, int deliveryPrice) {
    selectedAddress = point;
    distanceKm = dist;
    price = deliveryPrice;
    update();
  }
}
