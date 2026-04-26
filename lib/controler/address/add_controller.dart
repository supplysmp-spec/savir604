// import 'dart:async';
// //import 'package:get/get.dart';
// //import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:get/get.dart';
// import 'package:tks/core/class/StatusRequest.dart';
// import 'package:tks/core/constant/routes.dart';

// class AddAddressController extends GetxController {
//   StatusRequest statusRequest = StatusRequest.loading;

//   Completer<GoogleMapController>? completercontroller;

//   List<Marker> markers = [];

//   double? lat;
//   double? long;

//   addMarkers(LatLng latLng) {
//     markers.clear();
//     markers.add(Marker(markerId: const MarkerId("1"), position: latLng));
//     lat = latLng.latitude;
//     long = latLng.longitude;
//     update();
//   }

//   goToPageAddDetailsAddress() {
//     Get.toNamed(AppRoutes.addressadddetails,
//         arguments: {"lat": lat.toString(), "long": long.toString()});
//   }

//   Position? postion;

//   CameraPosition? kGooglePlex;

//   getCurrentLocation() async {
//     postion = await Geolocator.getCurrentPosition();
//     kGooglePlex = CameraPosition(
//       target: LatLng(postion!.latitude, postion!.longitude),
//       zoom: 14.4746,
//     );
//     statusRequest = StatusRequest.none;
//     update();
//   }

//   @override
//   void onInit() {
//     getCurrentLocation();
//     completercontroller = Completer<GoogleMapController>();
//     super.onInit();
//   }
// }
