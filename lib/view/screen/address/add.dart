// // ignore_for_file: unused_local_variable

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:tks/controler/address/add_controller.dart';
// import 'package:tks/core/class/handlingdataview.dart';
// import 'package:tks/core/constant/color.dart';

// class AddressAdd extends StatelessWidget {
//   const AddressAdd({super.key});

//   @override
//   Widget build(BuildContext context) {
//     AddAddressController controllerpage = Get.put(AddAddressController());
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('add new address'),
//       ),
//       body: Container(
//         child: GetBuilder<AddAddressController>(
//             builder: ((controllerpage) => HandlingDataView(
//                 statusRequest: controllerpage.statusRequest,
//                 widget: Column(children: [
//                   if (controllerpage.kGooglePlex != null)
//                     Expanded(
//                         child: Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         GoogleMap(
//                           mapType: MapType.normal,
//                           markers: controllerpage.markers.toSet(),
//                           onTap: (latlong) {
//                             controllerpage.addMarkers(latlong);
//                           },
//                           initialCameraPosition: controllerpage.kGooglePlex!,
//                           onMapCreated: (GoogleMapController controllermap) {
//                             controllerpage.completercontroller!
//                                 .complete(controllermap);
//                           },
//                         ),
//                         Positioned(
//                           bottom: 10,
//                           child: Container(
//                             child: MaterialButton(
//                               minWidth: 200,
//                               onPressed: () {
//                                 controllerpage.goToPageAddDetailsAddress();
//                               },
//                               color: ColorApp.praimaryColor,
//                               textColor: Colors.white,
//                               child:
//                                   Text("اكمال", style: TextStyle(fontSize: 18)),
//                             ),
//                           ),
//                         )
//                       ],
//                     ))
//                 ])))),
//       ),
//     );
//   }
// }
