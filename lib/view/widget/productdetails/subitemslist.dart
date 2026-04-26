// import 'package:tks/controler/productdetails_controller.dart';
// import 'package:tks/core/constant/color.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class SubitemsList extends GetView<ProductDetailsControllerImp> {
//   const SubitemsList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         ...List.generate(
//           controller.subitems.length,
//           (index) => InkWell(
//             onTap: () {
//               // تحديث حالة العنصر المختار
//               controller.setActiveSubitem(index);
//             },
//             child: Container(
//               margin: const EdgeInsets.only(right: 10),
//               alignment: Alignment.center,
//               padding: const EdgeInsets.only(bottom: 5),
//               height: 60,
//               width: 90,
//               decoration: BoxDecoration(
//                 color: controller.subitems[index]['active'] == "1"
//                     ? ColorApp.praimaryColor
//                     : Colors.white,
//                 border: Border.all(color: ColorApp.skipcolor),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 controller.subitems[index]['name'],
//                 style: TextStyle(
//                   color: controller.subitems[index]['active'] == "1"
//                       ? Colors.white
//                       : ColorApp.praimaryColor,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
